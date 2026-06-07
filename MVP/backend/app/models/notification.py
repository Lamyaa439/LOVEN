from app.extensions import db
from sqlalchemy.dialects.postgresql import UUID
import uuid


# =========================================================
# Model: Notification
# =========================================================
# In-app notifications delivered to a user (welcome, orders,
# feedback confirmations, cart/order reminders).
#
# Relationships:
# - Belongs to one user (users table)
#
# reference_id and reference_type optionally link to related
# entities (order, cart, feedback) without polymorphic FKs.
#
# IMPORTANT:
# This model intentionally DOES NOT inherit from BaseModel.
#
# Reason:
# The official schema does not include deleted_at for
# notifications. Rows are user-owned and removed via
# ON DELETE CASCADE when the user is hard-deleted.
# =========================================================


class Notification(db.Model):

    __tablename__ = "notifications"

    # =====================================================
    # Primary Key
    # =====================================================

    id = db.Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    # =====================================================
    # Recipient
    # =====================================================

    user_id = db.Column(
        UUID(as_uuid=True),
        db.ForeignKey(
            "users.id",
            ondelete="CASCADE",
        ),
        nullable=False,
    )

    # =====================================================
    # Notification Content
    # =====================================================

    type = db.Column(
        "type",
        db.String(100),
        nullable=False,
    )

    title = db.Column(
        db.String(255),
        nullable=False,
    )

    body = db.Column(
        db.Text,
        nullable=False,
    )

    # =====================================================
    # Optional Entity Reference (polymorphic, no FK)
    # =====================================================

    reference_id = db.Column(
        UUID(as_uuid=True),
        nullable=True,
    )

    reference_type = db.Column(
        db.String(50),
        nullable=True,
    )

    # =====================================================
    # Read State
    # =====================================================

    is_read = db.Column(
        db.Boolean,
        nullable=False,
        default=False,
        server_default=db.text("false"),
    )

    # =====================================================
    # Audit Timestamps
    # =====================================================

    created_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp(),
    )

    updated_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp(),
        onupdate=db.func.current_timestamp(),
    )

    # =====================================================
    # Serialization Helper
    # =====================================================

    def to_dict(self):
        """
        Convert Notification into an API-friendly dictionary.

        Returns:
            dict: Serializable notification payload for the in-app
            notifications list, mark-as-read updates, and deep links
            via reference_id / reference_type.
        """

        return {
            "id": str(self.id) if self.id else None,
            "user_id": (
                str(self.user_id)
                if self.user_id
                else None
            ),
            "type": self.type,
            "title": self.title,
            "body": self.body,
            "reference_id": (
                str(self.reference_id)
                if self.reference_id
                else None
            ),
            "reference_type": self.reference_type,
            "is_read": self.is_read,
            "created_at": (
                self.created_at.isoformat()
                if self.created_at
                else None
            ),
            "updated_at": (
                self.updated_at.isoformat()
                if self.updated_at
                else None
            ),
        }
