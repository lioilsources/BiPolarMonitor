"""
Video facial analysis using MediaPipe Face Landmarker.
Extracts proxies for Action Units, blink rate, and head stability.
(Full OpenFace AU analysis is a future enhancement via sidecar container.)
"""
import numpy as np
import cv2
import mediapipe as mp
from pathlib import Path


mp_face_mesh = mp.solutions.face_mesh

# Landmark indices for key facial regions (MediaPipe 478-point model)
_LEFT_EYE_TOP = 159
_LEFT_EYE_BOTTOM = 145
_LEFT_EYE_OUTER = 33
_LEFT_EYE_INNER = 133
_RIGHT_EYE_TOP = 386
_RIGHT_EYE_BOTTOM = 374
_MOUTH_LEFT = 61
_MOUTH_RIGHT = 291
_MOUTH_TOP = 13
_MOUTH_BOTTOM = 14
_BROW_LEFT_INNER = 107
_BROW_LEFT_OUTER = 70
_BROW_RIGHT_INNER = 336
_BROW_RIGHT_OUTER = 300


def _eye_aspect_ratio(landmarks, top_idx: int, bottom_idx: int, outer_idx: int, inner_idx: int) -> float:
    top = np.array([landmarks[top_idx].x, landmarks[top_idx].y])
    bottom = np.array([landmarks[bottom_idx].x, landmarks[bottom_idx].y])
    outer = np.array([landmarks[outer_idx].x, landmarks[outer_idx].y])
    inner = np.array([landmarks[inner_idx].x, landmarks[inner_idx].y])
    vertical = np.linalg.norm(top - bottom)
    horizontal = np.linalg.norm(outer - inner)
    return vertical / (horizontal + 1e-6)


def analyze_video(video_path: str) -> dict:
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    ears = []
    mouth_openness = []
    brow_heights = []
    head_rx = []  # proxy for head tilt (y-diff between ears)

    with mp_face_mesh.FaceMesh(
        max_num_faces=1,
        refine_landmarks=True,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    ) as face_mesh:
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = face_mesh.process(frame_rgb)
            if not results.multi_face_landmarks:
                continue

            lm = results.multi_face_landmarks[0].landmark

            # Eye Aspect Ratio (proxy for blink detection)
            left_ear = _eye_aspect_ratio(lm, _LEFT_EYE_TOP, _LEFT_EYE_BOTTOM, _LEFT_EYE_OUTER, _LEFT_EYE_INNER)
            right_ear = _eye_aspect_ratio(lm, _RIGHT_EYE_TOP, _RIGHT_EYE_BOTTOM, _RIGHT_EYE_OUTER, _RIGHT_EYE_INNER)
            ears.append((left_ear + right_ear) / 2)

            # Mouth openness (vertical / horizontal)
            mouth_v = abs(lm[_MOUTH_TOP].y - lm[_MOUTH_BOTTOM].y)
            mouth_h = abs(lm[_MOUTH_LEFT].x - lm[_MOUTH_RIGHT].x)
            mouth_openness.append(mouth_v / (mouth_h + 1e-6))

            # Brow height relative to eye (proxy for AU1/4)
            brow_y = (lm[_BROW_LEFT_INNER].y + lm[_BROW_RIGHT_INNER].y) / 2
            eye_y = (lm[_LEFT_EYE_TOP].y + lm[_RIGHT_EYE_TOP].y) / 2
            brow_heights.append(eye_y - brow_y)  # positive = brow above eye

            # Head pose proxy: y-position difference between left/right ear area
            head_rx.append(lm[234].y - lm[454].y)  # cheek landmarks

    cap.release()

    if not ears:
        return _empty_video_features()

    ears_arr = np.array(ears)
    # Blink detection: EAR drops below threshold (0.20 typical)
    blink_threshold = np.mean(ears_arr) * 0.7
    blink_frames = np.sum(ears_arr < blink_threshold)
    duration_min = total_frames / fps / 60.0
    blink_rate = blink_frames / (duration_min + 1e-6)

    return {
        "ear_mean": float(np.mean(ears_arr)),
        "ear_std": float(np.std(ears_arr)),
        "blink_rate_per_min": round(blink_rate, 1),
        "mouth_openness_mean": float(np.mean(mouth_openness)),
        "mouth_openness_std": float(np.std(mouth_openness)),
        "brow_height_mean": float(np.mean(brow_heights)),
        "brow_height_std": float(np.std(brow_heights)),
        "head_rx_std": float(np.std(head_rx)),  # movement/agitation proxy
        "frames_analyzed": len(ears),
        "total_frames": total_frames,
    }


def _empty_video_features() -> dict:
    return {
        "ear_mean": 0.0, "ear_std": 0.0, "blink_rate_per_min": 0.0,
        "mouth_openness_mean": 0.0, "mouth_openness_std": 0.0,
        "brow_height_mean": 0.0, "brow_height_std": 0.0,
        "head_rx_std": 0.0, "frames_analyzed": 0, "total_frames": 0,
    }


def facial_zscore_features(video_features: dict) -> dict:
    """
    Normalize video features into interpretable signals.
    Blink: baseline ~15-20/min; stress > 25 or < 8.
    Head movement: high std = agitation.
    """
    blink = video_features.get("blink_rate_per_min", 15.0)
    blink_deviation = abs(blink - 17.0) / 5.0  # normalized

    mouth_activity = video_features.get("mouth_openness_std", 0.0)
    brow_activity = video_features.get("brow_height_std", 0.0)
    head_movement = video_features.get("head_rx_std", 0.0)

    return {
        "blink_deviation": round(blink_deviation, 3),
        "mouth_activity": round(mouth_activity, 4),
        "brow_activity": round(brow_activity, 4),
        "head_movement": round(head_movement, 4),
        "engagement_proxy": round((mouth_activity + brow_activity) / 2, 4),
    }
