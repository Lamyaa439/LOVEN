from app.extensions import db
from sqlalchemy.dialects.postgresql import UUID

from app.models.base_model import BaseModel


# =========================================================
# Model: Feedback
# =========================================================
# Stores user suggestions and platform feedback.
#
# Feedback records inherit shared audit fields from
# BaseModel so timestamps and soft-delete behavior stay
# consistent across the application.
# =========================================================


class Feedback(BaseModel):

    __tablename__ = "feedback"

    user_id = db.Column(
        UUID(as_uuid=True),
        db.ForeignKey(
            "users.id",
            ondelete="CASCADE"
        ),
        nullable=False
    )

    subject = db.Column(
        db.String(255),
        nullable=True
    )

    message = db.Column(
        db.Text,
        nullable=False
    )

    def to_dict(self):

        return {
            "id": str(self.id) if self.id else None,
            "user_id": (
                str(self.user_id)
                if self.user_id
                else None
            ),
            "subject": self.subject,
            "message": self.message,
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