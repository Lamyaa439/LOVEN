"""
Cart repository.

Handles database operations for Cart and CartItem models.
Inherits generic CRUD for Cart from SQLAlchemyRepository and adds
cart-specific lookups and line-item helpers.
"""

from datetime import datetime, timezone

from sqlalchemy import func, update
from sqlalchemy.orm import joinedload

from app.models.cart import Cart
from app.models.cart_item import CartItem
from app.persistence.repository import SQLAlchemyRepository


class CartRepository(SQLAlchemyRepository):
    def __init__(self):
        super().__init__(Cart)

    # =====================================================================
    # Cart reads
    # =====================================================================

    def get_by_user_id(self, user_id):
        """Active cart for a user (soft-deleted carts excluded)."""
        if not user_id:
            return None
        return self.get_by_attribute("user_id", user_id)

    def get_any_by_user_id(self, user_id):
        """
        Cart for a user including soft-deleted rows.
        Used before create to respect UNIQUE(user_id) on the table.
        """
        if not user_id:
            return None
        return self.model.query.filter_by(user_id=user_id).first()
    
    # لما المستخدم يدخل على السلة
    def get_by_user_id_with_items(self, user_id):
        """
        Fetch cart, line items, and artworks in one query.

        Returns:
            (cart, items): items is [] if no cart exists.
        """
        if not user_id:
            return None, []
        
        # استعلام عن السلة من قاعدة البيانات
        cart = (
            self.model.query.filter(
                self.model.user_id == user_id,
                # نتأكد إن السلة مب محذوفة
                self.model.deleted_at.is_(None),
            )
            .options(
                joinedload(Cart.items).joinedload(CartItem.artwork)
            )
            .first()
        )
        if not cart:
            return None, []
        
        # وهنا نتأكد إن المنتجات نفسها اللي داخل السلة غير محذوفة 
        active_items = []
        for item in cart.items:
            if item.deleted_at is None:
                active_items.append(item)

        def get_creation_data(item):
            """ترجع تاريخ إضافة المنتجات """
            return item.created_at
        
        # نرتب القائمة حسب التاريخ الاحدث
        active_items.sort(key=get_creation_data, reverse=True)   
        return cart, active_items

    def list_carts_needing_inactivity_reminder(self, cutoff_dt):
        """
        Return active carts whose latest cart/item activity is on/before cutoff.

        Requires at least one active line item. Uses the most recent timestamp
        across ``carts.updated_at`` and each active line's ``created_at`` /
        ``updated_at``. Notification dedupe remains in NotificationService.
        """
        if not cutoff_dt:
            return []

        last_activity = func.greatest(
            Cart.updated_at,
            func.max(
                func.greatest(
                    CartItem.updated_at,
                    CartItem.created_at,
                )
            ),
        )

        return (
            self.model.query
            .join(CartItem, CartItem.cart_id == Cart.id)
            .filter(Cart.deleted_at.is_(None))
            .filter(CartItem.deleted_at.is_(None))
            .group_by(Cart.id)
            .having(last_activity <= cutoff_dt)
            .all()
        )

    # =====================================================================
    # CartItem operations
    # =====================================================================

    # استعراض السلة في التطبيق
    def list_items_by_cart(self, cart_id):
        """
        Retrieves all active line items for a specific cart.
        Excludes soft-deleted items and orders the results in 
        descending order by creation date (newest first).

        Args:
            cart_id: The UUID of the target cart.

        Returns:
            list: A list of active CartItem objects, or an empty list 
            if cart_id is missing or invalid.
        """
        if not cart_id:
            return []
        # الاستعلام
        return (
            CartItem.query.filter(
                CartItem.cart_id == cart_id,
                CartItem.deleted_at.is_(None),
            )
            # ترتيب المنتجات حسب تاريخ الإضافة الاحدث اولاً
            .order_by(CartItem.created_at.desc())
            .all()
        )
    
    # هنا لما المستخدم يضيف المنتج للسلة مرتين نزيد كمية المنتج 
    # بدال ما نكرره مرتين في السلة
    def get_item_by_cart_and_artwork(self, cart_id, artwork_id):
        """Retrieves a specific, active cart item by its associated cart and artwork IDs.
        Useful for checking if an artwork already exists in the cart to update its quantity 
        instead of creating a duplicate entry.

        Args:
            cart_id: The UUID of the target cart.
            artwork_id: The UUID of the specific artwork.

        Returns:
            CartItem: The matching active cart item object, or None if not found or if IDs are invalid."""
        if not cart_id or not artwork_id:
            return None
        # الاستعلام:
        # يبحث عن السلة المحددة، بعدين يبحث عن المنتج (العمل الفني) المحدد
        return (
            CartItem.query.filter(
                CartItem.cart_id == cart_id,
                CartItem.artwork_id == artwork_id,
                CartItem.deleted_at.is_(None),
            ).first() # أول ما يشوف المنتج (العمل الفني) المطلوب يرجعه على طول
        )
    
    #  تبحث عن المنتج وتتأكد إنه مهب محذوف
    def get_item(self, item_id):
        """
        Retrieves a specific cart item by its primary key (ID).
        Automatically hides soft-deleted items by returning None.

        Args:
            item_id: The primary key of the CartItem.

        Returns:
            CartItem: The active cart item object, or None if not found or soft-deleted.
        """
        if not item_id:
            return None
        
        row = CartItem.query.get(item_id)
        if row and row.deleted_at is not None:
            return None
        return row
    
    # تحفظ المنتج داخل السلة
    def add_item(self, cart_item):
        """
        Persists a newly created CartItem to the database.
        Args:
            cart_item (CartItem): The cart item instance to be added.

        Returns:
            CartItem: The saved cart item object.
        """
        return self.save(cart_item)
    
    # تعديل على المنتجات داخل السلة
    def update_item(self, item_id, data):
        """
        Dynamically updates specific attributes of an active cart item.

        Args:
            item_id: The primary key of the CartItem to update.
            data (dict): A dictionary of fields and their new values (e.g., {"quantity": 2}).

        Returns:
            CartItem: The updated cart item object, or None if the item is not found or soft-deleted.
        """
        item = self.get_item(item_id)
        if not item:
            return None
        
        for key, value in data.items():
            setattr(item, key, value)
        return self.save(item)

    def increment_quantity(self, item_id, amount=1):
        """
        Atomically increment quantity for an active cart line.

        Args:
            item_id: CartItem primary key.
            amount (int): The positive or negative value to 
            add to the current quantity. Defaults to 1.

        Returns:
            Updated CartItem, or None if the row was not found / not active.
        """
        if not item_id or amount == 0:
            return self.get_item(item_id)

        stmt = (
            update(CartItem)
            .where(
                CartItem.id == item_id,
                CartItem.deleted_at.is_(None),
            )
            .values(quantity=CartItem.quantity + amount)
        )
        result = self.execute_and_commit(stmt)
        if result.rowcount == 0:
            return None
        return self.get_item(item_id)

    def remove_item(self, item_id):
        """
        Soft-deletes a specific cart item by setting its deleted_at timestamp.
        Args:
            item_id: The primary key of the CartItem to remove.
        Returns:
            bool: True if the item was successfully soft-deleted, False if not found or already deleted.
        """
        item = self.get_item(item_id)
        if not item:
            return False

        item.deleted_at = datetime.now(timezone.utc)
        self.save(item)
        return True
    
    # تستخدم بعد أمر الدفع أو الشراء
    def clear_items(self, cart_id):
        """
        Soft-delete all active lines in a cart with a single UPDATE.

        Returns:
            int: Number of rows updated.
        """
        if not cart_id:
            return 0

        now = datetime.now(timezone.utc)
        stmt = (
            update(CartItem)
            .where(
                CartItem.cart_id == cart_id,
                CartItem.deleted_at.is_(None),
            )
            .values(deleted_at=now)
        )
        result = self.execute_and_commit(stmt)
        return result.rowcount
    
    # حساب عدد المنتجات الموجودة في السلة
    def count_items_by_cart(self, cart_id):
        """
        Count of active lines in a cart.

        Args:
            cart_id: The UUID of the target cart.
        
        Returns:
            int: The count of active items, or 0 if the cart_id is missing/invalid.
        """
        if not cart_id:
            return 0
        
        return (
            CartItem.query.filter(
                CartItem.cart_id == cart_id,
                CartItem.deleted_at.is_(None),
            ).count()
        )
