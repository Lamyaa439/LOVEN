from app.extensions import db
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import CheckConstraint
import uuid

# =========================================================
# Model: Order
# =========================================================
# Description:
# Represents a customer order in the LOVEN application.
#
# Relationships:
# - Belongs to one buyer (users table)
# - Can contain multiple order_items
#
# Purpose:
# Stores financial and shipment information
# related to a customer purchase.
#
# IMPORTANT:
# This model intentionally DOES NOT inherit
# from BaseModel.
#
# Reason:
# The official schema does not include:
# - deleted_at
# for financial order records.
#
# Financial records should remain immutable
# and should generally NOT support soft deletion.
# =========================================================


class Order(db.Model):

    # Database table name
    __tablename__ = "orders"

    # =====================================================
    # Primary Key
    # =====================================================

    # Unique order identifier
    id = db.Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    # =====================================================
    # Buyer Information
    # =====================================================

    # Reference to the customer who placed the order
    buyer_id = db.Column(
        UUID(as_uuid=True),

        # Financial records should never cascade delete
        db.ForeignKey(
            "users.id",
            ondelete="RESTRICT"
        ),

        nullable=False
    )

    # =====================================================
    # Financial Information
    # =====================================================

    # Sum of artwork prices before shipping
    subtotal = db.Column(
        db.Numeric(10, 2),
        nullable=True
    )

    # Shipping cost charged to customer
    shipping_fee = db.Column(
        db.Numeric(10, 2),
        nullable=True
    )

    # Final order total
    subtotal = db.Column(
        db.Numeric(10, 2),
        nullable=True
    )

    # Shipping cost charged to customer
    shipping_fee = db.Column(
        db.Numeric(10, 2),
        nullable=True
    )

    # Final order total
    total_amount = db.Column(
        db.Numeric(10, 2),
        nullable=True
    )

    # =====================================================
    # Order Status
    # =====================================================

    # Current order state
    #
    # Example values:
    # - pending
    # - paid
    # - shipped
    # - delivered
    # - cancelled
    status = db.Column(
        db.String(50),
        default="pending",
        nullable=True
    )

    # =====================================================
    # Shipment Information
    # =====================================================

    # Shipping provider name
    # Example:
    # - DHL
    # - Aramex
    # - FedEx
    shipping_company = db.Column(
        db.String(100),
        nullable=True
    )

    # Shipment tracking reference
    tracking_number = db.Column(
        db.String(100),
        nullable=True
    )

    # =====================================================
    # Audit Timestamps
    # =====================================================

    # Timestamp when order was created
    created_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp()
    )

    # Timestamp when order was last updated
    updated_at = db.Column(
        db.DateTime,
        server_default=db.func.current_timestamp(),
        onupdate=db.func.current_timestamp()
    )

    # =====================================================
    # Database Constraints
    # =====================================================

    __table_args__ = (

        # Prevent negative subtotal values
        CheckConstraint(
            "subtotal >= 0",
            name="check_order_subtotal_positive"
        ),

        # Prevent negative shipping fees
        CheckConstraint(
            "shipping_fee >= 0",
            name="check_order_shipping_fee_positive"
        ),

        # Prevent negative order totals
        CheckConstraint(
            "total_amount >= 0",
            name="check_order_total_amount_positive"
        ),
    )

    # =====================================================
    # Serialization Helper
    # =====================================================

    def to_dict(self):
        """
        Convert Order object into serializable dictionary.

        Returns:
            dict: API-friendly order data.
        """

        return {

            # Convert UUID values into strings
            "id": str(self.id) if self.id else None,

            # Buyer reference
            "buyer_id": (
                str(self.buyer_id)
                if self.buyer_id
                else None
            ),

            # Financial values
            "subtotal": (
                float(self.subtotal)
                if self.subtotal is not None
                else None
            ),

            "shipping_fee": (
                float(self.shipping_fee)
                if self.shipping_fee is not None
                else None
            ),

            "total_amount": (
                float(self.total_amount)
                if self.total_amount is not None
                else None
            ),

            # Order state
            "status": self.status,

            # Shipment details
            "shipping_company": self.shipping_company,
            "tracking_number": self.tracking_number,

            # Audit timestamps
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