"""
BipolarMonitor ML Inference Service (FastAPI).
Receives analysis jobs from the API service, runs the full pipeline,
writes results back to the shared PostgreSQL database.
"""
import json
import os
import tempfile
import asyncio
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path

import httpx
from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

from pipeline.audio_analyzer import analyze_audio
from pipeline.video_analyzer import analyze_video, facial_zscore_features, _try_openface, _openface_to_features
from pipeline.cohesion import analyze_cohesion
from pipeline.scoring import compute_scores, compute_trend, update_baseline
from pipeline.speaker import verify_speaker
from routers.speaker_router import router as speaker_router

DATABASE_URL = os.environ["DATABASE_URL"]
MINIO_ENDPOINT = os.environ["MINIO_ENDPOINT"]
MINIO_ACCESS_KEY = os.environ["MINIO_ACCESS_KEY"]
MINIO_SECRET_KEY = os.environ["MINIO_SECRET_KEY"]
MINIO_BUCKET = os.environ.get("MINIO_BUCKET", "bipolar-media")
API_CALLBACK_URL = os.environ.get("API_CALLBACK_URL", "http://api:8000")

engine = create_async_engine(DATABASE_URL, echo=False)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)


def _get_minio():
    from minio import Minio
    return Minio(MINIO_ENDPOINT, access_key=MINIO_ACCESS_KEY, secret_key=MINIO_SECRET_KEY, secure=False)


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await engine.dispose()


app = FastAPI(title="BipolarMonitor ML Service", lifespan=lifespan)
app.include_router(speaker_router)


class AnalyzeRequest(BaseModel):
    measurement_id: str
    video_path: str
    audio_path: str


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/analyze", status_code=202)
async def analyze(request: AnalyzeRequest, background_tasks: BackgroundTasks):
    background_tasks.add_task(_run_pipeline, request.measurement_id, request.video_path, request.audio_path)
    return {"measurement_id": request.measurement_id, "status": "queued"}


