from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.services.facade.cart_facade import CartFacade

carts_bp = Blueprint("carts", __name__)

# ----------------- Helper Functions -----------------
def _json_body():
    """
    Safely extracts the JSON payload from the incoming request.
    Returns an empty dictionary if the payload is missing or invalid to prevent crashes.
    """
    return request.get_json(silent=True) or {}


def _include_artwork_from_query():
    """
    Parses the 'include_artwork' query parameter into a boolean.
    Defaults to True, evaluating to False only for explicitly negative strings ('false', '0', 'no').
    """
    raw = request.args.get("include_artwork", "true")
    return str(raw).strip().lower() not in ("false", "0", "no")

# --------------- Routes (API) ----------------

# عرض السلة
@carts_bp.get("/")
@jwt_required()
def get_cart():
    """
    Return the authenticated user's cart and line items.

    Query params:
        include_artwork: true or false (default true)
    """
    result, status_code = CartFacade.get(
        get_jwt_identity(),
        include_artwork=_include_artwork_from_query(),
    )
    return jsonify(result), status_code

# إضافة منتج للسلة
@carts_bp.post("/items")
@jwt_required()
def add_cart_item():
    """
    Add an artwork to the cart or increase quantity if already present.

    JSON body:
        - artwork_id (required)
        - quantity (optional, default 1)
    """
    data = _json_body()
    if not data.get("artwork_id"):
        return jsonify({"error": "artwork_id is required"}), 400

    result, status_code = CartFacade.add(get_jwt_identity(), data)
    return jsonify(result), status_code

# تحديث كمية منتج داخل السلة
@carts_bp.patch("/items/<item_id>")
@jwt_required()
def update_cart_item(item_id):
    """
    Set quantity on a cart line (replace, not increment).

    JSON body:
        - quantity (required)
    """
    data = _json_body()
    if data.get("quantity") is None:
        return jsonify({"error": "quantity is required"}), 400

    result, status_code = CartFacade.update_item(
        get_jwt_identity(), item_id, data
    )
    return jsonify(result), status_code

# حذف منتج واحد داخل السلة
@carts_bp.delete("/items/<item_id>")
@jwt_required()
def remove_cart_item(item_id):
    """Remove one line from the cart."""
    result, status_code = CartFacade.remove_item(get_jwt_identity(), item_id)
    return jsonify(result), status_code

# حذف السلة بالكامل
@carts_bp.delete("/")
@jwt_required()
def clear_cart():
    """Remove all items from the cart."""
    result, status_code = CartFacade.clear(get_jwt_identity())
    return jsonify(result), status_code
