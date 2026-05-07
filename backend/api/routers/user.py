import json
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from middleware.auth_middleware import get_current_user
from models.user import User

router = APIRouter(prefix="/user", tags=["user"])


class ProfileResponse(BaseModel):
    id: str
    email: str
    display_name: str
    total_measurements: int
    has_speaker_embedding: bool
    enrolled_at: str | None


class ProfileUpdate(BaseModel):
    display_name: str | None = None


class SpeakerEnrollmentRequest(BaseModel):
    embedding: list[float]  # Speaker embedding vector from enrollment audio


@router.get("/profile", response_model=ProfileResponse)
async def get_profile(current_user: User = Depends(get_current_user)):
    return ProfileResponse(
        id=current_user.id,
        email=current_user.email,
        display_name=current_user.display_name,
        total_measurements=current_user.total_measurements,
        has_speaker_embedding=current_user.speaker_embedding is not None,
        enrolled_at=current_user.enrolled_at.isoformat() if current_user.enrolled_at else None,
    )


@router.put("/profile", response_model=ProfileResponse)
async def update_profile(
    body: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if body.display_name:
        current_user.display_name = body.display_name
    await db.commit()
    await db.refresh(current_user)
    return await get_profile(current_user)


@router.post("/enroll-speaker", status_code=200)
async def enroll_speaker(
    body: SpeakerEnrollmentRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Store speaker embedding from enrollment (computed on-device or by ML service)."""
    from datetime import datetime
    current_user.speaker_embedding = json.dumps(body.embedding)
    current_user.enrolled_at = datetime.utcnow()
    await db.commit()
    return {"enrolled": True}


@router.delete("/data", status_code=204)
async def delete_all_data(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """GDPR: delete all user data immediately."""
    from sqlalchemy import delete as sql_delete, text
    from models.measurement import Measurement, MeasurementScore
    from models.user import RefreshToken, UserBaseline
    from services import storage_service

    # Delete all media
    measurements = await db.execute(
        sql_delete(Measurement).where(Measurement.user_id == current_user.id).returning(
            Measurement.video_path, Measurement.audio_path
        )
    )
    for video_path, audio_path in measurements.fetchall():
        if video_path:
            storage_service.delete_object(video_path)
        if audio_path:
            storage_service.delete_object(audio_path)

    await db.execute(
        sql_delete(RefreshToken).where(RefreshToken.user_id == current_user.id)
    )
    await db.execute(
        sql_delete(UserBaseline).where(UserBaseline.user_id == current_user.id)
    )
    await db.delete(current_user)
    await db.commit()
