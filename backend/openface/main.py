"""OpenFace sidecar — wraps FeatureExtraction binary and returns AU/pose features."""
import asyncio
import csv
import io
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse

OPENFACE_BIN = "/opt/OpenFace/build/bin/FeatureExtraction"

app = FastAPI(title="OpenFace Sidecar", version="1.0.0")


@app.get("/health")
async def health():
    return {"status": "ok", "openface": Path(OPENFACE_BIN).exists()}


@app.post("/analyze")
async def analyze_video(video: UploadFile = File(...)):
    """Run OpenFace FeatureExtraction on the uploaded video. Returns AU intensities, pose, and gaze."""
    with tempfile.TemporaryDirectory() as tmpdir:
        video_path = Path(tmpdir) / "input.mp4"
        out_dir = Path(tmpdir) / "out"
        out_dir.mkdir()

        # Save uploaded file
        with open(video_path, "wb") as f:
            f.write(await video.read())

        # Run FeatureExtraction
        cmd = [
            OPENFACE_BIN,
            "-f", str(video_path),
            "-out_dir", str(out_dir),
            "-aus",       # Action Units
            "-pose",      # Head pose
            "-gaze",      # Gaze direction
            "-2Dfp",      # 2D facial landmarks
        ]
        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        _, stderr = await proc.communicate()

        if proc.returncode != 0:
            raise HTTPException(status_code=500, detail=f"OpenFace failed: {stderr.decode()[:500]}")

        # Parse CSV output
        csv_files = list(out_dir.glob("*.csv"))
        if not csv_files:
            raise HTTPException(status_code=500, detail="No OpenFace output CSV found")

        features = _parse_openface_csv(csv_files[0])

    return JSONResponse(content=features)


def _parse_openface_csv(csv_path: Path) -> dict:
    """Aggregate per-frame OpenFace output into summary statistics."""
    rows = []
    with open(csv_path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Only keep frames where face was confidently detected
            try:
                if float(row.get("confidence", 0)) < 0.7:
                    continue
                if row.get("success", "0").strip() != "1":
                    continue
            except ValueError:
                continue
            rows.append(row)

    if not rows:
        return {"error": "no_confident_frames", "frame_count": 0}

    def _mean(col: str) -> Optional[float]:
        vals = []
        for r in rows:
            try:
                vals.append(float(r[col.strip()]))
            except (KeyError, ValueError):
                pass
        return sum(vals) / len(vals) if vals else None

    # Action Units (intensity r=regression, presence c=classification)
    aus = ["AU01_r", "AU02_r", "AU04_r", "AU05_r", "AU06_r", "AU07_r",
           "AU09_r", "AU10_r", "AU12_r", "AU14_r", "AU15_r", "AU17_r",
           "AU20_r", "AU23_r", "AU25_r", "AU26_r", "AU45_r"]

    au_means = {au: _mean(au) for au in aus}

    # Pose: Rx Ry Rz (head rotation in radians)
    pose = {
        "pose_Rx": _mean("pose_Rx"),
        "pose_Ry": _mean("pose_Ry"),
        "pose_Rz": _mean("pose_Rz"),
    }

    # Gaze
    gaze = {
        "gaze_angle_x": _mean("gaze_angle_x"),
        "gaze_angle_y": _mean("gaze_angle_y"),
    }

    # Derived: blink rate from AU45 (blink AU)
    # AU45_r > 0.5 heuristic for a blink frame
    blink_frames = sum(1 for r in rows if _safe_float(r.get("AU45_r", 0)) > 0.5)
    blink_rate_per_min = (blink_frames / len(rows)) * 30 * 60  # assume 30fps

    return {
        "frame_count": len(rows),
        "au_means": {k: v for k, v in au_means.items() if v is not None},
        "pose": {k: v for k, v in pose.items() if v is not None},
        "gaze": {k: v for k, v in gaze.items() if v is not None},
        "blink_rate_per_min": blink_rate_per_min,
        # Valence/arousal proxy: AU12 (smile) - AU15 (frown)
        "valence_proxy": (au_means.get("AU12_r") or 0) - (au_means.get("AU15_r") or 0),
    }


def _safe_float(v) -> float:
    try:
        return float(v)
    except (TypeError, ValueError):
        return 0.0
