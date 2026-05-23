from app.models.artist_profile import ArtistProfile
from app.persistence.repositories.verification_request_repo import (
    VerificationRequestRepository,
)


class VerificationRequestService:
    VALID_STATUSES = {"pending", "approved", "rejected"}

    @staticmethod
    def create_request(user_id, data):
        """
        Create a verification request for the authenticated artist.

        The client should NOT send artist_profile_id.
        We derive the artist profile from the JWT user_id.
        """

        if not data:
            raise ValueError("Request body is required")

        artist_profile = ArtistProfile.query.filter_by(
            user_id=user_id,
        ).first()

        if not artist_profile:
            raise ValueError("Artist profile not found")

        existing_pending_request = (
            VerificationRequestRepository.get_pending_request_for_profile(
                artist_profile.id,
            )
        )

        if existing_pending_request:
            raise ValueError(
                "A pending verification request already exists"
            )

        request_data = {
            "artist_profile_id": artist_profile.id,
            "document_type": data.get("document_type"),
            "institution_name": data.get("institution_name"),
            "document_number": data.get("document_number"),
        }

        return VerificationRequestRepository.create(request_data)

    @staticmethod
    def get_all_requests():
        return VerificationRequestRepository.get_all()

    @staticmethod
    def get_request_by_id(request_id):
        verification_request = VerificationRequestRepository.get_by_id(
            request_id,
        )

        if not verification_request:
            raise ValueError("Verification request not found")

        return verification_request

    @staticmethod
    def update_request_status(request_id, status):
        if not status:
            raise ValueError("status is required")

        if status not in VerificationRequestService.VALID_STATUSES:
            raise ValueError(
                "status must be one of: pending, approved, rejected"
            )

        verification_request = VerificationRequestRepository.get_by_id(
            request_id,
        )

        if not verification_request:
            raise ValueError("Verification request not found")

        return VerificationRequestRepository.update_status(
            verification_request,
            status,
        )