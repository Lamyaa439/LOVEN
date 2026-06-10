from app.persistence.repositories.user_repo import UserRepository
from app.persistence.repositories.artist_profile_repo import ArtistProfileRepository
from app.persistence.repositories.artwork_repo import ArtworkRepository
from app.persistence.repositories.report_repo import report_repo
from app.persistence.repositories.verification_request_repo import (
    verification_request_repo,
)

user_repo = UserRepository()
artist_profile_repo = ArtistProfileRepository()
artwork_repo = ArtworkRepository()


def get_dashboard_stats():
    return {
        "total_users": user_repo.count_active_users(),
        "total_artists": user_repo.count_active_artists(),
        "verified_artists": artist_profile_repo.count_verified_artists(),
        "total_artworks": artwork_repo.count_active_artworks(),
        "open_reports": report_repo.count_open_reports(),
        "pending_verification_requests": (
            verification_request_repo.count_pending_requests()
        ),
    }, 200