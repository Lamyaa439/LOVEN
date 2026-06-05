"""
Tests for the corrective Firebase user-fields migration.

Uses an in-memory SQLite database and Alembic Operations so no PostgreSQL
or Flask app context is required.
"""

import importlib
import unittest
from unittest.mock import patch

from alembic.migration import MigrationContext
from alembic.operations import Operations
from sqlalchemy import create_engine, inspect, text


MIGRATION_MODULE = (
    "migrations.versions.b2c3d4e5f6a7_corrective_firebase_user_fields"
)


class CorrectiveFirebaseMigrationTestCase(unittest.TestCase):
    """Idempotent upgrade expectations for drifted users tables."""

    def setUp(self):
        self.engine = create_engine("sqlite:///:memory:")
        with self.engine.begin() as connection:
            connection.execute(
                text(
                    """
                    CREATE TABLE users (
                        id TEXT PRIMARY KEY,
                        name TEXT NOT NULL,
                        email TEXT NOT NULL UNIQUE,
                        password TEXT NOT NULL,
                        system_role TEXT DEFAULT 'customer',
                        fcm_token TEXT,
                        profile_image_url TEXT,
                        is_active INTEGER DEFAULT 1,
                        created_at TEXT NOT NULL,
                        updated_at TEXT NOT NULL,
                        deleted_at TEXT
                    )
                    """
                )
            )

        self.migration = importlib.import_module(MIGRATION_MODULE)

    def _run_upgrade(self):
        with self.engine.begin() as connection:
            context = MigrationContext.configure(connection)
            operations = Operations(context)
            with patch.object(self.migration, "op", operations):
                self.migration.upgrade()

    def _column_names(self):
        with self.engine.connect() as connection:
            return {column["name"] for column in inspect(connection).get_columns("users")}

    def _index_names(self):
        with self.engine.connect() as connection:
            return {index["name"] for index in inspect(connection).get_indexes("users")}

    def test_upgrade_adds_firebase_columns_and_index(self):
        self._run_upgrade()

        columns = self._column_names()
        self.assertIn("firebase_uid", columns)
        self.assertIn("auth_provider", columns)
        self.assertIn("email_verified_at", columns)
        self.assertIn("ix_users_firebase_uid", self._index_names())

    def test_upgrade_is_idempotent(self):
        self._run_upgrade()
        first_columns = self._column_names()
        first_indexes = self._index_names()

        self._run_upgrade()

        self.assertEqual(first_columns, self._column_names())
        self.assertEqual(first_indexes, self._index_names())

    def test_apply_helper_skips_existing_columns(self):
        with self.engine.begin() as connection:
            connection.execute(
                text("ALTER TABLE users ADD COLUMN firebase_uid TEXT")
            )

        with self.engine.connect() as connection:
            bind = connection
            columns_before = self.migration._users_columns(bind)

        self._run_upgrade()

        with self.engine.connect() as connection:
            bind = connection
            columns_after = self.migration._users_columns(bind)

        self.assertIn("firebase_uid", columns_before)
        self.assertIn("auth_provider", columns_after)
        self.assertIn("email_verified_at", columns_after)


if __name__ == "__main__":
    unittest.main()
