from app.persistence.repositories.order_repo import (
    create_order,
    create_order_item,
    get_orders_by_buyer,
    get_incoming_orders_by_artist,
    update_order_status,
    get_buyer_notification_info,
)

from app.external_services.firebase_service import (
    send_order_status_notification,
)

from app.extensions import db
from app.models.artwork import Artwork

# =========================================================
# Service: Order Service
# =========================================================


def create_user_order(data):

    buyer_id = data.get("buyer_id")
    subtotal = data.get("subtotal")
    shipping_fee = data.get("shipping_fee")
    total_amount = data.get("total_amount")
    items = data.get("items", [])

    # =====================================================
    # Validation
    # =====================================================

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

    # =====================================================
    # Create parent order
    # =====================================================

    order = create_order(
        buyer_id=buyer_id,
        subtotal=subtotal,
        shipping_fee=shipping_fee,
        total_amount=total_amount,
        status="pending",
    )

    order_id = order[0]
    created_items = []

    # =====================================================
    # Create order items
    # =====================================================

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

        order_item = create_order_item(
            order_id=order_id,
            artwork_id=artwork_id,
            quantity=quantity,
            price_at_purchase=price_at_purchase,
        )
        
        artwork = Artwork.query.get(artwork_id)
        
        if artwork:

            artwork.quantity_available -= quantity

            if artwork.quantity_available <= 0:
                artwork.quantity_available = 0
                artwork.status = "sold"
                
            db.session.commit()

        created_items.append({
            "id": str(order_item[0]),
            "order_id": str(order_item[1]),
            "artwork_id": str(order_item[2]),
            "quantity": order_item[3],
            "price_at_purchase": float(order_item[4]),
        })

    return {
        "message": "Order created successfully",
        "order": {
            "id": str(order[0]),
            "buyer_id": str(order[1]),
            "subtotal": float(order[2]),
            "shipping_fee": float(order[3]),
            "total_amount": float(order[4]),
            "status": order[5],
            "created_at": (
                order[6].isoformat()
                if order[6]
                else None
            ),
            "items": created_items,
        },
    }, 201


def get_user_orders(buyer_id):

    if not buyer_id:
        return {"error": "buyer_id is required"}, 400

    orders = get_orders_by_buyer(buyer_id)

    return {
        "orders": [
            {
                "id": str(order[0]),
                "buyer_id": str(order[1]),
                "subtotal": float(order[2]),
                "shipping_fee": float(order[3]),
                "total_amount": float(order[4]),
                "status": order[5],
                "created_at": (
                    order[6].isoformat()
                    if order[6]
                    else None
                ),
            }
            for order in orders
        ]
    }, 200


def get_artist_orders(artist_profile_id):

    if not artist_profile_id:
        return {"error": "artist_profile_id is required"}, 400

    orders = get_incoming_orders_by_artist(
        artist_profile_id
    )

    return {
        "orders": [
            {
                "id": str(order[0]),
                "buyer_id": str(order[1]),
                "subtotal": float(order[2]),
                "shipping_fee": float(order[3]),
                "total_amount": float(order[4]),
                "status": order[5],
                "created_at": (
                    order[6].isoformat()
                    if order[6]
                    else None
                ),
            }
            for order in orders
        ]
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

    allowed_statuses = [
        "pending",
        "paid",
        "shipped",
        "delivered",
        "cancelled",
    ]

    if status not in allowed_statuses:
        return {"error": "Invalid order status"}, 400

    order = update_order_status(
        order_id=order_id,
        status=status,
        shipping_company=shipping_company,
        tracking_number=tracking_number,
    )

    if not order:
        return {"error": "Order not found"}, 404

    # =====================================================
    # Firebase shipment notification
    # =====================================================

    if status == "shipped":

        buyer_info = get_buyer_notification_info(
            buyer_id=order[1]
        )

        if buyer_info and buyer_info[1]:
            
            send_order_status_notification(
                fcm_token=buyer_info[1],
                user_name=buyer_info[0] or "Customer",
                order_id=str(order[0]),
                status="shipped",
            )
            
            return {
                "message": "Order status updated successfully",
                "order": {
                    "id": str(order[0]),
                    "buyer_id": str(order[1]),
                    "subtotal": float(order[2]),
                    "shipping_fee": float(order[3]),
                    "total_amount": float(order[4]),
                    "status": order[5],
                    "shipping_company": order[6],
                    "tracking_number": order[7],
                    "created_at": (
                        order[8].isoformat()
                        if order[8]
                        else None
                    ),
                },
            }, 200