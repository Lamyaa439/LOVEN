from app.extensions import db
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import CheckConstraint
import uuid

# =========================================================
# Model: OrderItem
# =========================================================
# Description:
# Represents a single artwork inside a customer order.
#
# Relationships:
# - Belongs to one order
# - References one artwork
#
# Purpose:
# Stores purchased artwork information and preserves
# historical pricing using price_at_purchase.
#
# IMPORTANT:
# This model intentionally DOES NOT inherit
# from BaseModel.
#
# Reason:
# The official schema does not include:
# - updated_at
# - deleted_at
# for order_items.
#
# Financial records should remain immutable.
# =========================================================


class OrderItem(db.Model):

    # Database table name
    __tablename__ = "order_items"

    # =====================================================
    # Primary Key
    # =====================================================

    # Unique order item identifier
    id = db.Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    # =====================================================
    # Foreign Keys
    # =====================================================

    # Reference to parent order
    order_id = db.Column(
        UUID(as_uuid=True),

        # Financial records should never cascade delete
        db.ForeignKey(
            "orders.id",
            ondelete="RESTRICT"
        ),

        nullable=False
    )

    # Reference to purchased artwork
    artwork_id = db.Column(
        UUID(as_uuid=True),

        # Purchased artworks should remain protected
        db.ForeignKey(
            "artworks.id",
            ondelete="RESTRICT"
        ),

        nullable=False
    )

    # =====================================================
    # Purchase Information
    # =====================================================

    # Number of artwork units purchased
    quantity = db.Column(
        db.Integer,
        nullable=False
    )

    # Historical artwork price at purchase time
    #
    # IMPORTANT:
    # This preserves financial history even if
    # artwork prices later change.
    price_at_purchase = db.Column(
        db.Numeric(10, 2),
        nullable=False
    )

    # =====================================================
    # Audit Timestamp
    # =====================================================

    # Timestamp when order item was created
    created_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp()
    )

    # =====================================================
    # Database Constraints
    # =====================================================

    __table_args__ = (

        # Quantity must be greater than zero
        CheckConstraint(
            "quantity > 0",
            name="check_order_item_quantity_positive"
        ),

        # Price cannot be negative
        CheckConstraint(
            "price_at_purchase >= 0",
            name="check_order_item_price_positive"
        ),
    )

    # =====================================================
    # Serialization Helper
    # =====================================================

    def to_dict(self):
        """
        Convert OrderItem object into serializable dictionary.

        Returns:
            dict: API-friendly order item data.
        """

        return {

            # Convert UUID values into strings
            "id": str(self.id) if self.id else None,

            # Parent order reference
            "order_id": (
                str(self.order_id)
                if self.order_id
                else None
            ),

            # Purchased artwork reference
            "artwork_id": (
                str(self.artwork_id)
                if self.artwork_id
                else None
            ),

            # Purchase quantity
            "quantity": self.quantity,

            # Historical locked price
            "price_at_purchase": (
                float(self.price_at_purchase)
                if self.price_at_purchase is not None
                else None
            ),

            # Creation timestamp
            "created_at": (
                self.created_at.isoformat()
                if self.created_at
                else None
            ),
        }