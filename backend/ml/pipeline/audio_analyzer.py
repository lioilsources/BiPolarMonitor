"""
Audio analysis pipeline: openSMILE (GeMAPS) + Whisper transcription.
Produces per-question features as defined in BIPOLAR_DIALOG_PROTOCOL.md.
"""
import json
import tempfile
from pathlib import Path
from typing import Optional

import numpy as np
import opensmile
import whisper

_whisper_model: Optional[whisper.Whisper] = None
_smile: Optional[opensmile.Smile] = None


def _get_whisper():
    global _whisper_model
    if _whisper_model is None:
        _whisper_model = whisper.load_model("large-v3")
    return _whisper_model


def _get_smile():
    global _smile
    if _smile is None:
        _smile = opensmile.Smile(
            feature_set=opensmile.FeatureSet.eGeMAPS,
            feature_level=opensmile.FeatureLevel.Functionals,
        )
    return _smile


def transcribe(audio_path: str) -> dict:
    """Whisper transcription with word-level timestamps."""
    model = _get_whisper()
    result = model.transcribe(audio_path, word_timestamps=True, language="cs")
    return result


def extract_gemaps(audio_path: str) -> dict:
    """eGeMAPS features for the full audio or a segment."""
    smile = _get_smile()
    features = smile.process_file(audio_path)
    return {
        "f0_mean": float(features["F0semitoneFrom27.5Hz_sma3nz_amean"].values[0]),
        "f0_std": float(features["F0semitoneFrom27.5Hz_sma3nz_stddevNorm"].values[0]),
        "f0_range": float(features["F0semitoneFrom27.5Hz_sma3nz_pctlrange0-2"].values[0]),
        "loudness": float(features["loudness_sma3_amean"].values[0]),
        "jitter": float(features["jitterLocal_sma3nz_amean"].values[0]),
    }


def _extract_words_from_segment(result: dict, start: float, end: float) -> list[dict]:
    words = []
    for seg in result.get("segments", []):
        for w in seg.get("words", []):
            ws = w.get("start", 0)
            we = w.get("end", 0)
            if ws >= start and we <= end + 0.5:
                words.append({"text": w["word"].strip(), "start": ws, "end": we})
    return words


def speech_rate(words: list[dict]) -> float:
    if len(words) < 2:
        return 0.0
    duration = words[-1]["end"] - words[0]["start"]
    if duration < 0.1:
        return 0.0
    return (len(words) / duration) * 60


def pause_analysis(words: list[dict]) -> dict:
    if len(words) < 2:
        return {"pause_ratio": 0.0, "initial_latency": 0.0, "hesitation_count": 0,
                "long_pause_count": 0, "mean_pause_duration": 0.0}
    pauses = []
    for i in range(1, len(words)):
        gap = words[i]["start"] - words[i - 1]["end"]
        if gap > 0.3:
            pauses.append(gap)

    total = words[-1]["end"] - words[0]["start"]
    pause_ratio = sum(pauses) / total if total > 0 else 0.0
    initial_latency = words[0]["start"]
    hesitations = [p for p in pauses if 0.3 < p < 1.0]
    long_pauses = [p for p in pauses if p >= 1.0]

    return {
        "pause_ratio": pause_ratio,
        "initial_latency": initial_latency,
        "hesitation_count": len(hesitations),
        "long_pause_count": len(long_pauses),
        "mean_pause_duration": float(np.mean(pauses)) if pauses else 0.0,
    }


def analyze_audio(
    audio_path: str,
    question_timings: Optional[dict] = None,
) -> dict:
    """
    Full audio analysis. Returns per-question features + global GeMAPS.
    question_timings: {"Q1": {"start": 0.0, "end": 28.5}, ...}
    """
    transcript = transcribe(audio_path)
    gemaps_global = extract_gemaps(audio_path)

    all_words = []
    for seg in transcript.get("segments", []):
        for w in seg.get("words", []):
            all_words.append({"text": w["word"].strip(), "start": w["start"], "end": w["end"]})

    global_wpm = speech_rate(all_words)
    global_pauses = pause_analysis(all_words)
    full_text = transcript.get("text", "")
    total_words = len(full_text.split())

    per_question = {}
    if question_timings:
        for q_id, timing in question_timings.items():
            q_words = _extract_words_from_segment(transcript, timing["start"], timing["end"])
            q_text = " ".join(w["text"] for w in q_words)
            per_question[q_id] = {
                "wpm": speech_rate(q_words),
                "word_count": len(q_words),
                "text": q_text,
                "pauses": pause_analysis(q_words),
            }

    q_word_counts = [per_question[q]["word_count"] for q in sorted(per_question.keys())] if per_question else []
    energy_profile = _compute_energy_profile(q_word_counts)

    # Flags
    flags = []
    q4_data = per_question.get("Q4", {})
    if q4_data.get("word_count", 99) < 10:
        flags.append("emotional_avoidance")
    minimal = sum(1 for q in per_question.values() if q.get("word_count", 99) < 8)
    extended = sum(1 for q in per_question.values() if q.get("word_count", 0) > 120)
    if minimal >= 2:
        flags.append("minimal_responses")
    if extended >= 2:
        flags.append("extended_responses")

    return {
        "wpm": global_wpm,
        "total_words": total_words,
        "full_text": full_text,
        "pause_ratio": global_pauses["pause_ratio"],
        "initial_latency": global_pauses["initial_latency"],
        "hesitation_count": global_pauses["hesitation_count"],
        "long_pause_count": global_pauses["long_pause_count"],
        "gemaps": gemaps_global,
        "per_question": per_question,
        "energy_profile": energy_profile,
        "audio_flags": flags,
    }


def _compute_energy_profile(word_counts: list[int]) -> dict:
    if not word_counts:
        return {"word_counts": [], "slope": 0.0, "variance": 0.0, "pattern": "unknown"}
    if len(word_counts) < 2:
        return {"word_counts": word_counts, "slope": 0.0, "variance": 0.0, "pattern": "single"}
    x = np.arange(len(word_counts))
    slope = float(np.polyfit(x, word_counts, 1)[0])
    variance = float(np.var(word_counts))
    if slope < -2:
        pattern = "declining"
    elif slope > 2:
        pattern = "rising"
    elif variance > 100:
        pattern = "irregular"
    else:
        pattern = "stable"
    return {"word_counts": word_counts, "slope": round(slope, 2), "variance": round(variance, 2), "pattern": pattern}
