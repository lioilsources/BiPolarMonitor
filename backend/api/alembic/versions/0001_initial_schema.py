"""Initial schema

Revision ID: 0001
Revises:
Create Date: 2026-05-07
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("email", sa.String, nullable=False, unique=True),
        sa.Column("display_name", sa.String, nullable=False),
        sa.Column("hashed_password", sa.String, nullable=False),
        sa.Column("speaker_embedding", sa.Text, nullable=True),
        sa.Column("total_measurements", sa.Integer, default=0),
        sa.Column("created_at", sa.DateTime, nullable=False),
        sa.Column("enrolled_at", sa.DateTime, nullable=True),
    )
    op.create_index("ix_users_email", "users", ["email"])

    op.create_table(
        "refresh_tokens",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("user_id", sa.String, nullable=False),
        sa.Column("token_hash", sa.String, nullable=False),
        sa.Column("expires_at", sa.DateTime, nullable=False),
        sa.Column("created_at", sa.DateTime, nullable=False),
    )
    op.create_index("ix_refresh_tokens_user_id", "refresh_tokens", ["user_id"])

    op.create_table(
        "user_baselines",
        sa.Column("user_id", sa.String, primary_key=True),
        sa.Column("data", sa.Text, nullable=False),
        sa.Column("based_on_n", sa.Integer, default=0),
        sa.Column("updated_at", sa.DateTime, nullable=False),
    )

    op.create_table(
        "measurements",
        sa.Column("id", sa.String, primary_key=True),
        sa.Column("user_id", sa.String, nullable=False),
        sa.Column("recorded_at", sa.DateTime, nullable=False),
        sa.Column("duration_seconds", sa.Integer, nullable=False),
        sa.Column("video_path", sa.String, nullable=True),
        sa.Column("audio_path", sa.String, nullable=True),
        sa.Column("questions_used", sa.Text, nullable=False),
        sa.Column("question_timings", sa.Text, nullable=True),
        sa.Column("uploaded", sa.Boolean, default=False),
        sa.Column("analyzed", sa.Boolean, default=False),
        sa.Column("speaker_verified", sa.Boolean, nullable=True),
        sa.Column("speaker_similarity", sa.Float, nullable=True),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("created_at", sa.DateTime, nullable=False),
    )
    op.create_index("ix_measurements_user_id", "measurements", ["user_id"])

    op.create_table(
        "measurement_scores",
        sa.Column("measurement_id", sa.String, primary_key=True),
        sa.Column("user_id", sa.String, nullable=False),
        sa.Column("speech_rate_zscore", sa.Float, nullable=True),
        sa.Column("pause_ratio_zscore", sa.Float, nullable=True),
        sa.Column("voice_energy_zscore", sa.Float, nullable=True),
        sa.Column("f0_range_zscore", sa.Float, nullable=True),
        sa.Column("response_length_zscore", sa.Float, nullable=True),
        sa.Column("cohesion_zscore", sa.Float, nullable=True),
        sa.Column("facial_affect_zscore", sa.Float, nullable=True),
        sa.Column("composite_zscore", sa.Float, nullable=True),
        sa.Column("raw_features", sa.Text, nullable=True),
        sa.Column("per_question", sa.Text, nullable=True),
        sa.Column("energy_profile", sa.Text, nullable=True),
        sa.Column("flags", sa.Text, nullable=True),
        sa.Column("trend_7d", sa.String, nullable=True),
        sa.Column("baseline_mean", sa.Float, nullable=True),
        sa.Column("baseline_std", sa.Float, nullable=True),
        sa.Column("baseline_n", sa.Integer, nullable=True),
        sa.Column("analyzed_at", sa.DateTime, nullable=False),
    )
    op.create_index("ix_measurement_scores_user_id", "measurement_scores", ["user_id"])

    # FCM tokens for push notifications
    op.create_table(
        "fcm_tokens",
        sa.Column("user_id", sa.String, primary_key=True),
        sa.Column("token", sa.String, nullable=False),
        sa.Column("updated_at", sa.DateTime, nullable=False),
    )


def downgrade() -> None:
    op.drop_table("fcm_tokens")
    op.drop_table("measurement_scores")
    op.drop_table("measurements")
    op.drop_table("user_baselines")
    op.drop_table("refresh_tokens")
    op.drop_table("users")
