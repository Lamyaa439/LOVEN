"""
Payment repository.

Handles database operations for the Payment model.
Inherits generic CRUD from SQLAlchemyRepository and adds
payment-specific lookups used during Moyasar verification.

Typical flow:
    1. Service creates a pending Payment row for an order.
    2. Flutter sends ``moyasar_payment_id`` after SDK capture.
    3. Service fetches via ``get_by_moyasar_payment_id`` for idempotency,
       verifies with MoyasarClient, then updates status via ``save``.
"""

from datetime import datetime, timezone

from app.extensions import db
from app.models.order import Order
from app.models.payment import Payment
from app.persistence.repository import SQLAlchemyRepository


class PaymentRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Payment)

    # =========================================================
    # Payment lookup helpers
    # =========================================================

    # البحث عن الفاتورة برقم الطلب 
    def get_by_order_id(self, order_id):
        """
        Return the active payment record for an order.

        Because ``order_id`` is UNIQUE on the payments table, at most
        one non-deleted row exists per order.
        """
        if not order_id:
            return None
        return self.get_by_attribute("order_id", order_id)

    def get_by_moyasar_payment_id(self, moyasar_payment_id):
        """
        Return a payment by its Moyasar gateway reference.

        Used to:
        - prevent duplicate verification of the same gateway payment
        - reconcile webhook / retry requests idempotently
        """
        if not moyasar_payment_id:
            return None
        return self.get_by_attribute("moyasar_payment_id", moyasar_payment_id)
    
    # تغيير حالة الفاتورة: تم الدفع
    def mark_paid(
        self,
        payment_id,
        *,
        moyasar_payment_id,
        amount,
        currency="SAR",
        paid_at=None,
    ):
        """
        Persist a successful Moyasar verification on an existing payment row.

        Args:
            payment_id: Internal payment UUID.
            moyasar_payment_id: Gateway payment ID from the mobile SDK.
            amount: Verified amount in major currency units (e.g. SAR).
            currency: ISO currency code (defaults to SAR).
            paid_at: Timestamp when Moyasar marked the payment paid.
                     Defaults to UTC now if omitted.

        Returns:
            Updated Payment instance, or None if not found.
        """
        payment = self.get(payment_id)
        if not payment:
            return None

        payment.moyasar_payment_id = moyasar_payment_id
        payment.amount = amount
        payment.currency = currency
        payment.status = "paid"
        payment.paid_at = paid_at or datetime.now(timezone.utc)

        return self.save(payment)

    def fulfill_paid_order(
        self,
        payment_id,
        order_id,
        *,
        moyasar_payment_id,
        amount,
        currency="SAR",
        paid_at=None,
    ):
        """
        Mark payment as paid and order as paid in a single transaction.

        Returns the updated Payment, or None if payment/order was not found.
        """
        try:
            payment = db.session.get(Payment, payment_id)
            order = db.session.get(Order, order_id)

            if not payment or not order:
                return None

            payment.moyasar_payment_id = moyasar_payment_id
            payment.amount = amount
            payment.currency = currency
            payment.status = "paid"
            payment.paid_at = paid_at or datetime.now(timezone.utc)

            order.status = "paid"

            db.session.commit()
            return payment
        except Exception:
            db.session.rollback()
            raise

    # تغيير حالة الفاتورة :فشل الدفع
    def mark_failed(self, payment_id, *, moyasar_payment_id=None):
        """Mark a payment as failed after verification or gateway rejection."""
        payment = self.get(payment_id)
        if not payment:
            return None

        if moyasar_payment_id:
            payment.moyasar_payment_id = moyasar_payment_id
        payment.status = "failed"

        return self.save(payment)
