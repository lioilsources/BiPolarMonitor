import httpx
from config import settings


async def trigger_analysis(measurement_id: str, video_path: str, audio_path: str) -> bool:
    """Fire-and-forget async trigger to ML service."""
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.post(
                f"{settings.ml_service_url}/analyze",
                json={
                    "measurement_id": measurement_id,
                    "video_path": video_path,
                    "audio_path": audio_path,
                },
            )
            return resp.status_code == 202
    except Exception:
        return False
