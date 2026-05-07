"""
Face embedding extraction and verification using DeepFace / ArcFace.
"""
import logging
import os
import tempfile
from typing import Optional

import numpy as np

logger = logging.getLogger(__name__)


def extract_face_embedding(image_path: str) -> list[float] | None:
    """
    Extract a face embedding from an image file using DeepFace with ArcFace model.
    Returns the embedding as a list of floats, or None if face detection fails.
    """
    try:
        from deepface import DeepFace
        result = DeepFace.represent(
            img_path=image_path,
            model_name="ArcFace",
            enforce_detection=True,
            detector_backend="opencv",
        )
        if result and len(result) > 0:
            embedding = result[0]["embedding"]
            return list(embedding)
        return None
    except Exception as e:
        logger.warning(f"[face_embedder] extract_face_embedding failed for {image_path}: {e}")
        return None


def average_face_embeddings(embeddings: list[list[float]]) -> list[float]:
    """
    Compute the mean of multiple enrollment embeddings and L2-normalize the result.
    """
    arr = np.array(embeddings, dtype=np.float32)
    mean = arr.mean(axis=0)
    norm = np.linalg.norm(mean)
    if norm > 1e-8:
        mean = mean / norm
    return mean.tolist()


def cosine_similarity(a: list[float], b: list[float]) -> float:
    """Compute cosine similarity between two embedding vectors."""
    va = np.array(a, dtype=np.float32)
    vb = np.array(b, dtype=np.float32)
    denom = np.linalg.norm(va) * np.linalg.norm(vb)
    return float(np.dot(va, vb) / denom) if denom > 1e-8 else 0.0


def verify_face(
    image_path: str,
    stored_embedding: list[float],
    threshold: float = 0.68,
) -> dict:
    """
    Verify a face in image_path against a stored enrollment embedding.

    Returns:
        {"verified": bool|None, "similarity": float|None}
        If face detection fails, returns {"verified": None, "similarity": None}.
    """
    current_embedding = extract_face_embedding(image_path)
    if current_embedding is None:
        return {"verified": None, "similarity": None}

    similarity = cosine_similarity(current_embedding, stored_embedding)
    return {
        "verified": similarity >= threshold,
        "similarity": round(similarity, 4),
    }


def extract_frame(video_path: str, second: float = 2.0) -> str | None:
    """
    Extract a single frame from a video at the given timestamp (in seconds).
    Saves the frame to a temporary file and returns the path.
    Returns None if the video cannot be read or no frame is available at that time.
    """
    try:
        import cv2
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            logger.warning(f"[face_embedder] Cannot open video: {video_path}")
            return None

        fps = cap.get(cv2.CAP_PROP_FPS)
        if fps <= 0:
            fps = 25.0

        frame_index = int(fps * second)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

        # If requested second is beyond video length, use last available frame
        if total_frames > 0 and frame_index >= total_frames:
            frame_index = max(0, total_frames - 1)

        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
        ret, frame = cap.read()
        cap.release()

        if not ret or frame is None:
            logger.warning(f"[face_embedder] Could not read frame at second {second} from {video_path}")
            return None

        tmp_file = tempfile.NamedTemporaryFile(suffix=".jpg", delete=False)
        tmp_path = tmp_file.name
        tmp_file.close()

        cv2.imwrite(tmp_path, frame)
        return tmp_path

    except Exception as e:
        logger.warning(f"[face_embedder] extract_frame failed for {video_path}: {e}")
        return None
