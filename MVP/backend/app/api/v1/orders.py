from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.services.facade.order_facade import OrderFacade


# Order API routes.
# This file only handles HTTP input/output.
# The actual order logic stays in the facade, service, and repository layers.

order_bp = Blueprint("orders", __name__)


def get_authenticated_user_id():
    """
    Extract the current user's ID from the JWT token.

    Supports both JWT formats used in the project:
    - sub as a direct UUID string
    - sub as a dictionary containing user_id
    """

    current_user_identity = get_jwt_identity()

    if isinstance(current_user_identity, dict):
        return current_user_identity.get("user_id")

    return current_user_identity


@order_bp.post("/")
@jwt_required()
def create_order():
    """
    Create an order for the authenticated buyer.

    The client no longer needs to send buyer_id.
    buyer_id is taken from the JWT token to prevent users
    from creating orders under another user's account.

    Expected body:
    {
        "subtotal": 150.00,
        "shipping_fee": 20.00,
        "total_amount": 170.00,
        "items": [
            {
                "artwork_id": "...",
                "quantity": 1,
                "price_at_purchase": 150.00
            }
        ]
    }
    """

    data = request.get_json() or {}

    # Trust JWT identity, not request body
    data["buyer_id"] = get_authenticated_user_id()

    result, status_code = OrderFacade.create_order(data)

    return jsonify(result), status_code


@order_bp.get("/mine")
@jwt_required()
def view_my_orders():
    """
    Retrieve orders for the authenticated buyer.

    This replaces the need for the frontend to pass buyer_id
    in the URL when the current user wants their own orders.
    """

    buyer_id = get_authenticated_user_id()

    result, status_code = OrderFacade.get_customer_orders(
        buyer_id
    )

    return jsonify(result), status_code


@order_bp.get("/buyer/<buyer_id>")
def view_buyer_orders(buyer_id):
    """
    Existing buyer lookup route.

    Kept temporarily for testing/backward compatibility.
    Prefer /mine for authenticated frontend usage.
    """

    result, status_code = OrderFacade.get_customer_orders(
        buyer_id
    )

    return jsonify(result), status_code


@order_bp.get("/artist/<artist_profile_id>")
def view_artist_orders(artist_profile_id):
    """
    Retrieve incoming orders for an artist profile.

    This route is kept unchanged for now because it depends
    on artist profile ownership rules.
    """

    result, status_code = (
        OrderFacade.get_artist_incoming_orders(
            artist_profile_id
        )
    )

    return jsonify(result), status_code


@order_bp.patch("/<order_id>/status")
def update_status(order_id):
    """
    Update order status and shipment details.

    Usually used when an artist marks an order as shipped.
    Role/ownership protection can be added once artist-order
    permission rules are finalized.
    """

    data = request.get_json() or {}

    status = data.get("status")
    shipping_company = data.get("shipping_company")
    tracking_number = data.get("tracking_number")

    result, status_code = OrderFacade.update_status(
        order_id,
        status,
        shipping_company=shipping_company,
        tracking_number=tracking_number,
    )

    return jsonify(result), status_code