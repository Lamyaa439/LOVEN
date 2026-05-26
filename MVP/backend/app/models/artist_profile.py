from app.extensions import db
from app.models.base_model import BaseModel
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import validates

"""
Artist Profile Data Model Definition.

Acts as the Object-Relational Mapping (ORM) for the `artist_profiles` table.
This file encapsulates artist-specific information (display name, city, bio,
profile image, verification, shipping policy) and links each profile back to
its owning User account through a one-to-one relationship.
"""


class ArtistProfile(BaseModel):
    __tablename__ = "artist_profiles"

    # Architecture Note:
    # user_id is the foreign key back to the users table.
    # UNIQUE enforces the one-to-one rule (one artist profile per user).
    # ON DELETE CASCADE in the SQL schema removes the profile if the user is
    # hard-deleted by an admin.
    user_id = db.Column(
        UUID(as_uuid=True),
        db.ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    # Public-facing identity (shown in the marketplace)
    display_name = db.Column(db.String(255), unique=True, nullable=False)
    city = db.Column(db.String(100), nullable=True)
    bio = db.Column(db.Text, nullable=True)
    profile_image_url = db.Column(db.String(255), nullable=True)

    # Admin grants this flag after reviewing a verification_request
    is_verified = db.Column(db.Boolean, default=False, nullable=False)

    # Free-text shipping policy the artist defines (e.g. "Ships within 3 days")
    shipping_policy = db.Column(db.Text, nullable=True)

    # Architecture Note:
    # backref creates `user.artist_profile` automatically on the User side.
    # uselist=False makes it a single object instead of a list (one-to-one).
    user = db.relationship(
        "User",
        backref=db.backref("artist_profile", uselist=False),
    )

    # ==========================================
    # Validation Methods
    # ==========================================

    # ----------------- validate for display_name -----------------
    @validates("display_name")
    def validate_display_name(self, key, value):
        """
        Sanitizes and validates the artist's public display name.
        Args:
            value (str): The display name provided by the artist.
        Returns:
            str: The sanitized (stripped) display name.

        raises:
            ValueError: if the display name is missing, not a string,
            or not between 3-255 characters.
        """
        if not value or not isinstance(value, str):
            raise ValueError("Display name is required and must be text.")

        clean_name = value.strip()

        if len(clean_name) < 3 or len(clean_name) > 255:
            raise ValueError("Display name must be between 3 and 255 characters.")

        return clean_name

    # ----------------- validate for city -----------------
    @validates("city")
    def validate_city(self, key, value):
        """
        Optional field. If provided, strip whitespace and cap at 100 chars
        to match the VARCHAR(100) limit in the SQL schema.
        """
        if value is None:
            return None

        if not isinstance(value, str):
            raise ValueError("City must be text.")

        clean_city = value.strip()

        if clean_city == "":
            return None

        if len(clean_city) > 100:
            raise ValueError("City must be 100 characters or fewer.")

        return clean_city

    # ----------------- validate for bio -----------------
    @validates("bio")
    def validate_bio(self, key, value):
        """
        Optional field. Cap at 2000 chars to keep profile pages readable
        and prevent abuse of the unlimited TEXT column.
        """
        if value is None:
            return None

        if not isinstance(value, str):
            raise ValueError("Bio must be text.")

        clean_bio = value.strip()

        if clean_bio == "":
            return None

        if len(clean_bio) > 2000:
            raise ValueError("Bio must be 2000 characters or fewer.")

        return clean_bio

    # ----------------- validate for profile_image_url -----------------
    @validates("profile_image_url")
    def validate_profile_image_url(self, key, value):
        """
        Optional field. When provided, must be an HTTP(S) URL to prevent
        XSS payloads (javascript:, data:, etc.) from being stored.
        """
        if value is None:
            return None

        if not isinstance(value, str):
            raise ValueError("Profile image URL must be text.")

        clean_url = value.strip()
        if clean_url == "":
            return None

        if not clean_url.lower().startswith(("https://", "http://")):
            raise ValueError("Profile image URL must start with http:// or https://.")

        if len(clean_url) > 2048:
            raise ValueError("Profile image URL must be 2048 characters or fewer.")

        return clean_url

    def to_dict(self):
        """
        Canonical serialization matching the shape previously produced by
        ``_profile_to_dict()`` in the service layer.
        """
        return {
            "id": str(self.id) if self.id else None,
            "user_id": str(self.user_id) if self.user_id else None,
            "display_name": self.display_name,
            "city": self.city,
            "bio": self.bio,
            "profile_image_url": self.profile_image_url,
            "is_verified": self.is_verified,
            "shipping_policy": self.shipping_policy,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    def __repr__(self):
        return f"<ArtistProfile(display_name={self.display_name}, user_id={self.user_id})>"
