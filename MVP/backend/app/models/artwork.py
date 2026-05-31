from decimal import Decimal, InvalidOperation
from app.extensions import db
from app.models.base_model import BaseModel
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import validates

"""
Artwork Data Model Definition.

Acts as the Object-Relational Mapping (ORM) for the `artworks` table.
Each artwork belongs to exactly one ArtistProfile and carries the listing
information shown in the marketplace (title, price, quantity, image, status).
"""


class Artwork(BaseModel):
    __tablename__ = "artworks"

    # Architecture Note:
    # The owner is the artist_profile, NOT the user directly.
    # ON DELETE CASCADE mirrors the SQL schema: if an artist profile is removed,
    # its artworks are removed too.
    artist_profile_id = db.Column(
        UUID(as_uuid=True),
        db.ForeignKey("artist_profiles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Listing information
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)

    # Architecture Note:
    # Numeric (DECIMAL in PostgreSQL) is used instead of Float to avoid
    # floating-point rounding errors on money. precision=10, scale=2 means
    # up to 99,999,999.99 SAR.
    price = db.Column(db.Numeric(10, 2), nullable=False)
    quantity_available = db.Column(db.Integer, nullable=False, default=1)
    shipping_fee = db.Column(db.Numeric(10, 2), nullable=False, default=0)

    # Filled in server-side after a successful Firebase Storage upload
    artwork_image_url = db.Column(db.String(255), nullable=True)

    # Lifecycle status. Validated against a whitelist below.
    status = db.Column(db.String(50), nullable=False, default="available")

    # Architecture Note:
    # backref creates `artist.artworks` automatically on the ArtistProfile side.
    # lazy="dynamic" returns a query (not a list) so we can paginate / filter
    # without loading every artwork into memory.
    artist = db.relationship(
        "ArtistProfile",
        backref=db.backref("artworks", lazy="dynamic"),
    )

    # Whitelist of allowed status values, used by validate_status below.
    ALLOWED_STATUSES = ("available", "sold_out", "hidden")

    # ==========================================
    # Validation Methods
    # ==========================================

    # ----------------- validate for title -----------------
    @validates("title")
    def validate_title(self, key, value):
        """
        Sanitizes and validates the artwork title.
        Args:
            value (str): The title provided by the artist.
        Returns:
            str: The sanitized (stripped) title.

        raises:
            ValueError: if the title is missing, not a string, or not between
            3-255 characters.
        """
        if not value or not isinstance(value, str):
            raise ValueError("Title is required and must be text.")

        clean_title = value.strip()

        if len(clean_title) < 3 or len(clean_title) > 255:
            raise ValueError("Title must be between 3 and 255 characters.")

        return clean_title

    # ----------------- validate for description -----------------
    @validates("description")
    def validate_description(self, key, value):
        """
        Optional field. Cap at 2000 chars to keep listing pages readable.
        """
        if value is None:
            return None

        if not isinstance(value, str):
            raise ValueError("Description must be text.")

        clean_description = value.strip()

        if clean_description == "":
            return None

        if len(clean_description) > 2000:
            raise ValueError("Description must be 2000 characters or fewer.")

        return clean_description

    # ----------------- validate for price -----------------
    @validates("price")
    def validate_price(self, key, value):
        """
        Coerces the price into Decimal and enforces price >= 0.
        Accepts int, float, str, or Decimal from the API layer.

        raises:
            ValueError: if the price is missing, not numeric, or negative.
        """
        if value is None:
            raise ValueError("Price is required.")

        try:
            price_decimal = Decimal(str(value))
        except (InvalidOperation, TypeError):
            raise ValueError("Price must be a valid number.")

        if price_decimal < 0:
            raise ValueError("Price cannot be negative.")

        return price_decimal

    # ----------------- validate for quantity_available -----------------
    @validates("quantity_available")
    def validate_quantity_available(self, key, value):
        """
        Enforces quantity_available is a non-negative integer.
        A value of 0 is allowed and represents an out-of-stock listing.
        """
        if value is None:
            return 1

        try:
            quantity = int(value)
        except (TypeError, ValueError):
            raise ValueError("Quantity must be a whole number.")

        if quantity < 0:
            raise ValueError("Quantity cannot be negative.")

        return quantity

    # ----------------- validate for shipping_fee -----------------
    @validates("shipping_fee")
    def validate_shipping_fee(self, key, value):
        """
        Coerces the shipping fee into Decimal and enforces fee >= 0.
        Defaults to 0 when not provided.
        """
        if value is None:
            return Decimal("0")

        try:
            fee_decimal = Decimal(str(value))
        except (InvalidOperation, TypeError):
            raise ValueError("Shipping fee must be a valid number.")

        if fee_decimal < 0:
            raise ValueError("Shipping fee cannot be negative.")

        return fee_decimal

    # ----------------- validate for artwork_image_url -----------------
    @validates("artwork_image_url")
    def validate_artwork_image_url(self, key, value):
        """
        Optional field. When provided, must be an HTTP(S) URL to prevent
        XSS payloads (javascript:, data:, etc.) from being stored.
        """
        if value is None:
            return None

        if not isinstance(value, str):
            raise ValueError("Image URL must be text.")

        clean_url = value.strip()
        if clean_url == "":
            return None

        if not clean_url.lower().startswith(("https://", "http://")):
            raise ValueError("Image URL must start with http:// or https://.")

        if len(clean_url) > 2048:
            raise ValueError("Image URL must be 2048 characters or fewer.")

        return clean_url

    # ----------------- validate for status -----------------
    @validates("status")
    def validate_status(self, key, value):
        """
        Restricts status to the allowed whitelist so the marketplace logic
        can rely on known values.
        """
        if value is None:
            return "available"

        if value not in self.ALLOWED_STATUSES:
            raise ValueError(
                f"Invalid status. Allowed values are: {', '.join(self.ALLOWED_STATUSES)}"
            )

        return value

    def to_dict(self):
        """
        Canonical serialization matching the shape previously produced by
        ``_artwork_to_dict()`` in the service layer. Decimals are converted
        to strings to preserve financial precision across JSON transport.
        """
        return {
            "id": str(self.id) if self.id else None,
            "artist_profile_id": str(self.artist_profile_id) if self.artist_profile_id else None,
            "title": self.title,
            "description": self.description,
            "price": str(self.price) if self.price is not None else None,
            "quantity_available": self.quantity_available,
            "shipping_fee": str(self.shipping_fee) if self.shipping_fee is not None else None,
            "artwork_image_url": self.artwork_image_url,
            "status": self.status,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    def __repr__(self):
        return f"<Artwork(title={self.title}, price={self.price}, status={self.status})>"
