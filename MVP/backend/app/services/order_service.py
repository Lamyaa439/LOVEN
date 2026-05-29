from app.models.order import Order
from app.persistence.repositories.order_repo import order_repo

from app.external_services.firebase_service import (
    send_order_status_notification,
)

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
        price_at_purchase = item.get("price_at_purchase")

        if (
            not artwork_id
            or not quantity
            or price_at_purchase is None
        ):
            return {
                "error": (
                    "Each item must include "
                    "artwork_id, quantity, "
                    "price_at_purchase"
                )
            }, 400

        normalized_items.append(
            {
                "artwork_id": artwork_id,
                "quantity": quantity,
                "price_at_purchase": price_at_purchase,
            }
        )

    try:
        order, created_items = order_repo.create_order_with_items(
            buyer_id=buyer_id,
            subtotal=subtotal,
            shipping_fee=shipping_fee,
            total_amount=total_amount,
            items=normalized_items,
            status="pending",
        )
    except ValueError as exc:
        return {"error": str(exc)}, 400

    order_payload = order.to_dict()
    order_payload["items"] = [
        order_item.to_dict() for order_item in created_items
    ]

    return {
        "message": "Order created successfully",
        "order": order_payload,
    }, 201


def get_user_orders(buyer_id):

    if not buyer_id:
        return {"error": "buyer_id is required"}, 400

    orders = order_repo.get_orders_by_buyer(buyer_id)

    return {
        "orders": [order.to_dict() for order in orders],
    }, 200


def get_artist_orders(artist_profile_id):

    if not artist_profile_id:
        return {"error": "artist_profile_id is required"}, 400

    orders = order_repo.get_incoming_orders_by_artist(
        artist_profile_id
    )

    return {
        "orders": [order.to_dict() for order in orders],
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

    if status == "shipped":
        buyer = order_repo.get_buyer_notification_info(order.buyer_id)

        if buyer and buyer.fcm_token:
            send_order_status_notification(
                fcm_token=buyer.fcm_token,
                user_name=buyer.name or "Customer",
                order_id=str(order.id),
                status="shipped",
            )

    return {
        "message": "Order status updated successfully",
        "order": order.to_dict(),
    }, 200
