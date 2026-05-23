"""
Artwork service layer.

Business logic for creating, reading, updating, and soft-deleting artwork
listings. Returns (dict, status_code) tuples like auth_service.py and
artists_profiles_service.py.

API HTTP Status Codes Reference:
---------------------------------
* 200 (OK): The request was successful, and the expected data is returned.
* 201 (Created): A new resource (e.g., artist profile) was successfully created.
* 400 (Bad Request): Client-side error. Invalid input, missing fields, or validation failure.
* 403 (Forbidden): Permission denied. The user lacks the required role (e.g., not an artist).
* 404 (Not Found): The requested resource (e.g., profile or user ID) does not exist.
* 500 (Internal Server Error): An unexpected server-side issue or database failure.

"""

import uuid
from decimal import Decimal

from sqlalchemy.exc import IntegrityError

from app.persistence.repositories.user_repo import UserRepository
from app.models.artwork import Artwork
from app.persistence.repositories.artwork_repo import ArtworkRepository
from app.persistence.repositories.artist_profile_repo import ArtistProfileRepository

artwork_repo = ArtworkRepository()
artist_profile_repo = ArtistProfileRepository()
user_repo = UserRepository()

# -------------------- Private/Internal Constant --------------------


# Fields an artist may set on create / update (artist_profile_id is set server-side).
# الحقول المسموح للفنان بتعديلها في العمل الفني
# frozenset: An immutable (unchangeable) version of a Python set
_ARTIST_WRITABLE_FIELDS = frozenset(
    {
        "title",
        "description",
        "price",
        "quantity_available",
        "shipping_fee",
        "artwork_image_url",
        "status",
    }
)

# ---------------------- Private Helpers ----------------------

def _as_uuid(value):
    """
    Normalize JWT / string IDs to uuid.UUID for DB comparisons.

     Args:
        value (str or uuid.UUID): The ID to normalize. Can be a string 
        or a UUID object.

      Returns: 
        uuid.UUID or None: A valid UUID object, or None if the input was None.
    """
    if value is None:
        return None
    if isinstance(value, uuid.UUID):
        return value
    return uuid.UUID(str(value))

# take an object of Artwork and make it dict(JSON)
def _artwork_to_dict(artwork):
    """
    Serializes an Artwork SQLAlchemy model into a JSON-compatible dictionary.
    
    Safely converts complex Python objects (UUIDs, Decimals, Datetimes) into 
    standard strings to prevent JSON serialization errors and preserve 
    financial precision (e.g., converting Decimal prices to strings).

    Args:
        artwork (Artwork or None): The artwork model instance to serialize.

    Returns:
        dict or None: A dictionary containing the artwork data, or None if input is None.
    """
    if artwork is None:
        return None
    
    price = artwork.price
    fee = artwork.shipping_fee
    return {
        "id": str(artwork.id),
        "artist_profile_id": str(artwork.artist_profile_id),
        "title": artwork.title,
        "description": artwork.description,
        "price": str(price) if price is not None else None,
        "quantity_available": artwork.quantity_available,
        "shipping_fee": str(fee) if fee is not None else None,
        "artwork_image_url": artwork.artwork_image_url,
        "status": artwork.status,
        "created_at": artwork.created_at.isoformat() if artwork.created_at else None,
        "updated_at": artwork.updated_at.isoformat() if artwork.updated_at else None,
    }


def _filter_writable_payload(data):
    """
    Sanitizes the incoming request payload by stripping out unapproved fields.
    
    This acts as a security measure against Mass Assignment vulnerabilities, 
    ensuring that clients can only insert or update safely allowed fields 
    (defined in _ARTIST_WRITABLE_FIELDS).

    Args:
        data (dict or None): The raw JSON data sent by the client.

    Returns:
        dict: A filtered dictionary containing only the explicitly permitted keys.
    """
    # Return empty dict if no data is provided
    if not data:
        return {}
    
    safe_data = {}

    # Iterate through the user's data
    for key, value in data.items():
        if key in _ARTIST_WRITABLE_FIELDS:
            safe_data[key] = value
    return safe_data



def _parse_pagination(limit, offset, max_limit=100):
    """
    Validates limit and offset. Returns (limit, offset, error).
    """
    # Attempt to cast inputs to integers
    try:
        limit = int(limit)
        offset = int(offset)
    except (TypeError, ValueError):
        error_msg = ({"error": "limit and offset must be integers"}, 400)
        return None, None, error_msg

    # Ensure limit is within the allowed bounds (1 to max_limit) 
    if (limit < 1) or (limit > max_limit):
        error_msg = ({"error": f"limit must be between 1 and {max_limit}"}, 400)
        return None, None, error_msg
    
    # Ensure offset is not a negative number
    if offset < 0:
        error_msg = ({"error": "offset must be non-negative"}, 400)
        return None, None, error_msg
    
    return limit, offset, None


