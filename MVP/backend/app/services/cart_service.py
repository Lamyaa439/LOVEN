"""
Cart service layer.

Business logic for shopping cart operations. Returns (dict, status_code) tuples
like other services in this project.
"""

import uuid

from sqlalchemy.exc import IntegrityError

from app.models.cart import Cart
from app.models.cart_item import CartItem
from app.persistence.repositories.artwork_repo import ArtworkRepository
from app.persistence.repositories.cart_repo import CartRepository
from app.persistence.repositories.user_repo import UserRepository

cart_repo = CartRepository()
artwork_repo = ArtworkRepository()
user_repo = UserRepository()

# -------------------------- Private Helpers ---------------------------

def _as_uuid(value):
    """
    Normalize JWT / string IDs to uuid.UUID for DB comparisons.
    """
    if value is None:
        return None
    if isinstance(value, uuid.UUID):
        return value
    return uuid.UUID(str(value))

# تتأكد إن الكمية رقم صحيح موجب
def _parse_quantity(value, default=1):
    if value is None:
        return default
    try:
        quantity = int(value)
    except (TypeError, ValueError):
        raise ValueError("Quantity must be a whole number.")
    if quantity < 1:
        raise ValueError("Quantity must be at least 1.")
    return quantity


def _artwork_snapshot(artwork):
    """
    Creates a lightweight, JSON-serializable snapshot of essential artwork details.
    
    Args:
        artwork (Artwork): The artwork model instance.

    Returns:
        dict: A dictionary containing the artwork's core attributes, or None if input is None.
    """
    if artwork is None:
        return None
    
    return {
        "id": str(artwork.id),
        "title": artwork.title,
        "price": str(artwork.price) if artwork.price is not None else None,
        "shipping_fee": str(artwork.shipping_fee) if artwork.shipping_fee is not None else None,
        "artwork_image_url": artwork.artwork_image_url,
        "status": artwork.status,
        "quantity_available": artwork.quantity_available,
    }

# تحويل بيانات المنتج إلى قاموس، مع إمكانية عرض تفاصيل المنتج داخل السلة
# مثل: اسم وصورة المنتج
def _cart_item_to_dict(item, include_artwork=False):
    """
    Serializes a CartItem object into a dictionary.
    Optionally embeds the associated artwork's details. It smartly uses pre-loaded
    relationships (e.g., via joinedload) if available, falling back to a database 
    fetch if necessary.

        Args:
            item (CartItem): The cart item instance.
            include_artwork (bool): Whether to embed the artwork snapshot. Defaults to False.

        Returns:
            dict: A dictionary representation of the cart item.
    """
    data = item.to_dict()

    # Fast path: artwork is already pre-loaded in memory RAM
    # (e.g., via joinedload). No extra DB query needed.
    if include_artwork and item.artwork is not None:
        data["artwork"] = _artwork_snapshot(item.artwork)

    # Fallback path: artwork wasn't pre-loaded, so we explicitly 
    # fetch it from the DB.
    elif include_artwork:
        artwork = artwork_repo.get(item.artwork_id)
        data["artwork"] = _artwork_snapshot(artwork)

    return data

# ترتيب بيانات السلة ومنتجاتها
def _cart_payload(cart, items, include_artwork=False):
    """
    Constructs the final, structured dictionary (payload) representing the cart and its contents.
    Ready to be serialized into a JSON response for the API.
    """
    final_items = []

    # Loop through each item, translate it, and add it to final_items list
    for item in items:
        formatted_item = _cart_item_to_dict(item, include_artwork=include_artwork)
        final_items.append(formatted_item)
        
    return {
        "cart": cart.to_dict(),
        "items": final_items,
        "item_count": len(items),
    }

# تتأكد إذا المستخدم عنده سلة محذوفة وترجعها له او تنشئ سلة جديدة
def _get_or_create_cart(user_id):
    """
    Retrieves an active cart for the user, restores a soft-deleted one if found, 
    or creates a completely new cart if none exists.
    This safely handles database UNIQUE(user_id) constraints.
        Args:
            user_id: The UUID (or string representation) of the user.

        Returns:
            Cart: The active, restored, or newly created cart object.
    """
    uid = _as_uuid(user_id)

    # إذا السلة موجود ترجعها
    cart = cart_repo.get_by_user_id(uid)
    if cart:
        return cart
    
    # البحث عن اي سلة للمستخدم حتى لو كانت محذوفة وترجعها
    stale = cart_repo.get_any_by_user_id(uid)
    if stale is not None and stale.deleted_at is not None:
        stale.restore()
        return stale
    # في حالة إذا كانت السلة موجودة ولا فيها تاريخ حذف يرجعها
    if stale is not None:
        return stale
    
    # إذا كان مستخدم جديد ولا عنده سلة ننشئ له جديدة
    cart = Cart(user_id=uid)
    cart_repo.add(cart)
    return cart


