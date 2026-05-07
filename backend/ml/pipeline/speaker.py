"""
Speaker embedding + verification.
Uses Whisper encoder embeddings as speaker representation
(lightweight, no separate model required).
"""
import numpy as np
import torch
import whisper
from typing import Optional


_model: Optional[whisper.Whisper] = None


def _get_model() -> whisper.Whisper:
    global _model
    if _model is None:
        _model = whisper.load_model("base")  # smaller model for embedding only
    return _model


def extract_speaker_embedding(audio_path: str) -> list[float]:
    """
    Extract a speaker embedding from an audio file.
    Uses Whisper's encoder output (mean-pooled) as a speaker representation.
    This is a lightweight proxy — for production use SpeechBrain or pyannote.
    """
    model = _get_model()
    audio = whisper.load_audio(audio_path)
    audio = whisper.pad_or_trim(audio)
    mel = whisper.log_mel_spectrogram(audio).to(model.device)

    with torch.no_grad():
        encoder_output = model.encoder(mel.unsqueeze(0))  # (1, frames, dim)
        # Mean pool over time dimension → (dim,)
        embedding = encoder_output.squeeze(0).mean(dim=0).cpu().numpy()

    # L2-normalize
    norm = np.linalg.norm(embedding)
    if norm > 1e-8:
        embedding = embedding / norm

    return embedding.tolist()


def average_embeddings(embeddings: list[list[float]]) -> list[float]:
    """Average multiple enrollment embeddings into one representative vector."""
    arr = np.array(embeddings)
    mean = arr.mean(axis=0)
    norm = np.linalg.norm(mean)
    if norm > 1e-8:
        mean = mean / norm
    return mean.tolist()


def cosine_similarity(a: list[float], b: list[float]) -> float:
    va, vb = np.array(a), np.array(b)
    denom = np.linalg.norm(va) * np.linalg.norm(vb)
    return float(np.dot(va, vb) / denom) if denom > 1e-8 else 0.0


def verify_speaker(audio_path: str, stored_embedding: list[float], threshold: float = 0.75) -> dict:
    """
    Compare audio against stored enrollment embedding.
    Returns similarity score and verification result.
    """
    current_embedding = extract_speaker_embedding(audio_path)
    similarity = cosine_similarity(current_embedding, stored_embedding)
    return {
        "similarity": round(similarity, 4),
        "verified": similarity >= threshold,
        "embedding": current_embedding,
    }
