"""
FCM push notifications via Firebase Admin SDK.
Requires GOOGLE_APPLICATION_CREDENTIALS env var pointing to service account JSON.
"""
import os
import json
import logging
from typing import Optional

logger = logging.getLogger(__name__)

_app = None


def _get_app():
    global _app
    if _app is None:
        try:
            import firebase_admin
            from firebase_admin import credentials
            cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
            if cred_path and os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                _app = firebase_admin.initialize_app(cred)
            else:
                logger.warning("FCM: GOOGLE_APPLICATION_CREDENTIALS not set — push notifications disabled")
        except Exception as e:
            logger.error(f"FCM init failed: {e}")
    return _app


async def send_analysis_complete(
    fcm_token: str,
    measurement_id: str,
    composite_zscore: Optional[float],
    flags: list[str],
) -> bool:
    app = _get_app()
    if app is None:
        return False

    try:
        from firebase_admin import messaging

        # User-facing message (neutral, no diagnostic framing)
        body = _compose_body(composite_zscore, flags)

        message = messaging.Message(
            notification=messaging.Notification(
                title="Analýza dokončena",
                body=body,
            ),
            data={
                "type": "analysis_complete",
                "measurement_id": measurement_id,
                "composite_zscore": str(round(composite_zscore or 0, 2)),
            },
            android=messaging.AndroidConfig(priority="normal"),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound=None)  # no sound
                )
            ),
            token=fcm_token,
        )
        messaging.send(message)
        return True
    except Exception as e:
        logger.error(f"FCM send failed: {e}")
        return False


async def send_deviation_alert(fcm_token: str, measurement_id: str, sigma: float) -> bool:
    app = _get_app()
    if app is None:
        return False

    try:
        from firebase_admin import messaging
        message = messaging.Message(
            notification=messaging.Notification(
                title="Tvůj projev se dnes liší",
                body="Dnešní záznam se výrazněji liší od tvého průměru.",
            ),
            data={
                "type": "deviation_alert",
                "measurement_id": measurement_id,
                "sigma": str(round(sigma, 2)),
            },
            token=fcm_token,
        )
        messaging.send(message)
        return True
    except Exception as e:
        logger.error(f"FCM deviation alert failed: {e}")
        return False


def _compose_body(zscore: Optional[float], flags: list[str]) -> str:
    if zscore is None:
        return "Podívej se na výsledky svého záznamu."

    flag_messages = {
        "elevated_speech_rate": "Mluvil jsi rychleji než obvykle.",
        "suppressed_speech_rate": "Mluvil jsi pomaleji než obvykle.",
        "monotone_voice": "Hlas byl dnes klidnější.",
        "low_energy_profile": "Klidnější den.",
        "flight_of_ideas": "Hodně myšlenek najednou.",
    }
    visible = [f for f in flags if f != "emotional_avoidance"]
    if visible:
        msg = flag_messages.get(visible[0], "Zajímavý záznam.")
        return f"{msg} Otevři app pro detail."
    return "Záznam byl zpracován. Otevři app pro výsledky."
