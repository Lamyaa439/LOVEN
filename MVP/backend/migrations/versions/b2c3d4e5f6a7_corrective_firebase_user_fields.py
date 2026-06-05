"""Corrective Firebase auth columns for drifted databases.

Revision ID: b2c3d4e5f6a7
Revises: a1b2c3d4e5f6
Create Date: 2026-06-02

Some databases were stamped at ``a1b2c3d4e5f6`` without the Firebase columns
ever being applied. This migration adds missing ``users`` columns and indexes
only when absent — safe to run on databases that already have them.
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = "b2c3d4e5f6a7"
down_revision = "a1b2c3d4e5f6"
branch_labels = None
depends_on = None

FIREBASE_UID_INDEX = "ix_users_firebase_uid"


def _users_columns(bind) -> set[str]:
    return {column["name"] for column in inspect(bind).get_columns("users")}


def _users_indexes(bind) -> set[str]:
    return {index["name"] for index in inspect(bind).get_indexes("users")}


def _password_is_nullable(bind) -> bool:
    for column in inspect(bind).get_columns("users"):
        if column["name"] == "password":
            return bool(column.get("nullable"))
    return True


def apply_firebase_user_field_corrections(bind) -> None:
    """
    Idempotent schema repair for Firebase auth columns on ``users``.

    Intended for databases stamped at head but missing columns from
    ``a1b2c3d4e5f6``. Safe to run multiple times.
    """
    columns = _users_columns(bind)
    indexes = _users_indexes(bind)

    if "firebase_uid" not in columns:
        op.add_column(
            "users",
            sa.Column("firebase_uid", sa.String(length=128), nullable=True),
        )
        columns.add("firebase_uid")

    if FIREBASE_UID_INDEX not in indexes and "firebase_uid" in columns:
        op.create_index(
            FIREBASE_UID_INDEX,
            "users",
            ["firebase_uid"],
            unique=True,
        )
        indexes.add(FIREBASE_UID_INDEX)

    if "email_verified_at" not in columns:
        op.add_column(
            "users",
            sa.Column("email_verified_at", sa.DateTime(timezone=True), nullable=True),
        )
        columns.add("email_verified_at")

    if "auth_provider" not in columns:
        op.add_column(
            "users",
            sa.Column(
                "auth_provider",
                sa.String(length=32),
                nullable=False,
                server_default="firebase",
            ),
        )
        columns.add("auth_provider")

    if bind.dialect.name == "postgresql" and not _password_is_nullable(bind):
        op.alter_column(
            "users",
            "password",
            existing_type=sa.String(length=255),
            nullable=True,
        )


def upgrade():
    bind = op.get_bind()
    apply_firebase_user_field_corrections(bind)


def downgrade():
    bind = op.get_bind()
    columns = _users_columns(bind)
    indexes = _users_indexes(bind)

    if "auth_provider" in columns:
        op.drop_column("users", "auth_provider")

    if "email_verified_at" in columns:
        op.drop_column("users", "email_verified_at")

    if FIREBASE_UID_INDEX in indexes:
        op.drop_index(FIREBASE_UID_INDEX, table_name="users")

    if "firebase_uid" in columns:
        op.drop_column("users", "firebase_uid")

    if bind.dialect.name == "postgresql" and _password_is_nullable(bind):
        op.alter_column(
            "users",
            "password",
            existing_type=sa.String(length=255),
            nullable=False,
        )
