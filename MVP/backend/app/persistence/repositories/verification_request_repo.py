"""
Verification request repository.

Handles ORM persistence for artist verification submissions.
"""

from app.extensions import db
from app.models.artist_profile import ArtistProfile
from app.models.verification_requests import VerificationRequest
from app.persistence.repository import SQLAlchemyRepository


class VerificationRequestRepository(SQLAlchemyRepository):
    VALID_STATUSES = frozenset({"pending", "approved", "rejected"})

    def __init__(self):
        super().__init__(VerificationRequest)

    def create_request(self, data):
        """Create and persist a new verification request."""
        verification_request = VerificationRequest(
            artist_profile_id=data["artist_profile_id"],
            document_type=data.get("document_type"),
            institution_name=data.get("institution_name"),
            document_number=data.get("document_number"),
            status="pending",
        )
        return self.save(verification_request)

    def get_pending_request_for_profile(self, artist_profile_id):
        """
        Return the active pending verification request for a profile, if any.
        """
        if not artist_profile_id:
            return None

        return (
            self.model.query.filter_by(
                artist_profile_id=artist_profile_id,
                status="pending",
            )
            .filter(self.model.deleted_at.is_(None))
            .first()
        )

    def list_all(self):
        """Return all non-deleted verification requests, newest first."""
        return (
            self.model.query.filter(self.model.deleted_at.is_(None))
            .order_by(self.model.created_at.desc())
            .all()
        )

    def update_status(self, verification_request, status):
        """
        Update verification request status and, when approved, mark the
        linked artist profile as verified in a single transaction.
        """
        if status not in self.VALID_STATUSES:
            raise ValueError(
                "status must be pending, approved, or rejected"
            )

        verification_request.status = status

        if status == "approved":
            artist_profile = db.session.get(
                ArtistProfile,
                verification_request.artist_profile_id,
            )
            if artist_profile:
                artist_profile.is_verified = True

        return self.save(verification_request)


verification_request_repo = VerificationRequestRepository()
