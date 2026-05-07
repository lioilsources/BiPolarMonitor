"""
Media retention cleanup — called by the API on startup via background scheduler.
Deletes MinIO objects for measurements older than MEDIA_RETENTION_DAYS
where analysis is already complete.
"""
import asyncio
import logging
from datetime import datetime, timedelta

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from config import settings
from services import storage_service

logger = logging.getLogger(__name__)


async def cleanup_old_media(db: AsyncSession) -> int:
    cutoff = datetime.utcnow() - timedelta(days=settings.media_retention_days)

    result = await db.execute(
        text("""
            SELECT id, video_path, audio_path
            FROM measurements
            WHERE analyzed = TRUE
              AND created_at < :cutoff
              AND (video_path IS NOT NULL OR audio_path IS NOT NULL)
            LIMIT 100
        """),
        {"cutoff": cutoff},
    )
    rows = result.fetchall()
    deleted = 0

    for row in rows:
        if row.video_path:
            storage_service.delete_object(row.video_path)
        if row.audio_path:
            storage_service.delete_object(row.audio_path)

        await db.execute(
            text("UPDATE measurements SET video_path=NULL, audio_path=NULL WHERE id=:id"),
            {"id": row.id},
        )
        deleted += 1

    if deleted:
        await db.commit()
        logger.info(f"Retention cleanup: removed media for {deleted} measurements (cutoff: {cutoff.date()})")

    return deleted


async def run_retention_loop(session_factory) -> None:
    """Background task that runs cleanup daily."""
    while True:
        await asyncio.sleep(24 * 3600)
        async with session_factory() as db:
            try:
                await cleanup_old_media(db)
            except Exception as e:
                logger.error(f"Retention cleanup error: {e}")
