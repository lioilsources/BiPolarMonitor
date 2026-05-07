import json
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, BackgroundTasks
from pydantic import BaseModel
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from middleware.auth_middleware import get_current_user
from models.measurement import Measurement, MeasurementScore
from models.user import User
from services import storage_service, ml_client

router = APIRouter(prefix="/measurements", tags=["measurements"])


class MeasurementSummary(BaseModel):
    id: str
    recorded_at: datetime
    duration_seconds: int
    analyzed: bool
    composite_zscore: float | None
    flags: list[str]
    trend_7d: str | None


class MeasurementDetail(BaseModel):
    id: str
    recorded_at: datetime
    duration_seconds: int
    questions_used: list[str]
    analyzed: bool
    speaker_verified: bool | None
    speaker_similarity: float | None
    notes: str | None
    scores: dict | None
    per_question: dict | None
    energy_profile: dict | None
    flags: list[str]
    baseline: dict | None
    trend_7d: str | None


@router.post("/upload", status_code=202)
async def upload_measurement(
    background_tasks: BackgroundTasks,
    measurement_id: str = Form(...),
    questions_used: str = Form(...),       # JSON: ["Q1B","Q2A","Q3C","Q4A","Q5B"]
    question_timings: str = Form(None),    # JSON: {"Q1":{"start":0,"end":28.5},...}
    recorded_at: str = Form(...),          # ISO datetime
    duration_seconds: int = Form(...),
    notes: str = Form(None),
    video: UploadFile = File(...),
    audio: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Validate measurement_id format
    try:
        uuid.UUID(measurement_id)
    except ValueError:
        raise HTTPException(status_code=422, detail="Invalid measurement_id format")

    video_data = await video.read()
    audio_data = await audio.read()

    if len(video_data) > 200 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Video exceeds 200MB limit")

    video_key = f"{current_user.id}/{measurement_id}/video.mp4"
    audio_key = f"{current_user.id}/{measurement_id}/audio.wav"

    storage_service.upload_file(video_key, video_data, "video/mp4")
    storage_service.upload_file(audio_key, audio_data, "audio/wav")

    m = Measurement(
        id=measurement_id,
        user_id=current_user.id,
        recorded_at=datetime.fromisoformat(recorded_at),
        duration_seconds=duration_seconds,
        video_path=video_key,
        audio_path=audio_key,
        questions_used=questions_used,
        question_timings=question_timings,
        uploaded=True,
        notes=notes,
    )
    db.add(m)
    current_user.total_measurements += 1
    await db.commit()

    background_tasks.add_task(
        ml_client.trigger_analysis, measurement_id, video_key, audio_key
    )

    return {"measurement_id": measurement_id, "status": "processing"}


@router.get("/", response_model=list[MeasurementSummary])
async def list_measurements(
    limit: int = 20,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Measurement)
        .where(Measurement.user_id == current_user.id)
        .order_by(desc(Measurement.recorded_at))
        .limit(limit)
        .offset(offset)
    )
    measurements = result.scalars().all()

    summaries = []
    for m in measurements:
        score_result = await db.execute(
            select(MeasurementScore).where(MeasurementScore.measurement_id == m.id)
        )
        score = score_result.scalar_one_or_none()
        summaries.append(MeasurementSummary(
            id=m.id,
            recorded_at=m.recorded_at,
            duration_seconds=m.duration_seconds,
            analyzed=m.analyzed,
            composite_zscore=score.composite_zscore if score else None,
            flags=json.loads(score.flags) if score and score.flags else [],
            trend_7d=score.trend_7d if score else None,
        ))

    return summaries


@router.get("/{measurement_id}", response_model=MeasurementDetail)
async def get_measurement(
    measurement_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Measurement).where(
            Measurement.id == measurement_id,
            Measurement.user_id == current_user.id,
        )
    )
    m = result.scalar_one_or_none()
    if not m:
        raise HTTPException(status_code=404, detail="Measurement not found")

    score_result = await db.execute(
        select(MeasurementScore).where(MeasurementScore.measurement_id == m.id)
    )
    score = score_result.scalar_one_or_none()

    scores_dict = None
    if score:
        scores_dict = {
            "speech_rate_zscore": score.speech_rate_zscore,
            "pause_ratio_zscore": score.pause_ratio_zscore,
            "voice_energy_zscore": score.voice_energy_zscore,
            "f0_range_zscore": score.f0_range_zscore,
            "response_length_zscore": score.response_length_zscore,
            "cohesion_zscore": score.cohesion_zscore,
            "facial_affect_zscore": score.facial_affect_zscore,
            "composite_zscore": score.composite_zscore,
        }

    return MeasurementDetail(
        id=m.id,
        recorded_at=m.recorded_at,
        duration_seconds=m.duration_seconds,
        questions_used=json.loads(m.questions_used),
        analyzed=m.analyzed,
        speaker_verified=m.speaker_verified,
        speaker_similarity=m.speaker_similarity,
        notes=m.notes,
        scores=scores_dict,
        per_question=json.loads(score.per_question) if score and score.per_question else None,
        energy_profile=json.loads(score.energy_profile) if score and score.energy_profile else None,
        flags=json.loads(score.flags) if score and score.flags else [],
        baseline={
            "composite_mean": score.baseline_mean,
            "composite_std": score.baseline_std,
            "deviation_sigma": round((score.composite_zscore or 0), 2),
            "based_on_n": score.baseline_n,
        } if score else None,
        trend_7d=score.trend_7d if score else None,
    )


@router.delete("/{measurement_id}", status_code=204)
async def delete_measurement(
    measurement_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Measurement).where(
            Measurement.id == measurement_id,
            Measurement.user_id == current_user.id,
        )
    )
    m = result.scalar_one_or_none()
    if not m:
        raise HTTPException(status_code=404, detail="Measurement not found")

    if m.video_path:
        storage_service.delete_object(m.video_path)
    if m.audio_path:
        storage_service.delete_object(m.audio_path)

    score_result = await db.execute(
        select(MeasurementScore).where(MeasurementScore.measurement_id == m.id)
    )
    score = score_result.scalar_one_or_none()
    if score:
        await db.delete(score)

    await db.delete(m)
    await db.commit()
