"""
Payment service layer.

Business logic for Moyasar payment verification after the Flutter SDK
captures payment on-device. The backend never initiates charges — it
only confirms gateway state and persists the result.

Returns:
    tuple: (response dict, HTTP status code)

Architecture:
    API Route -> Facade -> Service -> Repository / MoyasarClient -> Database
"""

import logging
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy.exc import IntegrityError

from app.core.uuid_utils import as_uuid
from app.extensions import db
from app.external_services.moyasar_service import MoyasarClient, MoyasarError
from app.models.order import Order
from app.models.payment import Payment
from app.persistence.repositories.order_repo import order_repo
from app.persistence.repositories.payment_repo import PaymentRepository
from app.services.notification_service import notification_service
from config import Config

logger = logging.getLogger(__name__)

payment_repo = PaymentRepository()
moyasar_client = MoyasarClient(secret_key=Config.MOYASAR_SECRET_KEY)

# Moyasar amounts are in the smallest currency unit (halalah for SAR).
_HALALAH_PER_UNIT = 100

# Gateway statuses treated as successfully captured.
_MOYASAR_PAID_STATUSES = frozenset({"paid", "captured"})


# =========================================================
# Private helpers
# =========================================================

def _amount_to_halalah(amount) -> int:
    """Convert a major-unit decimal amount (e.g. 170.00 SAR) to halalah."""
    return int(Decimal(str(amount)) * _HALALAH_PER_UNIT)


def _halalah_to_major(amount_halalah) -> Decimal:
    """Convert Moyasar halalah amount back to major currency units."""
    return Decimal(str(amount_halalah)) / _HALALAH_PER_UNIT


def _parse_moyasar_timestamp(raw_value):
    """Best-effort parse of Moyasar ISO timestamps into aware datetimes."""
    if not raw_value:
        return None
    if isinstance(raw_value, datetime):
        return raw_value if raw_value.tzinfo else raw_value.replace(tzinfo=timezone.utc)
    try:
        normalized = str(raw_value).replace("Z", "+00:00")
        parsed = datetime.fromisoformat(normalized)
        return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)
    except ValueError:
        return None


def _get_order_for_buyer(order_id, buyer_id):
    """
    Load an order and ensure it belongs to the authenticated buyer.

    Returns:
        (order, error_response) — error_response is a (dict, status_code) tuple
        when validation fails, otherwise None.
    """
    try:
        order_uuid = as_uuid(order_id)
        buyer_uuid = as_uuid(buyer_id)
    except (TypeError, ValueError):
        return None, ({"error": "Invalid order or buyer ID format"}, 400)

    order = db.session.get(Order, order_uuid)
    if not order:
        return None, ({"error": "Order not found"}, 404)

    if order.buyer_id != buyer_uuid:
        return None, ({"error": "Forbidden"}, 403)

    return order, None


def _get_or_create_pending_payment(order):
    """Return the existing payment row for an order, creating a pending one if needed."""
    payment = payment_repo.get_by_order_id(order.id)
    if payment:
        return payment

    payment = Payment(
        order_id=order.id,
        status="pending",
        currency="SAR",
    )
    payment_repo.add(payment)
    return payment


# =========================================================
# Public service operations
# =========================================================

def initiate_payment(order_id, buyer_id):
    """
    Create (or return) a pending payment record for an order.

    Called after order creation and before the mobile SDK opens Moyasar.
    """
    order, error = _get_order_for_buyer(order_id, buyer_id)
    if error:
        return error

    if order.total_amount is None:
        return {"error": "Order total_amount is missing"}, 400

    existing = payment_repo.get_by_order_id(order.id)
    if existing:
        if existing.status == "paid":
            return {
                "message": "Order is already paid",
                "payment": existing.to_dict(),
            }, 200
        return {
            "message": "Payment already initiated",
            "payment": existing.to_dict(),
        }, 200

    try:
        payment = Payment(
            order_id=order.id,
            status="pending",
            currency="SAR",
            amount=order.total_amount,
        )
        payment_repo.add(payment)
    except IntegrityError:
        db.session.rollback()
        payment = payment_repo.get_by_order_id(order.id)
        if not payment:
            return {"error": "Could not initiate payment"}, 400

    return {
        "message": "Payment initiated",
        "payment": payment.to_dict(),
        "expected_amount_halalah": _amount_to_halalah(order.total_amount),
        "currency": "SAR",
    }, 201


