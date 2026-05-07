import uuid
from datetime import datetime
from sqlalchemy import String, DateTime, Integer, Float, Text, Boolean, JSON
from sqlalchemy.orm import Mapped, mapped_column
from database import Base


class Measurement(Base):
    __tablename__ = "measurements"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String, nullable=False, index=True)
    recorded_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    duration_seconds: Mapped[int] = mapped_column(Integer, nullable=False)

    # Storage paths
    video_path: Mapped[str | None] = mapped_column(String, nullable=True)  # MinIO object key
    audio_path: Mapped[str | None] = mapped_column(String, nullable=True)

    # Dialog metadata
    questions_used: Mapped[str] = mapped_column(Text, nullable=False)  # JSON: ["Q1B","Q2A",...]
    question_timings: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON: {Q1: {start, end}}

    # State
    uploaded: Mapped[bool] = mapped_column(Boolean, default=False)
    analyzed: Mapped[bool] = mapped_column(Boolean, default=False)
    speaker_verified: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    speaker_similarity: Mapped[float | None] = mapped_column(Float, nullable=True)
    face_verified: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    face_similarity: Mapped[float | None] = mapped_column(Float, nullable=True)

    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class MeasurementScore(Base):
    __tablename__ = "measurement_scores"

    measurement_id: Mapped[str] = mapped_column(String, primary_key=True)
    user_id: Mapped[str] = mapped_column(String, nullable=False, index=True)

    # Z-scores (relative to user baseline)
    speech_rate_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)
    pause_ratio_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)
    voice_energy_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)
    f0_range_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)
    response_length_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)
    cohesion_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)
    facial_affect_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)
    composite_zscore: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Raw features (stored as JSON)
    raw_features: Mapped[str | None] = mapped_column(Text, nullable=True)
    per_question: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON per-Q breakdown
    energy_profile: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Flags & context
    flags: Mapped[str | None] = mapped_column(Text, nullable=True)  # JSON array
    trend_7d: Mapped[str | None] = mapped_column(String, nullable=True)
    baseline_mean: Mapped[float | None] = mapped_column(Float, nullable=True)
    baseline_std: Mapped[float | None] = mapped_column(Float, nullable=True)
    baseline_n: Mapped[int | None] = mapped_column(Integer, nullable=True)

    analyzed_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
