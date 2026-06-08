from app.services.order_service import (
    create_user_order,
    get_user_orders,
    get_artist_orders,
    get_order_by_id,
    change_order_status,
)

# =========================================================
# Facade: OrderFacade
# Description:
# Provides a clean orchestration layer for order management.
#
# Responsibilities:
# - Keep API routes thin
# - Delegate business logic to service layer
# - Coordinate future integrations:
#   - payments
#   - inventory management
#   - Firebase notifications
# =========================================================


class OrderFacade:

    @staticmethod
    def create_order(data):
        """
        Create a customer order.
        """
        return create_user_order(data)

    @staticmethod
    def get_customer_orders(buyer_id):
        """
        Retrieve all orders placed by a buyer.
        """
        return get_user_orders(buyer_id)

    @staticmethod
    def get_artist_incoming_orders(artist_profile_id):
        """
        Retrieve incoming orders for an artist.
        """
        return get_artist_orders(artist_profile_id)

    @staticmethod
    def get_order(order_id, user_id, role=None):
        """
        Retrieve a single order when the caller is authorized.
        """
        return get_order_by_id(order_id, user_id, role=role)

    @staticmethod
    def update_status(
        order_id,
        status,
        shipping_company=None,
        tracking_number=None,
    ):
        """
        Update order shipment/status information.
        """

        return change_order_status(
            order_id,
            status,
            shipping_company,
            tracking_number,
        )