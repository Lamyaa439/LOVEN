"""
Unit tests for single-order retrieval authorization in order_service.
"""

import unittest
import uuid
from unittest.mock import MagicMock, patch

from app.services.order_service import get_order_by_id


def _order(*, order_id=None, buyer_id=None):
    order = MagicMock()
    order.id = order_id or uuid.uuid4()
    order.buyer_id = buyer_id or uuid.uuid4()
    order.to_dict.return_value = {
        "id": str(order.id),
        "buyer_id": str(order.buyer_id),
        "status": "paid",
    }
    return order


def _order_item():
    item = MagicMock()
    item.to_dict.return_value = {
        "id": str(uuid.uuid4()),
        "quantity": 1,
    }
    return item


class GetOrderByIdTestCase(unittest.TestCase):
    @patch("app.services.order_service.artist_profile_repo")
    @patch("app.services.order_service.order_repo")
    def test_buyer_can_access_own_order(self, mock_order_repo, mock_artist_repo):
        buyer_id = uuid.uuid4()
        order = _order(buyer_id=buyer_id)
        item = _order_item()
        mock_order_repo.get_order_with_items.return_value = (order, [item])

        result, status_code = get_order_by_id(order.id, buyer_id)

        self.assertEqual(status_code, 200)
        self.assertEqual(result["order"]["id"], str(order.id))
        self.assertEqual(result["order"]["items"], [item.to_dict.return_value])
        mock_artist_repo.get_active_by_user_id.assert_not_called()

    @patch("app.services.order_service.artist_profile_repo")
    @patch("app.services.order_service.order_repo")
    def test_artist_can_access_order_with_their_artwork(
        self,
        mock_order_repo,
        mock_artist_repo,
    ):
        artist_user_id = uuid.uuid4()
        buyer_id = uuid.uuid4()
        order = _order(buyer_id=buyer_id)
        profile = MagicMock()
        profile.id = uuid.uuid4()
        mock_order_repo.get_order_with_items.return_value = (order, [])
        mock_artist_repo.get_active_by_user_id.return_value = profile
        mock_order_repo.artist_has_order.return_value = True

        result, status_code = get_order_by_id(order.id, artist_user_id)

        self.assertEqual(status_code, 200)
        mock_order_repo.artist_has_order.assert_called_once_with(
            profile.id,
            order.id,
        )

    @patch("app.services.order_service.artist_profile_repo")
    @patch("app.services.order_service.order_repo")
    def test_unrelated_user_gets_forbidden(self, mock_order_repo, mock_artist_repo):
        order = _order()
        mock_order_repo.get_order_with_items.return_value = (order, [])
        mock_artist_repo.get_active_by_user_id.return_value = None

        result, status_code = get_order_by_id(
            order.id,
            uuid.uuid4(),
        )

        self.assertEqual(status_code, 403)
        self.assertEqual(result["error"], "Forbidden")

    @patch("app.services.order_service.order_repo")
    def test_admin_can_access_any_order(self, mock_order_repo):
        order = _order()
        mock_order_repo.get_order_with_items.return_value = (order, [])

        result, status_code = get_order_by_id(
            order.id,
            uuid.uuid4(),
            role="admin",
        )

        self.assertEqual(status_code, 200)
        self.assertEqual(result["order"]["id"], str(order.id))

    @patch("app.services.order_service.order_repo")
    def test_missing_order_returns_not_found(self, mock_order_repo):
        mock_order_repo.get_order_with_items.return_value = (None, [])

        result, status_code = get_order_by_id(uuid.uuid4(), uuid.uuid4())

        self.assertEqual(status_code, 404)
        self.assertEqual(result["error"], "Order not found")


if __name__ == "__main__":
    unittest.main()
