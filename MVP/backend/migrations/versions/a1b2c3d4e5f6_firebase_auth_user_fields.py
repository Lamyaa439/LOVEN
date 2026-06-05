"""Firebase auth user fields for LOVEN MVP.

Revision ID: a1b2c3d4e5f6
Revises:
Create Date: 2026-06-02

Adds Firebase Authentication linkage columns and makes ``users.password``
nullable for Firebase-owned credentials.
"""

from alembic import op
import sqlalchemy as sa


revision = "a1b2c3d4e5f6"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "users",
        sa.Column("firebase_uid", sa.String(length=128), nullable=True),
    )
    op.create_index(
        op.f("ix_users_firebase_uid"),
        "users",
        ["firebase_uid"],
        unique=True,
    )
    op.add_column(
        "users",
        sa.Column("email_verified_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.add_column(
        "users",
        sa.Column(
            "auth_provider",
            sa.String(length=32),
            nullable=False,
            server_default="firebase",
        ),
    )
    op.alter_column(
        "users",
        "password",
        existing_type=sa.String(length=255),
        nullable=True,
    )


def downgrade():
    op.alter_column(
        "users",
        "password",
        existing_type=sa.String(length=255),
        nullable=False,
    )
    op.drop_column("users", "auth_provider")
    op.drop_column("users", "email_verified_at")
    op.drop_index(op.f("ix_users_firebase_uid"), table_name="users")
    op.drop_column("users", "firebase_uid")
