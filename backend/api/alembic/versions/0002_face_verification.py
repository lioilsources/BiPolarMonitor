"""Add face verification columns

Revision ID: 0002
Revises: 0001
Create Date: 2026-05-07
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "0002"
down_revision: Union[str, None] = "0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("face_embedding", sa.Text, nullable=True))
    op.add_column("measurements", sa.Column("face_verified", sa.Boolean, nullable=True))
    op.add_column("measurements", sa.Column("face_similarity", sa.Float, nullable=True))


def downgrade() -> None:
    op.drop_column("measurements", "face_similarity")
    op.drop_column("measurements", "face_verified")
    op.drop_column("users", "face_embedding")
