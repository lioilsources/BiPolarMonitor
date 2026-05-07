"""
Composite scoring pipeline — z-scores + flags per BIPOLAR_DIALOG_PROTOCOL.md.
"""
import json
import numpy as np
from typing import Optional


WEIGHTS = {
    "speech_rate":      0.18,
    "pause_ratio":      0.12,
    "voice_energy":     0.15,
    "f0_range":         0.10,
    "response_length":  0.15,
    "cohesion":         0.12,
    "facial_affect":    0.10,
    "negative_affect":  0.08,
}


def zscore(value: float, baseline_key: str, user_baseline: dict) -> float:
    entry = user_baseline.get(baseline_key, {})
    mean = entry.get("mean", value)
    std = entry.get("std", 1.0)
    if std < 1e-6:
        return 0.0
    return (value - mean) / std


def compute_scores(
    audio_features: dict,
    video_features: dict,
    cohesion_features: dict,
    user_baseline: dict,
) -> dict:
    gemaps = audio_features.get("gemaps", {})

    dimensions = {
        "speech_rate":      zscore(audio_features.get("wpm", 130), "wpm", user_baseline),
        "pause_ratio":     -zscore(audio_features.get("pause_ratio", 0.2), "pause_ratio", user_baseline),
        "voice_energy":     zscore(gemaps.get("loudness", 0.5), "loudness", user_baseline),
        "f0_range":         zscore(gemaps.get("f0_range", 10.0), "f0_range", user_baseline),
        "response_length":  zscore(audio_features.get("total_words", 100), "total_words", user_baseline),
        "cohesion":         zscore(cohesion_features.get("cohesion_mean", 0.6), "cohesion_mean", user_baseline),
        "facial_affect":    zscore(video_features.get("engagement_proxy", 0.02), "engagement_proxy", user_baseline),
        "negative_affect": -zscore(video_features.get("blink_deviation", 0.5), "blink_deviation", user_baseline),
    }

    composite = sum(dimensions[k] * WEIGHTS[k] for k in dimensions)

    flags = _detect_flags(audio_features, video_features, cohesion_features, dimensions)

    return {
        "dimensions": {k: round(v, 4) for k, v in dimensions.items()},
        "composite_zscore": round(composite, 4),
        "flags": flags,
    }


def _detect_flags(audio: dict, video: dict, cohesion: dict, dimensions: dict) -> list[str]:
    flags = []

    if dimensions["speech_rate"] > 2.0:
        flags.append("elevated_speech_rate")
    if dimensions["speech_rate"] < -2.0:
        flags.append("suppressed_speech_rate")

    if dimensions["f0_range"] < -1.8:
        flags.append("monotone_voice")

    if dimensions["response_length"] < -2.0 or "minimal_responses" in audio.get("audio_flags", []):
        flags.append("minimal_responses")
    if "extended_responses" in audio.get("audio_flags", []):
        flags.append("extended_responses")
    if "emotional_avoidance" in audio.get("audio_flags", []):
        flags.append("emotional_avoidance")

    # Flight of ideas: fast + incoherent
    if dimensions["speech_rate"] > 1.5 and cohesion.get("internal_cohesion_mean", 1.0) < 0.40:
        flags.append("flight_of_ideas")

    # Low energy profile: multiple dimensions suppressed
    depleted = sum(1 for k in ["speech_rate", "voice_energy", "response_length"] if dimensions[k] < -1.5)
    if depleted >= 2:
        flags.append("low_energy_profile")

    # Topic drift flags from cohesion
    flags.extend(cohesion.get("flags", []))

    return list(set(flags))


def compute_trend(
    current_composite: float,
    recent_composites: list[float],
) -> str:
    if len(recent_composites) < 3:
        return "insufficient_data"
    mean_recent = np.mean(recent_composites)
    diff = current_composite - mean_recent
    if diff > 0.5:
        return "markedly_elevated"
    elif diff > 0.2:
        return "mildly_elevated"
    elif diff < -0.5:
        return "markedly_suppressed"
    elif diff < -0.2:
        return "mildly_suppressed"
    return "stable"


def update_baseline(user_id: str, new_features: dict, history: list[dict]) -> dict:
    """
    Rolling weighted baseline from last 30 measurements.
    Weights: older = 0.5, newer = 1.0 (linear interpolation).
    Only update if speaker_verified.
    """
    history = list(history) + [new_features]
    history = history[-30:]

    weights = np.linspace(0.5, 1.0, len(history))
    baseline = {}

    all_keys = set(new_features.keys())
    for key in all_keys:
        values = [h.get(key) for h in history if isinstance(h.get(key), (int, float))]
        if not values:
            continue
        w = weights[-len(values):]
        baseline[key] = {
            "mean": round(float(np.average(values, weights=w)), 6),
            "std": round(float(np.std(values)), 6),
        }

    return baseline
