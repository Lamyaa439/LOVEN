from app.extensions import db
from app.models.base_model import BaseModel


class Favorite(BaseModel):
    """
    Favorite model.

    Represents a "like" relationship between a user and an artwork.

    Rules:
    - A user can favorite many artworks.
    - An artwork can be favorited by many users.
    - Duplicate favorites are prevented using a UNIQUE constraint.

    Example:
        user_id = Alice
        artwork_id = Mona Lisa

        -> means Alice favorited Mona Lisa
    """

    __tablename__ = "favorites"

    # =========================================================
    # Foreign Keys
    # =========================================================

    # User who favorited the artwork
    user_id = db.Column(
        db.UUID(as_uuid=True),
        db.ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    # Artwork that was favorited
    artwork_id = db.Column(
        db.UUID(as_uuid=True),
        db.ForeignKey("artworks.id", ondelete="CASCADE"),
        nullable=False,
    )

    # =========================================================
    # Constraints
    # =========================================================

    # Prevent duplicate favorites:
    # the same user cannot favorite the same artwork twice
    __table_args__ = (
        db.UniqueConstraint(
            "user_id",
            "artwork_id",
            name="uq_user_artwork_favorite",
        ),
    )