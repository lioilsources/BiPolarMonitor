"""FCM token registration + internal webhook from ML service."""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from middleware.auth_middleware import get_current_user
from models.user import User
from services import fcm_service

router = APIRouter(prefix="/push", tags=["push"])

_ML_SECRET = None  # set via env ML_WEBHOOK_SECRET


class RegisterTokenRequest(BaseModel):
    fcm_token: str


class AnalysisWebhookPayload(BaseModel):
    measurement_id: str
    user_id: str
    composite_zscore: float | None
    flags: list[str]
    secret: str  # shared secret between API and ML service


@router.post("/register-token", status_code=200)
async def register_token(
    body: RegisterTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await db.execute(
        text("""
            INSERT INTO fcm_tokens (user_id, token, updated_at)
            VALUES (:uid, :tok, :ts)
            ON CONFLICT (user_id) DO UPDATE SET token=:tok, updated_at=:ts
        """),
        {"uid": current_user.id, "tok": body.fcm_token, "ts": datetime.utcnow()},
    )
    await db.commit()
    return {"registered": True}


@router.post("/analysis-complete", status_code=200, include_in_schema=False)
async def analysis_webhook(body: AnalysisWebhookPayload, db: AsyncSession = Depends(get_db)):
    """Called by ML service after pipeline completes. Not exposed publicly."""
    import os
    expected_secret = os.environ.get("ML_WEBHOOK_SECRET", "")
    if expected_secret and body.secret != expected_secret:
        raise HTTPException(status_code=403)

    # Get FCM token for user
    row = await db.execute(
        text("SELECT token FROM fcm_tokens WHERE user_id = :uid"),
        {"uid": body.user_id},
    )
    token_row = row.fetchone()
    if not token_row:
        return {"sent": False, "reason": "no_token"}

    sent = await fcm_service.send_analysis_complete(
        fcm_token=token_row.token,
        measurement_id=body.measurement_id,
        composite_zscore=body.composite_zscore,
        flags=body.flags,
    )

    # Send deviation alert if > 2.5σ
    if body.composite_zscore and abs(body.composite_zscore) > 2.5:
        await fcm_service.send_deviation_alert(
            fcm_token=token_row.token,
            measurement_id=body.measurement_id,
            sigma=body.composite_zscore,
        )

    return {"sent": sent}