def _profile_for_user(user_id):
    """
    Fetches the active artist profile for the given user ID. 
    Returns None if the user is not an artist or the profile is deleted.
    """
    return artist_profile_repo.get_active_by_user_id(_as_uuid(user_id))


def _artwork_owned_by_user(artwork, user_id):
    """
    Checks if a specific artwork belongs to the currently authenticated user.
    Returns True if owned by the user, False otherwise.
    """
    profile = _profile_for_user(user_id)
    if not profile or not artwork:
        return False
    return artwork.artist_profile_id == profile.id


# ----------------------------- Public Functions ---------------------------------

def create_artwork(user_id, data):
    """
    Create a listing owned by the caller's active artist profile.

    Required in data: title, price.
    Optional: description, quantity_available, shipping_fee, artwork_image_url, status.
    """

    # نتأكد إن المستخدم فنان
    user = user_repo.get_user_by_id(_as_uuid(user_id))

    if not user:
        return {"error": "User not found"}, 404

    if user.system_role != "artist":
        return {"error": "Only artists can upload artwork"}, 403

    # التحقق من هوية البائع (الفنان)
    profile = _profile_for_user(user_id)

    if not profile:
        return {"error": "Create an artist profile before listing artwork"}, 400
    
    # التحقق من البيانات المرسلة للعمل الفني
    payload = _filter_writable_payload(data or {})

    # العنوان والسعر بيانات إلزامية للعمل المراد بيعه
    title = payload.get("title")
    price = payload.get("price")
    if not title or price is None:
        return {"error": "title and price are required"}, 400
    
    # create an artwork object
    try:
        artwork = Artwork(
            artist_profile_id=profile.id,
            title=title,
            description=payload.get("description"),
            price=price,
            quantity_available=payload.get("quantity_available", 1),
            shipping_fee=payload.get("shipping_fee", Decimal("0")),
            artwork_image_url=payload.get("artwork_image_url"),
            status=payload.get("status", "available"),
        )
        artwork_repo.add(artwork)
        return {"message": "Artwork created", "artwork": _artwork_to_dict(artwork)}, 201
    # Error Handling
    except ValueError as e:
        # Catches invalid data types (e.g., letters instead of numbers for price)
        return {"error": str(e)}, 400
    except IntegrityError:
        # Catches DB rejections due to constraint violations or relational conflicts
        return {"error": "Could not create artwork"}, 400
    except Exception:
        # Generic fallback for unexpected crashes (e.g., sudden DB disconnection)
        return {"error": "An internal error occurred"}, 500

# (المشتري)لعرض تفاصيل العمل الفني للمستخدم
def get_artwork(artwork_id):
    """
    Fetches the details of a single artwork by its ID.
    Soft-deleted artworks are automatically ignored.
    
    Returns the serialized artwork data (200 OK) or an error (404 Not Found).
    """
    aid = _as_uuid(artwork_id)
    artwork = artwork_repo.get(aid)
    if not artwork:
        return {"error": "Artwork not found"}, 404
    return {"artwork": _artwork_to_dict(artwork)}, 200

# الصفحة الرئيسية للمتجر
def list_public_artworks(limit=20, offset=0, status="available"):
    """
    Paginated marketplace feed. Pass status=None to include all non-deleted statuses.
    """
    limit, offset, err = _parse_pagination(limit, offset)
    if err:
        return err
    rows = artwork_repo.list_public(limit=limit, offset=offset, status=status)

    public_artwork = []
    for artwork in rows:
        public_artwork.append(_artwork_to_dict(artwork))

    return {
        "artworks": public_artwork,
        "limit": limit,
        "offset": offset,
    }, 200

# محرك البحث
def search_artworks(query_text, limit=20, offset=0, status="available"):
    """
    Searches for artworks by title (case-insensitive) and returns a paginated list.
    
    By default, it only searches for 'available' artworks. It also validates 
    pagination and cleans up the search query text before returning the results.
    """
    limit, offset, err = _parse_pagination(limit, offset)
    if err:
        return err
    
    # نبحث حسب عنوان اللوحة
    # نجيب اللوحات من المستودع حسب كلمات البحث
    rows = artwork_repo.search_by_title(
        query_text, limit=limit, offset=offset, status=status
    )

    artwork_of_search = []
    for artwork in rows:
        artwork_of_search.append(_artwork_to_dict(artwork))

    return {
        "artworks": artwork_of_search,
        "limit": limit,
        "offset": offset,
        "query": (query_text or "").strip(),
    }, 200