def verify_payment(order_id, moyasar_payment_id, buyer_id):
    """
    Verify a Moyasar payment ID against the gateway and fulfill the order.

    Idempotent: if the same gateway payment was already verified for this
    order, the existing paid record is returned without re-calling Moyasar.

    Args:
        order_id: Internal LOVEN order UUID.
        moyasar_payment_id: Payment ID returned by the Moyasar Flutter SDK.
        buyer_id: Authenticated buyer UUID (from JWT).

    Returns:
        (dict, status_code)
    """
    if not moyasar_payment_id or not str(moyasar_payment_id).strip():
        return {"error": "moyasar_payment_id is required"}, 400

    order, error = _get_order_for_buyer(order_id, buyer_id)
    if error:
        return error

    if order.total_amount is None:
        return {"error": "Order total_amount is missing"}, 400

    moyasar_payment_id = str(moyasar_payment_id).strip()
    expected_halalah = _amount_to_halalah(order.total_amount)

    # Idempotency — same gateway ID already recorded as paid.
    existing_gateway_payment = payment_repo.get_by_moyasar_payment_id(moyasar_payment_id)
    if existing_gateway_payment:
        if existing_gateway_payment.order_id == order.id and existing_gateway_payment.status == "paid":
            return {
                "message": "Payment already verified",
                "payment": existing_gateway_payment.to_dict(),
            }, 200
        return {"error": "Moyasar payment ID is already linked to another order"}, 409

    payment = _get_or_create_pending_payment(order)
    if payment.status == "paid":
        return {
            "message": "Order is already paid",
            "payment": payment.to_dict(),
        }, 200

    # Fetch authoritative state from Moyasar.
    try:
        gateway_payment = moyasar_client.fetch_payment(moyasar_payment_id)
    except MoyasarError as exc:
        logger.warning("Moyasar verification failed for %s: %s", moyasar_payment_id, exc)
        status_code = 502 if exc.status_code == 0 else 400
        return {"error": f"Payment verification failed: {exc.detail}"}, status_code

    gateway_status = (gateway_payment.get("status") or "").lower()
    gateway_amount = gateway_payment.get("amount")
    gateway_currency = (gateway_payment.get("currency") or "").upper()

    if gateway_status not in _MOYASAR_PAID_STATUSES:
        payment_repo.mark_failed(payment.id, moyasar_payment_id=moyasar_payment_id)
        return {
            "error": f"Payment not completed (gateway status: {gateway_status or 'unknown'})",
        }, 402

    if gateway_currency != "SAR":
        payment_repo.mark_failed(payment.id, moyasar_payment_id=moyasar_payment_id)
        return {"error": "Payment currency mismatch"}, 400

    try:
        gateway_amount_int = int(gateway_amount)
    except (TypeError, ValueError):
        payment_repo.mark_failed(payment.id, moyasar_payment_id=moyasar_payment_id)
        return {"error": "Invalid payment amount from gateway"}, 400

    if gateway_amount_int != expected_halalah:
        payment_repo.mark_failed(payment.id, moyasar_payment_id=moyasar_payment_id)
        return {
            "error": "Payment amount does not match order total",
            "expected_halalah": expected_halalah,
            "received_halalah": gateway_amount_int,
        }, 400

    verified_amount = _halalah_to_major(gateway_amount_int)
    paid_at = _parse_moyasar_timestamp(gateway_payment.get("paid_at") or gateway_payment.get("created_at"))

    try:
        updated_payment = payment_repo.fulfill_paid_order(
            payment.id,
            order.id,
            moyasar_payment_id=moyasar_payment_id,
            amount=verified_amount,
            currency=gateway_currency,
            paid_at=paid_at,
        )
    except IntegrityError:
        db.session.rollback()
        duplicate = payment_repo.get_by_moyasar_payment_id(moyasar_payment_id)
        if duplicate and duplicate.status == "paid":
            return {
                "message": "Payment already verified",
                "payment": duplicate.to_dict(),
            }, 200
        return {"error": "Could not persist payment record"}, 409
    except ValueError as exc:
        db.session.rollback()
        return {"error": str(exc)}, 400

    if not updated_payment:
        return {"error": "Could not fulfill payment for order"}, 500

    try:
        db.session.refresh(order)
        buyer = order_repo.get_buyer_notification_info(order.buyer_id)
        if buyer:
            notification_service.notify_payment_success(
                buyer,
                order,
                payment=updated_payment,
            )
    except Exception:
        logger.exception(
            "Payment-success notification failed (non-fatal) "
            "for order_id=%s payment_id=%s",
            order.id,
            updated_payment.id,
        )

    try:
        artist_users = order_repo.get_artist_users_for_order(order.id)
        for artist_user in artist_users:
            notification_service.notify_artist_new_order(artist_user, order)
    except Exception:
        logger.exception(
            "Artist new-order notifications failed (non-fatal) "
            "for order_id=%s payment_id=%s",
            order.id,
            updated_payment.id,
        )

    return {
        "message": "Payment verified successfully",
        "payment": updated_payment.to_dict(),
        "order_id": str(order.id),
    }, 200

# لاستعراض تفاصيل الفاتورة
def get_payment_for_order(order_id, buyer_id):
    """Return the payment record for an order owned by the buyer."""
    order, error = _get_order_for_buyer(order_id, buyer_id)
    if error:
        return error

    payment = payment_repo.get_by_order_id(order.id)
    if not payment:
        return {"error": "Payment not found for this order"}, 404

    return {"payment": payment.to_dict()}, 200