def _get_user_cart(user_id):
    """
    Helper function to fetch a user's active cart after ensuring the user_id is a valid UUID.

    Args:
        user_id: The UUID or string representation of the user.

    Returns:
        Cart: The active cart object, or None if not found.
    """
    uid = _as_uuid(user_id)
    return cart_repo.get_by_user_id(uid)

# تتأكد إن السلة تنتمي للمستخدم
def _item_belongs_to_user(item, user_id):
    """
    Security check to verify if a specific cart item actually belongs to the requesting user.
    Args:
        item (CartItem): The cart item instance.
        user_id: The UUID of the requesting user.
    Returns:
        bool: True if the item belongs to the user's active cart, False otherwise.
    """
    if not item:
        return False
    
    cart = _get_user_cart(user_id)
    # نتأكد إن السلة موجودة
    if cart is None:
        return False
    
    # ID نتأكد من تطابق ال
    if item.cart_id == cart.id:
        return True
    else:
        return False

# تتأكد من توفر المنتج وإذا يقدر المستخدم يضيفها للسلة أو لا
def _validate_artwork_for_cart(artwork_id):
    """
    Validates whether an artwork exists and is eligible to be added to a cart.
    Implements business rules (e.g., checking if the status is 'available').

        Args:
            artwork_id: The UUID of the artwork.

        Returns:
            tuple: A pair of (Artwork_Object, Error_Response_Tuple). 
            If successful, returns (artwork, None). 
            If validation fails, returns (None, (error_dict, status_code)).
    """
    artwork = artwork_repo.get(_as_uuid(artwork_id))

    # إذا المنتج غير موجود أو محذوف
    if not artwork:
        return None, ({"error": "Artwork not found"}, 404)
    # إذا كان المنتج غير متاح
    if artwork.status != "available":
        return None, ({"error": "Artwork is not available for purchase"}, 400)
    # إذا كان المنتج موجود ومتاح
    return artwork, None


# ----------------------------- Public Functions ---------------------------------


def get_cart(user_id, include_artwork=True):
    """
    Retrieves the active cart and its items for a specific user.
    Gracefully handles users without an active cart by returning an empty, 
    structured payload with a 200 status, rather than an error.

    Args:
        user_id: The UUID of the requesting user.
        include_artwork (bool): Whether to include full artwork details in the response. Defaults to True.

    Returns:
        tuple: A pair containing the response dictionary (payload or error message) and the HTTP status code (200 or 404).
    """
    uid = _as_uuid(user_id)
    # نتأكد المستخدم موجود
    if not user_repo.get_user_by_id(uid):
        return {"error": "User not found"}, 404
    # نرجع السلة وقائمة المنتجات داخلها
    cart, items = cart_repo.get_by_user_id_with_items(uid)
    # إذا لسه ما أضاف منتجات للسلة
    if not cart:
        return {
            "cart": None,
            "items": [],
            "item_count": 0,
        }, 200

    return _cart_payload(cart, items, include_artwork=include_artwork), 200


def add_to_cart(user_id, data):
    """
    Add an artwork to the cart or increase quantity if it already exists.

    Expects data with:
        - artwork_id (required)
        - quantity (optional, default 1)
    """
    # -------- Input Validation --------
    uid = _as_uuid(user_id)
    # نتأكد إن المستخدم موجود
    if not user_repo.get_user_by_id(uid):
        return {"error": "User not found"}, 404
    # نتأكد من بيانات المنتج
    payload = data or {}
    artwork_id = payload.get("artwork_id")
    if not artwork_id:
        return {"error": "artwork_id is required"}, 400
    # نتأكد إن الكمية رقم صحيح موجب
    try:
        quantity = _parse_quantity(payload.get("quantity", 1))
    except ValueError as e:
        return {"error": str(e)}, 400
    
    # --------- Business Rules ---------
    # نتأكد إن المنتج موجود
    artwork, err = _validate_artwork_for_cart(artwork_id)
    if err:
        return err
    
    # الفنان ما يقدر يشتري عمله الخاص
    if artwork.artist and artwork.artist.user_id == uid:
        return {"error": "Artists cannot buy their own artwork"}, 403
    
    # نتأكد إن المخزون المطلوب إضافته للسلة متوفر
    if quantity > artwork.quantity_available:
        return {"error": "Requested quantity exceeds available stock"}, 400
    
    # --------- Core Logic ----------
    try:
        cart = _get_or_create_cart(uid)
        aid = _as_uuid(artwork_id)
        existing = cart_repo.get_item_by_cart_and_artwork(cart.id, aid)

        # إذا المنتج موجود في السلة نزيد الكمية
        if existing:
            new_qty = existing.quantity + quantity
            if new_qty > artwork.quantity_available:
                return {"error": "Requested quantity exceeds available stock"}, 400
            
            updated = cart_repo.increment_quantity(existing.id, quantity)
            if not updated:
                return {"error": "Could not update cart item"}, 500
            
            return {
                "message": "Cart updated",
                "item": _cart_item_to_dict(updated, include_artwork=True),
            }, 200
        
        # إذا المنتج مب موجود في السلة ننشئه ونحفظه في السلة
        item = CartItem(cart_id=cart.id, artwork_id=aid, quantity=quantity)
        cart_repo.add_item(item)
        return {
            "message": "Item added to cart",
            "item": _cart_item_to_dict(item, include_artwork=True),
        }, 201
    # ----------------- Exception Handling ------------------
    except ValueError as e:
        return {"error": str(e)}, 400
    except IntegrityError:
        return {"error": "Could not add item to cart"}, 400
    except Exception:
        return {"error": "An internal error occurred"}, 500

