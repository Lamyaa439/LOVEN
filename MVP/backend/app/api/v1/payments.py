from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.services.facade.payment_facade import PaymentFacade


payments_bp = Blueprint("payments", __name__)


def get_authenticated_user_id():
    """Extract the current user's ID from the JWT token."""
    current_user_identity = get_jwt_identity()

    if isinstance(current_user_identity, dict):
        return current_user_identity.get("user_id")

    return current_user_identity


@payments_bp.post("/orders/<order_id>/initiate")
@jwt_required()
def initiate_order_payment(order_id):
    """
    Create (or return) a pending payment record before Moyasar SDK checkout.

    The buyer is always taken from the JWT — never from the request body.
    """
    buyer_id = get_authenticated_user_id()

    result, status_code = PaymentFacade.initiate(
        order_id=order_id,
        buyer_id=buyer_id,
    )

    return jsonify(result), status_code


@payments_bp.post("/orders/<order_id>/verify")
@jwt_required()
def verify_order_payment(order_id):
    """
    Verify a Moyasar payment after the Flutter SDK captures it.

    Expected body:
    {
        "moyasar_payment_id": "pay_abc123"
    }
    """
    data = request.get_json() or {}
    moyasar_payment_id = data.get("moyasar_payment_id")
    buyer_id = get_authenticated_user_id()

    result, status_code = PaymentFacade.verify(
        order_id=order_id,
        moyasar_payment_id=moyasar_payment_id,
        buyer_id=buyer_id,
    )

    return jsonify(result), status_code


@payments_bp.get("/orders/<order_id>")
@jwt_required()
def get_order_payment(order_id):
    """Return the payment record for an order owned by the authenticated buyer."""
    buyer_id = get_authenticated_user_id()

    result, status_code = PaymentFacade.get_for_order(
        order_id=order_id,
        buyer_id=buyer_id,
    )

    return jsonify(result), status_code