# لوحة تحكم الفنان
# تعرض للفنان كل لوحاته الخاصة
def list_my_artworks(user_id, limit=20, offset=0):
    """
    Fetches a paginated list of all artworks belonging to the authenticated artist.
    
    It validates the user's artist profile first, then returns all their active 
    listings regardless of their current status (e.g., available, sold).
    """
    # نتأكد إن المستخدم فنان
    profile = _profile_for_user(user_id)
    if not profile:
        return {"error": "Artist profile not found"}, 404

    limit, offset, err = _parse_pagination(limit, offset)
    if err:
        return err
    
    # نطلب من المستودع يجيب كل اللوحات الخاصة لهذا الفنان
    rows = artwork_repo.list_active_by_artist(
        profile.id, limit=limit, offset=offset
    )

    my_artwork = []
    for artwork in rows:
        my_artwork.append(_artwork_to_dict(artwork))

    return {
        "artworks": my_artwork,
        "limit": limit,
        "offset": offset,
    }, 200

# لما المستخدم (المشتري) يدخل على بروفايل الفنان نجيب له كل اللوحات المتاحة لهذا الفنان
def list_artworks_for_profile(artist_profile_id, limit=20, offset=0, status="available"):
    """
    Fetches a public, paginated list of artworks for a specific artist profile.
    
    By default, it only returns 'available' artworks. If status is set to None, 
    it returns all non-deleted artworks. Results are always sorted from newest to oldest.
    """
    # نتأكد إن الفنان موجود
    pid = _as_uuid(artist_profile_id)
    profile = artist_profile_repo.get(pid)
    if not profile:
        return {"error": "Artist profile not found"}, 404
    
    limit, offset, err = _parse_pagination(limit, offset)
    if err:
        return err
    
    # search query (Find artist's artworks that are not deleted)
    search_query = Artwork.query.filter(
        Artwork.artist_profile_id == pid,
        Artwork.deleted_at.is_(None),
    )

    # Add status filter ONLY IF a specific status is requested
    if status is not None:
        search_query = search_query.filter(Artwork.status == status)

    # Sort by newest, apply pagination, and execute the search  
    rows = search_query.order_by(Artwork.created_at.desc()) \
        .limit(limit) \
        .offset(offset) \
        .all()
    
    list_artwork = []
    for artwork in rows:
        list_artwork.append(_artwork_to_dict(artwork))

    return {
        "artworks": list_artwork,
        "limit": limit,
        "offset": offset,
        "artist_profile_id": str(pid),
    }, 200

# تعديل أو تحديث معلومات العمل الفني للفنان
def update_artwork(user_id, artwork_id, data):
    """
    Updates an existing artwork listing with new data.
    
    Security checks ensure the artwork exists and is strictly owned by the caller.
    The incoming data is sanitized to allow only permitted fields to be updated.
    Returns the updated artwork on success, or appropriate error codes otherwise.
    """
    artwork = artwork_repo.get(_as_uuid(artwork_id))
    if not artwork:
        return {"error": "Artwork not found"}, 404
    if not _artwork_owned_by_user(artwork, user_id):
        return {"error": "Forbidden"}, 403

    payload = _filter_writable_payload(data or {})
    if not payload:
        return {"error": "No valid fields to update"}, 400

    try:
        updated = artwork_repo.update(artwork.id, payload)
        if not updated:
            return {"error": "Artwork not found"}, 404
        return {"message": "Artwork updated", "artwork": _artwork_to_dict(updated)}, 200
    except ValueError as e:
        return {"error": str(e)}, 400
    except IntegrityError:
        return {"error": "Could not update artwork"}, 400
    except Exception:
        return {"error": "An internal error occurred"}, 500


def soft_delete_artwork(user_id, artwork_id):
    """
    Performs a soft delete on an artwork, hiding it from the public marketplace 
    without permanently removing it from the database (preserving order history).
    
    Security checks ensure that the artwork exists and the caller is the actual owner.
    """

    artwork = artwork_repo.get(_as_uuid(artwork_id))
    if not artwork:
        return {"error": "Artwork not found"}, 404
    # نتأكد إن الفنان هو المالك لهذا العمل
    if not _artwork_owned_by_user(artwork, user_id):
        return {"error": "You do not have permission to modify this artwork"}, 403

    ok = artwork_repo.soft_delete(artwork.id)
    if not ok:
        return {"error": "Could not delete artwork"}, 500
    return {"message": "Artwork deleted"}, 200

# عدد الاعمال الفنية للفنان
def count_artworks_for_profile(artist_profile_id):
    """Public count of non-deleted artworks for an artist profile."""
    pid = _as_uuid(artist_profile_id)
    
    # نتحقق إن بروفايل الفنان موجود
    profile = artist_profile_repo.get(pid)
    if not profile:
        return {"error": "Artist profile not found"}, 404
    
    # حساب عدد الاعمال المنشورة و إرجاع النتيجة
    total_artworks = artwork_repo.count_by_artist(pid)
    response_data = {
        "artist_profile_id": str(pid),
        "count": total_artworks
    }
    return response_data, 200
