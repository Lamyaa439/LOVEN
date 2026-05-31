
"""
Payment Data Model Definition.

ORM for the `payments` table. Each payment belongs to exactly one order
(one-to-one). Moyasar payment IDs are stored after the mobile SDK captures
payment; the backend verifies them via ``MoyasarClient.fetch_payment``.
"""

from decimal import Decimal, InvalidOperation

from app.extensions import db
from app.models.base_model import BaseModel
from sqlalchemy import CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import validates


class Payment(BaseModel):
    __tablename__ = "payments"

    # One payment record per order (UNIQUE in SQL schema).
    # ON DELETE RESTRICT: orders and payments are financial records.
    order_id = db.Column(
        UUID(as_uuid=True),
        db.ForeignKey("orders.id", ondelete="RESTRICT"),
        nullable=False,
        unique=True,
        index=True,
    )

    # Moyasar gateway reference returned by the Flutter SDK after capture.
    moyasar_payment_id = db.Column(db.String(255), unique=True, nullable=True)

    amount = db.Column(db.Numeric(10, 2), nullable=True)
    status = db.Column(db.String(50), default="pending", nullable=True)
    currency = db.Column(db.String(10), default="SAR", nullable=True)
    paid_at = db.Column(db.DateTime(timezone=True), nullable=True)

    order = db.relationship(
        "Order",
        backref=db.backref("payment", uselist=False),
    )

    ALLOWED_STATUSES = ("pending", "paid", "failed", "refunded")

    __table_args__ = (
        CheckConstraint("amount >= 0", name="check_payment_amount_positive"),
    )

    @validates("status")
    def validate_status(self, key, value):
        if value is None:
            return "pending"
        if value not in self.ALLOWED_STATUSES:
            raise ValueError(
                f"Invalid payment status '{value}'. "
                f"Allowed values: {', '.join(self.ALLOWED_STATUSES)}"
            )
        return value

    @validates("amount")
    def validate_amount(self, key, value):
        if value is None:
            return None
        try:
            amount_decimal = Decimal(str(value))
        except (InvalidOperation, TypeError):
            raise ValueError("Payment amount must be a valid number.")
        if amount_decimal < 0:
            raise ValueError("Payment amount cannot be negative.")
        return amount_decimal

    @validates("currency")
    def validate_currency(self, key, value):
        if value is None:
            return "SAR"
        if not isinstance(value, str):
            raise ValueError("Currency must be text.")
        clean = value.strip().upper()
        if len(clean) != 3:
            raise ValueError("Currency must be a 3-letter ISO code (e.g. SAR).")
        return clean

    def to_dict(self):
        """API-safe serialization for payment records."""
        return {
            "id": str(self.id) if self.id else None,
            "order_id": str(self.order_id) if self.order_id else None,
            "moyasar_payment_id": self.moyasar_payment_id,
            "amount": float(self.amount) if self.amount is not None else None,
            "status": self.status,
            "currency": self.currency,
            "paid_at": self.paid_at.isoformat() if self.paid_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    def __repr__(self):
        return (
            f"<Payment(order_id={self.order_id}, "
            f"status={self.status}, amount={self.amount})>"
        )
