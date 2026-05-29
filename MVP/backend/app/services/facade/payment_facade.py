from app.services.payment_service import (
    initiate_payment,
    verify_payment,
    get_payment_for_order,
)


# =========================================================
# Payment Facade
# =========================================================
# Thin orchestration layer between HTTP routes and the
# payment service. Keeps routes free of business logic and
# leaves room for future workflows (webhooks, refunds, admin).
# =========================================================


class PaymentFacade:

    @staticmethod
    def initiate(order_id, buyer_id):
        """Create or return a pending payment record for an order."""
        return initiate_payment(order_id, buyer_id)

    @staticmethod
    def verify(order_id, moyasar_payment_id, buyer_id):
        """Verify a Moyasar payment ID and fulfill the order."""
        return verify_payment(order_id, moyasar_payment_id, buyer_id)

    @staticmethod
    def get_for_order(order_id, buyer_id):
        """Return the payment record linked to an order."""
        return get_payment_for_order(order_id, buyer_id)
