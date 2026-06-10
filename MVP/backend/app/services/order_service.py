from app.extensions import db
from app.models.artwork import Artwork
from app.models.order import Order
from app.persistence.repositories.artist_profile_repo import ArtistProfileRepository
from app.persistence.repositories.order_repo import order_repo
from app.services.notification_service import notification_service

import logging

logger = logging.getLogger(__name__)

artist_profile_repo = ArtistProfileRepository()


def _serialize_order_items(items):
    """Return line items with artwork title and image for client display."""
    serialized = []

    for item in items:
        payload = item.to_dict()
        artwork = db.session.get(Artwork, item.artwork_id)

        if artwork:
            payload["artwork_title"] = artwork.title
            payload["artwork_image_url"] = artwork.artwork_image_url

        serialized.append(payload)

    return serialized

# =========================================================
# Service: Order Service
# =========================================================


def create_user_order(data):

    buyer_id = data.get("buyer_id")
    subtotal = data.get("subtotal")
    shipping_fee = data.get("shipping_fee")
    total_amount = data.get("total_amount")
    items = data.get("items", [])

    if not buyer_id:
        return {"error": "buyer_id is required"}, 400

    if subtotal is None:
        return {"error": "subtotal is required"}, 400

    if shipping_fee is None:
        return {"error": "shipping_fee is required"}, 400

    if total_amount is None:
        return {"error": "total_amount is required"}, 400

    if not items:
        return {"error": "Order must contain at least one item"}, 400

    normalized_items = []

    for item in items:
        artwork_id = item.get("artwork_id")
        quantity = item.get("quantity")

        if not artwork_id or quantity is None:
            return {
                "error": (
                    "Each item must include artwork_id and quantity"
                )
            }, 400

        try:
            quantity = int(quantity)
        except (TypeError, ValueError):
            return {
                "error": "Each item quantity must be a whole number",
            }, 400

        if quantity < 1:
            return {
                "error": "Each item quantity must be at least 1",
            }, 400

        normalized_items.append(
            {
                "artwork_id": artwork_id,
                "quantity": quantity,
            }
        )

    try:
        order, created_items = order_repo.create_order_with_items(
            buyer_id=buyer_id,
            items=normalized_items,
            status="pending",
            expected_subtotal=subtotal,
            expected_shipping_fee=shipping_fee,
            expected_total_amount=total_amount,
        )
    except ValueError as exc:
        return {"error": str(exc)}, 400

    order_payload = order.to_dict()
    order_payload["items"] = _serialize_order_items(created_items)

    return {
        "message": "Order created successfully",
        "order": order_payload,
    }, 201


def get_user_orders(buyer_id):

    if not buyer_id:
        return {"error": "buyer_id is required"}, 400

    orders = order_repo.get_orders_by_buyer(buyer_id)
    order_payloads = []

    for order in orders:
        payload = order.to_dict()
        _, items = order_repo.get_order_with_items(order.id)
        payload["items"] = _serialize_order_items(items)
        order_payloads.append(payload)

    return {
        "orders": order_payloads,
    }, 200


def get_order_by_id(order_id, user_id, role=None):
    """
    Return a single order with line items when the caller is authorized.

    Buyers may access their own orders. Artists may access orders that
    include their artworks. Admins may access any order.
    """
    if not order_id:
        return {"error": "order_id is required"}, 400

    if not user_id:
        return {"error": "user_id is required"}, 400

    order, items = order_repo.get_order_with_items(order_id)
    if not order:
        return {"error": "Order not found"}, 404

    if role != "admin":
        is_buyer = str(order.buyer_id) == str(user_id)
        is_artist = False

        if not is_buyer:
            profile = artist_profile_repo.get_active_by_user_id(user_id)
            if profile:
                is_artist = order_repo.artist_has_order(profile.id, order.id)

        if not is_buyer and not is_artist:
            return {"error": "Forbidden"}, 403

    order_payload = order.to_dict()
    order_payload["items"] = _serialize_order_items(items)

    return {"order": order_payload}, 200


def get_artist_orders(artist_profile_id):

    if not artist_profile_id:
        return {"error": "artist_profile_id is required"}, 400

    orders = order_repo.get_incoming_orders_by_artist(
        artist_profile_id
    )
    order_payloads = []

    for order in orders:
        payload = order.to_dict()
        _, items = order_repo.get_order_with_items(order.id)
        payload["items"] = _serialize_order_items(items)
        order_payloads.append(payload)

    return {
        "orders": order_payloads,
    }, 200


def change_order_status(
    order_id,
    status,
    shipping_company=None,
    tracking_number=None,
):

    if not order_id:
        return {"error": "order_id is required"}, 400

    if not status:
        return {"error": "status is required"}, 400

    allowed_statuses = list(Order.ALLOWED_STATUSES)

    if status not in allowed_statuses:
        return {"error": "Invalid order status"}, 400

    order = order_repo.update_order_status(
        order_id=order_id,
        status=status,
        shipping_company=shipping_company,
        tracking_number=tracking_number,
    )

    if not order:
        return {"error": "Order not found"}, 404

    try:
        buyer = order_repo.get_buyer_notification_info(order.buyer_id)
        # Paid transitions are owned by payment_service.verify_payment()
        # via notify_payment_success(); skip generic order_status here.
        if buyer and status != "paid":
            notification_service.notify_customer_order_status(
                buyer,
                order,
                status,
            )
    except Exception:
        logger.exception(
            "Customer order-status notifications failed (non-fatal) "
            "for order_id=%s status=%s",
            order.id,
            status,
        )

    return {
        "message": "Order status updated successfully",
        "order": order.to_dict(),
    }, 200
