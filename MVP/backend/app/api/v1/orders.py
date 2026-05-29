from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required

from app.core.auth_utils import (
    get_authenticated_user_id,
    get_authenticated_user_role,
)

from app.persistence.repositories.artist_profile_repo import ArtistProfileRepository
from app.persistence.repositories.order_repo import order_repo
from app.services.facade.order_facade import OrderFacade

artist_profile_repo = ArtistProfileRepository()


# Order API routes.
# This file only handles HTTP input/output.
# The actual order logic stays in the facade, service, and repository layers.

order_bp = Blueprint("orders", __name__)


def _is_admin(role):
    """
    Check if the provided role belongs to a system administrator.
    """
    return role == "admin"


def _forbidden():
    """
    Generate a standardized 403 Forbidden JSON response for unauthorized access.
    """
    return jsonify({"error": "Forbidden"}), 403


def _user_owns_artist_profile(user_id, artist_profile_id):
    """
    Verify if the authenticated user is the legitimate owner of the specified artist profile.
    """
    profile = artist_profile_repo.get(artist_profile_id)
    if not profile:
        return False
    return str(profile.user_id) == str(user_id)


def _artist_can_update_order(user_id, order_id):
    """
    Validate that the user has an active artist profile and the specified order belongs to them.
    """
    profile = artist_profile_repo.get_active_by_user_id(user_id)
    if not profile:
        return False

    return order_repo.artist_has_order(profile.id, order_id)


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
                "quantity": 1
            }
        ]
    }

    Totals are validated against server-computed artwork prices; tampered
    amounts are rejected. Line prices are always taken from the database.
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
@jwt_required()
def view_buyer_orders(buyer_id):
    """
    Retrieve orders for a buyer.

    Authenticated users may only access their own buyer_id unless admin.
    Prefer GET /mine for the current user's orders.
    """
    user_id = get_authenticated_user_id()
    role = get_authenticated_user_role()

    if not _is_admin(role) and str(user_id) != str(buyer_id):
        return _forbidden()

    result, status_code = OrderFacade.get_customer_orders(
        buyer_id
    )

    return jsonify(result), status_code


@order_bp.get("/artist/<artist_profile_id>")
@jwt_required()
def view_artist_orders(artist_profile_id):
    """
    Retrieve incoming orders for an artist profile.

    Authenticated users may only access orders for a profile they own,
    unless admin.
    """
    user_id = get_authenticated_user_id()
    role = get_authenticated_user_role()

    if not _is_admin(role) and not _user_owns_artist_profile(user_id, artist_profile_id):
        return _forbidden()

    result, status_code = (
        OrderFacade.get_artist_incoming_orders(
            artist_profile_id
        )
    )

    return jsonify(result), status_code


@order_bp.patch("/<order_id>/status")
@jwt_required()
def update_status(order_id):
    """
    Update order status and shipment details.

    Only the artist who owns artworks in the order (or an admin) may update
    shipment status.
    """
    user_id = get_authenticated_user_id()
    role = get_authenticated_user_role()

    if not _is_admin(role) and not _artist_can_update_order(user_id, order_id):
        return _forbidden()

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