from app.extensions import db
from sqlalchemy.dialects.postgresql import UUID

from app.models.base_model import BaseModel


# =========================================================
# Model: VerificationRequest
# =========================================================
# Stores artist verification submissions.
#
# Each request belongs to an artist profile and keeps the
# submitted institutional/document information needed for
# review. The status field tracks the review lifecycle.
# =========================================================


class VerificationRequest(BaseModel):

    __tablename__ = "verification_requests"

    artist_profile_id = db.Column(
        UUID(as_uuid=True),
        db.ForeignKey(
            "artist_profiles.id",
            ondelete="CASCADE"
        ),
        nullable=False
    )

    document_type = db.Column(
        db.String(50),
        nullable=True
    )

    institution_name = db.Column(
        db.String(255),
        nullable=True
    )

    document_number = db.Column(
        db.String(100),
        nullable=True
    )

    status = db.Column(
        db.String(50),
        default="pending",
        nullable=True
    )

    def to_dict(self):

        return {
            "id": str(self.id) if self.id else None,
            "artist_profile_id": (
                str(self.artist_profile_id)
                if self.artist_profile_id
                else None
            ),
            "document_type": self.document_type,
            "institution_name": self.institution_name,
            "document_number": self.document_number,
            "status": self.status,
            "submitted_at": (
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
