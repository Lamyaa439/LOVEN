"""
API tests for single-order retrieval route.

Mocks OrderFacade — no live PostgreSQL required.
"""

import unittest
import uuid
from unittest.mock import patch

from flask_jwt_extended import create_access_token

from app import create_app
from app.services.facade.order_facade import OrderFacade


def _order_payload(*, order_id=None, buyer_id=None):
    order_id = order_id or uuid.uuid4()
    buyer_id = buyer_id or uuid.uuid4()
    return {
        "id": str(order_id),
        "buyer_id": str(buyer_id),
        "subtotal": 150.0,
        "shipping_fee": 20.0,
        "total_amount": 170.0,
        "status": "paid",
        "shipping_company": None,
        "tracking_number": None,
        "created_at": "2026-06-02T12:00:00",
        "updated_at": "2026-06-02T12:00:00",
        "items": [
            {
                "id": str(uuid.uuid4()),
                "order_id": str(order_id),
                "artwork_id": str(uuid.uuid4()),
                "quantity": 1,
                "price_at_purchase": 150.0,
                "created_at": "2026-06-02T12:00:00",
            }
        ],
    }


class OrdersApiTestCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app()
        self.client = self.app.test_client()
        self.user_id = str(uuid.uuid4())
        self.order_id = str(uuid.uuid4())

    def _auth_headers(self, user_id):
        with self.app.app_context():
            token = create_access_token(identity=user_id)
        return {"Authorization": f"Bearer {token}"}

    @patch.object(OrderFacade, "get_order")
    def test_authenticated_user_can_fetch_single_order(self, mock_get_order):
        order = _order_payload(order_id=self.order_id, buyer_id=self.user_id)
        mock_get_order.return_value = ({"order": order}, 200)

        response = self.client.get(
            f"/api/v1/orders/{self.order_id}",
            headers=self._auth_headers(self.user_id),
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["order"]["id"], self.order_id)
        self.assertEqual(len(response.json["order"]["items"]), 1)
        mock_get_order.assert_called_once_with(
            order_id=self.order_id,
            user_id=self.user_id,
            role=None,
        )

    def test_single_order_requires_authentication(self):
        response = self.client.get(f"/api/v1/orders/{self.order_id}")

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json["error"], "Authorization token required")

    @patch.object(OrderFacade, "get_order")
    def test_single_order_forbidden_for_unauthorized_user(self, mock_get_order):
        mock_get_order.return_value = ({"error": "Forbidden"}, 403)

        response = self.client.get(
            f"/api/v1/orders/{self.order_id}",
            headers=self._auth_headers(str(uuid.uuid4())),
        )

        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json["error"], "Forbidden")

    @patch.object(OrderFacade, "get_order")
    def test_single_order_not_found(self, mock_get_order):
        mock_get_order.return_value = ({"error": "Order not found"}, 404)

        response = self.client.get(
            f"/api/v1/orders/{self.order_id}",
            headers=self._auth_headers(self.user_id),
        )

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.json["error"], "Order not found")


if __name__ == "__main__":
    unittest.main()