# التحديث المباشر للمنتج داخل السلة
def update_cart_item(user_id, item_id, data):
    """
    Set the quantity for a cart line (replace, not increment).

    Expects data with:
        - quantity (required)
    """
    uid = _as_uuid(user_id)
    # نتأكد المستخدم موجود
    if not user_repo.get_user_by_id(uid):
        return {"error": "User not found"}, 404
    
    payload = data or {}
    # نتأكد إن الكمية موجودة في البيانات
    if payload.get("quantity") is None:
        return {"error": "quantity is required"}, 400
    # نتأكد إن الكمية رقم صحيح وموجب
    try:
        quantity = _parse_quantity(payload.get("quantity"))
    except ValueError as e:
        return {"error": str(e)}, 400
    
    # البحث عن المنتج داخل السلة
    item = cart_repo.get_item(_as_uuid(item_id))
    if not item:
        return {"error": "Cart item not found"}, 404
    # إذا حاول يعدل منتجات سلة مهب سلته
    if not _item_belongs_to_user(item, uid):
        return {"error": "Access denied"}, 403
    # التأكد إن المنتج مازال متاح للبيع
    artwork, err = _validate_artwork_for_cart(item.artwork_id)
    if err:
        return err
    # فحص المخزون للمنتج المطلوب 
    if quantity > artwork.quantity_available:
        return {"error": "Requested quantity exceeds available stock"}, 400

    try:
        updated = cart_repo.update_item(item.id, {"quantity": quantity})
        if not updated:
            return {"error": "Cart item not found"}, 404
        return {
            "message": "Cart item updated",
            "item": _cart_item_to_dict(updated, include_artwork=True),
        }, 200
    except ValueError as e:
        return {"error": str(e)}, 400
    except Exception:
        return {"error": "An internal error occurred"}, 500

# حذف منتج من السلة
def remove_cart_item(user_id, item_id):
    """
    Safely removes a single item from the user's cart (soft delete).
    Includes strict authorization checks to ensure users can only remove their own items.

    Args:
        user_id: The UUID of the requesting user.
        item_id: The UUID of the cart item to remove.

    Returns:
        tuple: A success message with a 200 status, or an error payload.
    """
    uid = _as_uuid(user_id)
    # التأكد إن المستخدم موجود
    if not user_repo.get_user_by_id(uid):
        return {"error": "User not found"}, 404
    # نتأكد إن المنتج المراد حذفه موجود 
    item = cart_repo.get_item(_as_uuid(item_id))
    if not item:
        return {"error": "Cart item not found"}, 404
    if not _item_belongs_to_user(item, uid):
        return {"error": "Access denied"}, 403

    ok = cart_repo.remove_item(item.id)
    if not ok:
        return {"error": "Could not remove cart item"}, 500
    return {"message": "Item removed from cart"}, 200

# حذف أو تفريغ السلة كاملة إذا تمت عملية الدفع
def clear_cart(user_id):
    """
    Empties the user's entire cart by soft-deleting all active lines.
    Designed to be idempotent; safely returns a 200 status even if the cart is already empty.

    Args:
        user_id: The UUID of the requesting user.

    Returns:
        tuple: A success payload indicating the number of cleared items،
        or a 500 error on failure.
    """
    uid = _as_uuid(user_id)
    cart = _get_user_cart(uid)
    if not cart:
        return {"message": "Cart is already empty", "cleared": 0}, 200

    try:
        cleared = cart_repo.clear_items(cart.id)
        return {"message": "Cart cleared", "cleared": cleared}, 200
    except Exception:
        return {"error": "An internal error occurred"}, 500
