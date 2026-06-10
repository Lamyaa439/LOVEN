"""
Artist Profile repository.

Handles database operations related to the ArtistProfile model.
Inherits generic CRUD from SQLAlchemyRepository: add, get, get_all, update,
delete, soft_delete, get_by_attribute, get_all_by_attribute.

"""
from app.persistence.repository import SQLAlchemyRepository
from app.models.artist_profile import ArtistProfile


class ArtistProfileRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(ArtistProfile)

    # =====================================================================
    # Reads that respect soft-delete (use these for normal app flows)
    # =====================================================================

    def get_active_by_user_id(self, user_id):
        """
        Fetch the caller's active artist profile.
        Powers GET /artists/me and any guard that asks "does this user have
        a live profile?". Soft-deleted profiles are NOT returned.
        """
        if not user_id:
            return None
        return self.get_by_attribute("user_id", user_id)

    def get_active_by_display_name(self, display_name):
        """
        Fetch a live artist profile by its public display name.
        Used by the public profile-by-handle lookup. Soft-deleted profiles
        are NOT returned so they don't surface in the App.
        """
        if not display_name:
            return None
        normalized = display_name.strip()
        return self.get_by_attribute("display_name", normalized)

    def list_active(self, limit=20, offset=0):
        """
        Paginated public listing of active artist profiles, newest first.
        Soft-deleted rows are skipped by the deleted_at filter.
        """
        return (
            self.model.query
            .filter(self.model.deleted_at.is_(None))
            .order_by(self.model.created_at.desc()) # order by descending
            .limit(limit)
            .offset(offset)
            .all()
        )

    # =====================================================================
    # Uniqueness checks (must see soft-deleted rows too, because the DB
    # UNIQUE constraint applies to ALL rows regardless of deleted_at)
    # =====================================================================

    def display_name_is_taken(self, display_name):
        """
        Returns True if ANY row (active or soft-deleted) already uses this
        display name. Use this before insert to fail fast with a 400 instead
        of letting PostgreSQL raise IntegrityError.
        """
        if not display_name:
            return False
        normalized = display_name.strip()
        return (
            # use first() so if find one artist with this display_name
            # stop looking and return True
            self.model.query.filter_by(display_name=normalized).first()
            is not None # True: taken, Flase: not taken
        )

    def get_any_by_user_id(self, user_id):
        """
        Returns the profile owned by this user even if it was soft-deleted.
        Used during create-profile so the service can offer to restore an
        existing soft-deleted profile instead of failing on the UNIQUE
        constraint over user_id.
        """
        if not user_id:
            return None
        return self.model.query.filter_by(user_id=user_id).first()

    # =====================================================================
    # Targeted updates (thin wrappers around the generic update)
    # =====================================================================

    def set_verified(self, profile_id, is_verified=True):
        """
        Admin action: flip the is_verified flag. Returns the updated
        ArtistProfile or None if not found / soft-deleted.
        """
        return self.update(profile_id, {"is_verified": is_verified})

    def update_profile_image(self, profile_id, new_url):
        """
        Persists the Firebase Storage URL after a successful image upload.
        """
        return self.update(profile_id, {"profile_image_url": new_url})
    
    def count_verified_artists(self):
        return (
            self.model.query
            .filter(self.model.deleted_at.is_(None))
            .filter(self.model.is_verified.is_(True))
            .count()
        )
