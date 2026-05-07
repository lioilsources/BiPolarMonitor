"""
Dialog prompt rotation — BladeRunner/Voigt-Kampff style.
Returns the next set of 5 questions (one per dimension) for a recording session.
"""
import json
from datetime import datetime, timedelta
from typing import Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from database import get_db
from middleware.auth_middleware import get_current_user
from models.user import User

router = APIRouter(prefix="/dialog", tags=["dialog"])

# Full question bank from BIPOLAR_DIALOG_PROTOCOL.md
QUESTIONS = {
    "Q1": {
        "dimension": "orientation",
        "description": "Orientace v přítomnosti",
        "variants": {
            "A": "Popiš mi, co jsi dělal dnes ráno. Ale začni od druhé věci, co tě napadne.",
            "B": "Co jsi dělal posledních pár hodin? Řekni mi to pozpátku — od teď dozadu.",
            "C": "Kdybys měl popsat dnešní ráno jedním gestem, jakým by bylo? A teď mi ho popiš slovy.",
        },
    },
    "Q2": {
        "dimension": "abstraction",
        "description": "Abstraktní asociace",
        "variants": {
            "A": "Kdybys byl počasí, jaké by bylo dnes? Ne jaké chceš — jaké skutečně je.",
            "B": "Kdybys byl zvuk, co by teď hrál? Můžeš být cokoliv — hudba, hluk, ticho.",
            "C": "Kdybys byl místnost, jak by teď vypadala? Co by v ní bylo a co by v ní chybělo?",
        },
    },
    "Q3": {
        "dimension": "cognitive",
        "description": "Kognitivní zátěž",
        "variants": {
            "A": "Vyjmenuj pět věcí, které vidíš kolem sebe. Pak řekni, která z nich by přežila požár.",
            "B": "Řekni mi tři barvy, které teď vidíš. A pak — která z nich je nejhlučnější?",
            "C": "Popiš mi povrch nejbližšího předmětu, kterého se dotýkáš. A pak řekni, čemu se podobá.",
        },
    },
    "Q4": {
        "dimension": "valence",
        "description": "Emoční valence",
        "variants": {
            "A": "Co bylo poslední dobou těžké? Nemusí to být nic velkého.",
            "B": "Co tě v posledních dnech překvapilo — příjemně nebo nepříjemně?",
            "C": "Co ti teď leží na mysli, i když o tom nechceš moc přemýšlet?",
        },
    },
    "Q5": {
        "dimension": "future",
        "description": "Uzavření a budoucnost",
        "variants": {
            "A": "Řekni mi jednu věc, na kterou se těšíš. Klidně vymyšlenou.",
            "B": "Co by byl dobrý den? Nemusí být reálný — prostě dobrý.",
            "C": "Kdyby zítra bylo jiné než dnes — v čem by to bylo?",
        },
    },
}

# Q4 minimum gap: 21 days; same combo gap: 60 days
Q4_MIN_GAP_DAYS = 21
COMBO_MIN_GAP_DAYS = 60


class DialogPrompt(BaseModel):
    question_id: str
    variant: str
    dimension: str
    text: str


class DialogSession(BaseModel):
    session_id: str
    questions: list[DialogPrompt]
    # Timing guidance (seconds) — app uses these as soft limits
    suggested_duration_per_question: int = 30


@router.get("/next", response_model=DialogSession)
async def get_next_dialog(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return next optimally-rotated set of 5 questions for the user."""
    history = await _load_dialog_history(current_user.id, db)
    chosen = _pick_variants(history)
    import uuid
    return DialogSession(
        session_id=str(uuid.uuid4()),
        questions=[
            DialogPrompt(
                question_id=q_id,
                variant=variant,
                dimension=QUESTIONS[q_id]["dimension"],
                text=QUESTIONS[q_id]["variants"][variant],
            )
            for q_id, variant in chosen.items()
        ],
    )


async def _load_dialog_history(user_id: str, db: AsyncSession) -> dict:
    """Load when each Q/variant was last used from measurements table."""
    result = await db.execute(
        text("""
            SELECT questions_used, created_at
            FROM measurements
            WHERE user_id = :uid
            ORDER BY created_at DESC
            LIMIT 100
        """),
        {"uid": user_id},
    )
    rows = result.fetchall()

    # last_used[q_id][variant] = datetime
    last_used: dict[str, dict[str, Optional[datetime]]] = {
        q: {v: None for v in ["A", "B", "C"]} for q in QUESTIONS
    }
    combos_used: list[tuple[str, datetime]] = []

    for row in rows:
        try:
            questions = json.loads(row.questions_used)  # e.g. ["Q1B","Q2A","Q3C","Q4A","Q5B"]
            ts = row.created_at
            combo_key = "".join(questions)
            combos_used.append((combo_key, ts))
            for qv in questions:
                q_id, variant = qv[:2], qv[2]
                if q_id in last_used and variant in last_used[q_id]:
                    if last_used[q_id][variant] is None or ts > last_used[q_id][variant]:
                        last_used[q_id][variant] = ts
        except Exception:
            continue

    return {"last_used": last_used, "combos": combos_used}


def _pick_variants(history: dict) -> dict[str, str]:
    last_used = history["last_used"]
    combos = history["combos"]
    now = datetime.utcnow()

    chosen: dict[str, str] = {}
    for q_id in ["Q1", "Q2", "Q3", "Q4", "Q5"]:
        variants = ["A", "B", "C"]

        if q_id == "Q4":
            # Q4 must not repeat same variant within 21 days
            valid = [
                v for v in variants
                if last_used[q_id][v] is None
                or (now - last_used[q_id][v]).days >= Q4_MIN_GAP_DAYS
            ]
            if not valid:
                valid = variants  # fallback: pick least-recently-used

        else:
            valid = variants

        # Pick least-recently-used among valid
        def sort_key(v):
            t = last_used[q_id][v]
            return t if t is not None else datetime.min

        chosen[q_id] = min(valid, key=sort_key)

    return chosen