async def _run_pipeline(measurement_id: str, video_path: str, audio_path: str):
    async with SessionLocal() as db:
        try:
            # Fetch measurement metadata + user speaker embedding
            row = await db.execute(
                text("SELECT user_id, questions_used, question_timings FROM measurements WHERE id = :id"),
                {"id": measurement_id},
            )
            m = row.fetchone()
            if not m:
                return

            user_id = m.user_id
            questions_used = json.loads(m.questions_used)
            question_timings = json.loads(m.question_timings) if m.question_timings else None

            # Load user speaker embedding for verification
            speaker_row = await db.execute(
                text("SELECT speaker_embedding FROM users WHERE id = :uid"),
                {"uid": user_id},
            )
            user_row = speaker_row.fetchone()
            stored_embedding = json.loads(user_row.speaker_embedding) if user_row and user_row.speaker_embedding else None

            # Download files from MinIO
            minio = _get_minio()
            with tempfile.TemporaryDirectory() as tmpdir:
                video_local = os.path.join(tmpdir, "video.mp4")
                audio_local = os.path.join(tmpdir, "audio.wav")
                minio.fget_object(MINIO_BUCKET, video_path, video_local)
                minio.fget_object(MINIO_BUCKET, audio_path, audio_local)

                # Speaker verification
                speaker_verified = None
                speaker_similarity = None
                if stored_embedding:
                    sv = verify_speaker(audio_local, stored_embedding)
                    speaker_verified = sv["verified"]
                    speaker_similarity = sv["similarity"]
                    await db.execute(
                        text("UPDATE measurements SET speaker_verified=:v, speaker_similarity=:s WHERE id=:id"),
                        {"v": speaker_verified, "s": speaker_similarity, "id": measurement_id},
                    )

                # Run analysis pipelines
                audio_features = analyze_audio(audio_local, question_timings)
                # Try OpenFace sidecar first; fall back to MediaPipe
                openface_result = await _try_openface(video_local)
                if openface_result and "error" not in openface_result:
                    video_raw = _openface_to_features(openface_result)
                else:
                    video_raw = analyze_video(video_local)
                video_features = facial_zscore_features(video_raw)
                cohesion_features = analyze_cohesion(
                    audio_features.get("per_question", {}),
                    questions_used,
                )

            # Load user baseline
            baseline_row = await db.execute(
                text("SELECT data, based_on_n FROM user_baselines WHERE user_id = :uid"),
                {"uid": user_id},
            )
            baseline_data = baseline_row.fetchone()
            user_baseline = json.loads(baseline_data.data) if baseline_data else {}
            baseline_n = baseline_data.based_on_n if baseline_data else 0

            # Score
            scores = compute_scores(audio_features, video_features, cohesion_features, user_baseline)

            # Trend (last 7 days composites)
            trend_row = await db.execute(
                text("""
                    SELECT ms.composite_zscore
                    FROM measurement_scores ms
                    JOIN measurements m ON m.id = ms.measurement_id
                    WHERE m.user_id = :uid
                    ORDER BY ms.analyzed_at DESC
                    LIMIT 7
                """),
                {"uid": user_id},
            )
            recent_composites = [r.composite_zscore for r in trend_row.fetchall() if r.composite_zscore is not None]
            trend = compute_trend(scores["composite_zscore"], recent_composites)

            # Flat features for baseline update
            flat_features = {
                "wpm": audio_features.get("wpm"),
                "pause_ratio": audio_features.get("pause_ratio"),
                "total_words": audio_features.get("total_words"),
                "loudness": audio_features.get("gemaps", {}).get("loudness"),
                "f0_range": audio_features.get("gemaps", {}).get("f0_range"),
                "cohesion_mean": cohesion_features.get("cohesion_mean"),
                "engagement_proxy": video_features.get("engagement_proxy"),
                "blink_deviation": video_features.get("blink_deviation"),
            }

            # Update baseline only if speaker verified (or no enrollment yet → allow)
            if speaker_verified is not False:
                history_row = await db.execute(
                    text("""
                        SELECT raw_features FROM measurement_scores ms
                        JOIN measurements me ON me.id = ms.measurement_id
                        WHERE me.user_id = :uid ORDER BY ms.analyzed_at DESC LIMIT 29
                    """),
                    {"uid": user_id},
                )
                history = [json.loads(r.raw_features) for r in history_row.fetchall() if r.raw_features]
                new_baseline = update_baseline(user_id, flat_features, history)
                await db.execute(
                    text("""
                        INSERT INTO user_baselines (user_id, data, based_on_n, updated_at)
                        VALUES (:uid, :data, :n, :ts)
                        ON CONFLICT (user_id) DO UPDATE SET data=:data, based_on_n=:n, updated_at=:ts
                    """),
                    {"uid": user_id, "data": json.dumps(new_baseline), "n": baseline_n + 1, "ts": datetime.utcnow()},
                )

            d = scores["dimensions"]
            # Upsert scores
            await db.execute(
                text("""
                    INSERT INTO measurement_scores (
                        measurement_id, user_id,
                        speech_rate_zscore, pause_ratio_zscore, voice_energy_zscore,
                        f0_range_zscore, response_length_zscore, cohesion_zscore,
                        facial_affect_zscore, composite_zscore,
                        raw_features, per_question, energy_profile, flags, trend_7d,
                        baseline_mean, baseline_std, baseline_n, analyzed_at
                    ) VALUES (
                        :mid, :uid,
                        :sr, :pr, :ve, :fr, :rl, :co, :fa, :cs,
                        :raw, :pq, :ep, :fl, :tr,
                        :bm, :bs, :bn, :ts
                    )
                    ON CONFLICT (measurement_id) DO UPDATE SET
                        speech_rate_zscore=:sr, pause_ratio_zscore=:pr,
                        voice_energy_zscore=:ve, f0_range_zscore=:fr,
                        response_length_zscore=:rl, cohesion_zscore=:co,
                        facial_affect_zscore=:fa, composite_zscore=:cs,
                        raw_features=:raw, per_question=:pq, energy_profile=:ep,
                        flags=:fl, trend_7d=:tr, baseline_mean=:bm,
                        baseline_std=:bs, baseline_n=:bn, analyzed_at=:ts
                """),
                {
                    "mid": measurement_id, "uid": user_id,
                    "sr": d.get("speech_rate"), "pr": d.get("pause_ratio"),
                    "ve": d.get("voice_energy"), "fr": d.get("f0_range"),
                    "rl": d.get("response_length"), "co": d.get("cohesion"),
                    "fa": d.get("facial_affect"), "cs": scores["composite_zscore"],
                    "raw": json.dumps(flat_features),
                    "pq": json.dumps(audio_features.get("per_question", {})),
                    "ep": json.dumps(audio_features.get("energy_profile", {})),
                    "fl": json.dumps(scores["flags"]),
                    "tr": trend,
                    "bm": user_baseline.get("composite_zscore", {}).get("mean"),
                    "bs": user_baseline.get("composite_zscore", {}).get("std"),
                    "bn": baseline_n,
                    "ts": datetime.utcnow(),
                },
            )

            # Mark measurement as analyzed
            await db.execute(
                text("UPDATE measurements SET analyzed=TRUE WHERE id=:id"),
                {"id": measurement_id},
            )
            await db.commit()

            # Notify API → FCM push notification
            webhook_secret = os.environ.get("ML_WEBHOOK_SECRET", "")
            try:
                async with httpx.AsyncClient(timeout=5.0) as client:
                    await client.post(
                        f"{API_CALLBACK_URL}/api/v1/push/analysis-complete",
                        json={
                            "measurement_id": measurement_id,
                            "user_id": user_id,
                            "composite_zscore": scores["composite_zscore"],
                            "flags": scores["flags"],
                            "secret": webhook_secret,
                        },
                    )
            except Exception:
                pass  # FCM failure must never break the pipeline

        except Exception as e:
            await db.rollback()
            print(f"[ML] Pipeline error for {measurement_id}: {e}")
