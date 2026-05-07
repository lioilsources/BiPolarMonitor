"""
Tematická soudržnost (Dimension 5) pomocí multilingual sentence embeddings.
"""
from typing import Optional
import numpy as np
from sentence_transformers import SentenceTransformer

_model: Optional[SentenceTransformer] = None
_MODEL_NAME = "paraphrase-multilingual-mpnet-base-v2"

# Dialog questions (for Q-A cohesion scoring)
QUESTION_TEXTS = {
    "Q1A": "Popiš mi, co jsi dělal dnes ráno. Ale začni od druhé věci, co tě napadne.",
    "Q1B": "Co jsi dělal posledních pár hodin? Řekni mi to pozpátku — od teď dozadu.",
    "Q1C": "Kdybys měl popsat dnešní ráno jedním gestem, jakým by bylo? A teď mi ho popiš slovy.",
    "Q2A": "Kdybys byl počasí, jaké by bylo dnes? Ne jaké chceš — jaké skutečně je.",
    "Q2B": "Kdybys byl zvuk, co by teď hrál? Můžeš být cokoliv — hudba, hluk, ticho.",
    "Q2C": "Kdybys byl místnost, jak by teď vypadala? Co by v ní bylo a co by v ní chybělo?",
    "Q3A": "Vyjmenuj pět věcí, které vidíš kolem sebe. Pak řekni, která z nich by přežila požár.",
    "Q3B": "Řekni mi tři barvy, které teď vidíš. A pak — která z nich je nejhlučnější?",
    "Q3C": "Popiš mi povrch nejbližšího předmětu, kterého se dotýkáš. A pak řekni, čemu se podobá.",
    "Q4A": "Co bylo poslední dobou těžké? Nemusí to být nic velkého.",
    "Q4B": "Co tě v posledních dnech překvapilo — příjemně nebo nepříjemně?",
    "Q4C": "Co ti teď leží na mysli, i když o tom nechceš moc přemýšlet?",
    "Q5A": "Řekni mi jednu věc, na kterou se těšíš. Klidně vymyšlenou.",
    "Q5B": "Co by byl dobrý den? Nemusí být reálný — prostě dobrý.",
    "Q5C": "Kdyby zítra bylo jiné než dnes — v čem by to bylo?",
}


def _get_model() -> SentenceTransformer:
    global _model
    if _model is None:
        _model = SentenceTransformer(_MODEL_NAME)
    return _model


def _cosine_similarity(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b) + 1e-8))


def qa_cohesion(question_key: str, answer_text: str) -> float:
    """Cosine similarity between question and answer embeddings."""
    if not answer_text.strip():
        return 0.0
    model = _get_model()
    question_text = QUESTION_TEXTS.get(question_key, "")
    if not question_text:
        return 0.5
    q_emb, a_emb = model.encode([question_text, answer_text])
    return round(_cosine_similarity(q_emb, a_emb), 4)


def internal_cohesion(text: str, language: str = "czech") -> float:
    """Average cosine similarity between consecutive sentences."""
    try:
        from nltk.tokenize import sent_tokenize
        sentences = sent_tokenize(text, language=language)
    except Exception:
        sentences = [s.strip() for s in text.split(".") if s.strip()]

    if len(sentences) < 2:
        return 1.0

    model = _get_model()
    embeddings = model.encode(sentences)
    sims = [
        _cosine_similarity(embeddings[i], embeddings[i + 1])
        for i in range(len(embeddings) - 1)
    ]
    return round(float(np.mean(sims)), 4)


def analyze_cohesion(per_question: dict, questions_used: list[str]) -> dict:
    """
    per_question: {"Q1": {"text": "..."}, ...}
    questions_used: ["Q1B", "Q2A", ...]
    """
    qa_scores = {}
    internal_scores = {}

    q_key_map = {q[:2]: q for q in questions_used}  # "Q1" -> "Q1B"

    for q_id, data in per_question.items():
        text = data.get("text", "")
        question_key = q_key_map.get(q_id, "")
        qa_scores[q_id] = qa_cohesion(question_key, text)
        internal_scores[q_id] = internal_cohesion(text)

    mean_qa = float(np.mean(list(qa_scores.values()))) if qa_scores else 0.5
    mean_internal = float(np.mean(list(internal_scores.values()))) if internal_scores else 0.5

    flags = []
    for q_id, score in qa_scores.items():
        if score < 0.35:
            flags.append(f"topic_drift_{q_id}")

    # Detect flight of ideas: high speech rate + low internal cohesion
    # (checked in scoring.py with cross-signal logic)

    return {
        "qa_cohesion_per_q": qa_scores,
        "internal_cohesion_per_q": internal_scores,
        "cohesion_mean": round(mean_qa, 4),
        "internal_cohesion_mean": round(mean_internal, 4),
        "flags": flags,
    }
