"""
Artist profile service layer.

Business logic for creating, reading, updating, and soft-deleting artist
profiles. Returns (dict, status_code) tuples like auth_service.py.

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
from sqlalchemy.exc import IntegrityError

from app.models.artist_profile import ArtistProfile
from app.persistence.repositories.artist_profile_repo import ArtistProfileRepository
from app.persistence.repositories.user_repo import UserRepository

artist_profile_repo = ArtistProfileRepository()
user_repo = UserRepository()

# Fields an artist may set on create / update (never user_id or is_verified).
# The "_ARTIST_WRITABLE_FIELDS" variable is Private/Internal and Constant
# that means we can NOT used it in another files
_ARTIST_WRITABLE_FIELDS = frozenset(
    {"display_name", "city", "bio", "profile_image_url", "shipping_policy"}
)

# Private/Internal Constant 
_MAX_SHIPPING_POLICY_LEN = 5000


# --------------- Private Helpers ---------------
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
    # if the value already UUID object, return the value
    if isinstance(value, uuid.UUID):
        return value
    # if not make it UUID object
    return uuid.UUID(str(value))


def _resolve_user_id(jwt_identity):
    """
    Extract the users.id UUID from JWT identity.

    Tokens from register/login store identity as a plain UUID string.
    Some routes may use a dict shape instead — support both.
    """
    if jwt_identity is None:
        return None
    if isinstance(jwt_identity, dict):
        raw = jwt_identity.get("user_id") or jwt_identity.get("sub")
    else:
        raw = jwt_identity
    return _as_uuid(raw)


def _profile_to_dict(profile):
    """
    Serializes an ArtistProfile object into a JSON-compatible dictionary.
    Converts UUIDs to strings and datetime objects to ISO 8601 format (2026-05-14T13:45:30Z).

    Args:
        profile (ArtistProfile or None): The database model instance to serialize.

    Returns:
        dict or None: The serialized profile data, or None if the input is None.
    """
    if profile is None:
        return None
    return {
        "id": str(profile.id),
        "user_id": str(profile.user_id),
        "display_name": profile.display_name,
        "city": profile.city,
        "bio": profile.bio,
        "profile_image_url": profile.profile_image_url,
        "is_verified": profile.is_verified,
        "shipping_policy": profile.shipping_policy,
        "created_at": profile.created_at.isoformat() if profile.created_at else None,
        "updated_at": profile.updated_at.isoformat() if profile.updated_at else None,
    }


def _display_name_taken_by_other(profile_id, display_name):
    """
    Checks if a requested display name is already in use by a different artist profile.
    this prevents naming conflicts while allowing the current artist to keep their 
    own name during updates.
    Args:
        profile_id (uuid.UUID or str): The ID of the current artist's profile.
        display_name (str or None): The requested display name to check.

    Returns:
        bool: True if the name is taken by another artist, False otherwise.
    """
    if not display_name:
        return False
    
    # Clean up the text by removing leading/trailing spaces
    normalized = display_name.strip()

    # Query the database:
    # find a profile with the same name, BUT a different ID
    row = (
        ArtistProfile.query.filter(
            ArtistProfile.display_name == normalized,
            ArtistProfile.id != profile_id,
        ).first()
    )
    return row is not None


def _filter_writable_payload(data):
    """
    Filters the incoming request data to prevent mass-assignment vulnerabilities.
    Only fields explicitly listed in `_ARTIST_WRITABLE_FIELDS` are kept.

    Args:
        data (dict): The raw JSON payload from the user.

    Returns:
        dict: A sanitized dictionary containing only the allowed fields.
    """

    # Return empty dict if no data is provided
    if not data:
        return {}
    
    clean_data = {}
    # Iterate through the user's data
    for key, value in data.items():
        if key in _ARTIST_WRITABLE_FIELDS:
            clean_data[key] = value
    return clean_data


def _validate_shipping_policy(value):
    """
    Validates and sanitizes the shipping policy text.
    Ensures the input is a string and does not exceed the maximum allowed length.

    Args:
        value (str or None): The raw shipping policy text provided by the artist.

    Raises:
        ValueError: If the input is not a string type or if it exceeds the character limit.

    Returns:
        str or None: The cleaned text, or None if the input was empty/missing.
    """
    if value is None:
        return None
    if not isinstance(value, str):
        raise ValueError("Shipping policy must be text.")
    text = value.strip()
    if text == "":
        return None
    if len(text) > _MAX_SHIPPING_POLICY_LEN:
        raise ValueError(
            f"Shipping policy must be {_MAX_SHIPPING_POLICY_LEN} characters or fewer."
        )
    return text

# ----------------------------- Public Functions ---------------------------------

def bootstrap_artist_profile(user_id, data):
    """
    Create an empty artist profile right after registration.

    Skips the artist-role check used by create_artist_profile so every new
    account can call GET /artist-profiles/me. Idempotent if a profile exists.
    """
    uid = _resolve_user_id(user_id)
    if not uid:
        return {"error": "Invalid user id"}, 400

    existing = artist_profile_repo.get_active_by_user_id(uid)
    if existing:
        return {"message": "Artist profile already exists", "profile": _profile_to_dict(existing)}, 200

    email = (data or {}).get("email") or ""
    raw_name = (
        (data or {}).get("display_name")
        or (data or {}).get("name")
        or (data or {}).get("username")
        or (email.split("@")[0] if email else None)
        or "New Artist"
    )
    display_name = str(raw_name).strip()
    if len(display_name) < 3:
        display_name = "New Artist"
    display_name = display_name[:255]

    suffix = 1
    base = display_name
    while artist_profile_repo.display_name_is_taken(display_name):
        display_name = f"{base[:240]}_{suffix}"
        suffix += 1

    try:
        profile = ArtistProfile(
            user_id=uid,
            display_name=display_name,
        )
        artist_profile_repo.add(profile)
        return {
            "message": "Artist profile created",
            "profile": _profile_to_dict(profile),
        }, 201
    except ValueError as e:
        return {"error": str(e)}, 400
    except IntegrityError:
        return {"error": "Display name is already taken"}, 400
    except Exception:
        return {"error": "An internal error occurred"}, 500


def create_artist_profile(user_id, data):
    """
    Create a new artist profile or restore a soft-deleted one for this user.

    Expects data with at least display_name (required for a brand-new profile).
    """
    uid = _as_uuid(user_id)
    user = user_repo.get_user_by_id(uid)
    if not user:
        return {"error": "User not found"}, 404

    if getattr(user, "system_role", None) != "artist":
        return {"error": "Only users with the artist role can create a profile"}, 403
    
    # -------- Checking State & Filtering --------

    active = artist_profile_repo.get_active_by_user_id(uid)
    if active:
        return {"error": "Artist profile already exists"}, 400

    stale = artist_profile_repo.get_any_by_user_id(uid)
    payload = _filter_writable_payload(data or {})

    # ------------- Restore deleted Profile ------------
    try:
        if stale is not None and stale.deleted_at is not None:
            display_name = payload.get("display_name")
            if not display_name:
                return {"error": "display_name is required"}, 400
            if _display_name_taken_by_other(stale.id, display_name):
                return {"error": "Display name is already taken"}, 400
            
            # used restore() function from BaseModel.py to Restore Profile
            # that is mean update deleted_at to None.
            stale.restore()

            # then update old data with new data
            update_data = {}
            for key in _ARTIST_WRITABLE_FIELDS:
                if key not in payload:
                    continue
                if key == "shipping_policy":
                    update_data[key] = _validate_shipping_policy(payload[key])
                else:
                    update_data[key] = payload[key]
            profile = artist_profile_repo.update(stale.id, update_data)
            return {"message": "Artist profile restored", "profile": _profile_to_dict(profile)}, 201
        
        # ------------ Create New Artist Profile ------------

        display_name = payload.get("display_name")
        if not display_name:
            return {"error": "display_name is required"}, 400
        if artist_profile_repo.display_name_is_taken(display_name):
            return {"error": "Display name is already taken"}, 400

        shipping = _validate_shipping_policy(payload.get("shipping_policy"))

        profile = ArtistProfile(
            user_id=uid,
            display_name=display_name,
            city=payload.get("city"),
            bio=payload.get("bio"),
            profile_image_url=payload.get("profile_image_url"),
            shipping_policy=shipping,
        )
        artist_profile_repo.add(profile)
        return {"message": "Artist profile created", "profile": _profile_to_dict(profile)}, 201
    
    # ------------ Error Handling -----------
    except ValueError as e:
        return {"error": str(e)}, 400
    except IntegrityError:
        return {"error": "Display name is already taken"}, 400
    except Exception:
        return {"error": "An internal error occurred"}, 500

# تجيب بروفايل الفنان نفسه (عشان صفحة "إعدادات حسابي")
def get_my_profile(user_id):
    """
    Retrieves the active artist profile for the authenticated user.

    Args:
        user_id: JWT identity (UUID string or dict with user_id).

    Returns:
        tuple: A tuple containing a JSON-serializable dictionary with the profile data 
        (or an error message) and the corresponding HTTP status code.
    """
    uid = _resolve_user_id(user_id)
    if not uid:
        return {"error": "Invalid user identity"}, 401

    # MUST match on artist_profiles.user_id — never artist_profiles.id.
    profile = (
        ArtistProfile.query.filter(
            ArtistProfile.user_id == uid,
            ArtistProfile.deleted_at.is_(None),
        ).first()
    )
    if not profile:
        return {"error": "Artist profile not found"}, 404
    return {"profile": _profile_to_dict(profile)}, 200

# تجيب بروفايل فنان معين عبر الـ ID الخاص فيه.
def get_profile_by_id(profile_id):
    """
    Retrieves a specific artist profile using its unique profile ID.
    Typically used for public-facing storefronts to view an artist's details.

    Args:
        profile_id (str or uuid.UUID): The unique ID of the target artist profile.

    Returns:
        tuple: A tuple containing a JSON-serializable dictionary with the profile data 
        (or an error message) and the 200/404 HTTP status code.
    """
    pid = _as_uuid(profile_id)
    profile = artist_profile_repo.get(pid)
    if not profile:
        return {"error": "Artist profile not found"}, 404
    return {"profile": _profile_to_dict(profile)}, 200

# تجيب البروفايل عبر الاسم
def get_profile_by_display_name(display_name):
    """
    Retrieves an active artist profile using their unique display name (handle).
    Useful for "Share Profile" features to create clean URLs.
    Example: 
        loven.com/ArtistName
    Instead of: 
        loven.com/123e4567-e89b-12d3-a456-426614174000
    
    Args:
        display_name (str): The requested display name to search for.

    Returns:
        tuple: A tuple containing a JSON-serializable dictionary with the profile data 
        (or an error message) and the appropriate HTTP status code (200, 400, or 404).
    """
    if not display_name or not str(display_name).strip():
        return {"error": "display_name is required"}, 400
    profile = artist_profile_repo.get_active_by_display_name(str(display_name))
    if not profile:
        return {"error": "Artist profile not found"}, 404
    return {"profile": _profile_to_dict(profile)}, 200

# تجيب قائمة بالفنانين
def list_artist_profiles(limit=20, offset=0):
    """
    Retrieves a paginated list of active artist profiles (newest first).
    Enforces maximum retrieval limits to optimize performance and prevent 
    server overload.

    Args:
        limit (int, optional): The maximum number of profiles to return (1-100). Defaults to 20.
        offset (int, optional): The number of profiles to skip. Defaults to 0.

    Returns:
        tuple: A dictionary containing the serialized profiles list and pagination metadata, 
        along with the HTTP status code (200 or 400).
    """
    try:
        limit = int(limit)
        offset = int(offset)
    except (TypeError, ValueError):
        return {"error": "limit and offset must be integers"}, 400
    if limit < 1 or limit > 100:
        return {"error": "limit must be between 1 and 100"}, 400
    if offset < 0:
        return {"error": "offset must be non-negative"}, 400

    rows = artist_profile_repo.list_active(limit=limit, offset=offset)
    return {
        "profiles": [_profile_to_dict(p) for p in rows],
        "limit": limit,
        "offset": offset,
    }, 200


def update_my_profile(user_id, data):
    """
    Updates the authenticated user's active artist profile.
    
    This function safely filters the incoming payload to allow only specific writable fields.
    It also validates the shipping policy length and ensures the requested display name 
    is not already taken by another artist.

    Args:
        user_id (str or uuid.UUID): The ID of the currently logged-in user.
        data (dict): The raw JSON payload containing the fields to update.

    Returns:
        tuple: A tuple containing a success/error message with the updated profile data,
        and the appropriate HTTP status code (200, 400, 404, or 500).
    """
    uid = _as_uuid(user_id)
    profile = artist_profile_repo.get_active_by_user_id(uid)
    if not profile:
        return {"error": "Artist profile not found"}, 404

    payload = _filter_writable_payload(data or {})
    if not payload:
        return {"error": "No valid fields to update"}, 400

    new_name = payload.get("display_name")
    if new_name is not None and new_name != profile.display_name:
        if _display_name_taken_by_other(profile.id, new_name):
            return {"error": "Display name is already taken"}, 400

    if "shipping_policy" in payload:
        payload["shipping_policy"] = _validate_shipping_policy(payload.get("shipping_policy"))

    try:
        updated = artist_profile_repo.update(profile.id, payload)
        if not updated:
            return {"error": "Artist profile not found"}, 404
        return {"message": "Profile updated", "profile": _profile_to_dict(updated)}, 200
    except ValueError as e:
        return {"error": str(e)}, 400
    except IntegrityError:
        return {"error": "Display name is already taken"}, 400
    except Exception:
        return {"error": "An internal error occurred"}, 500


def soft_delete_my_profile(user_id):
    """
    Soft-deletes the active artist profile for the authenticated user.
    
    This effectively suspends the profile by setting a 'deleted_at' timestamp 
    without removing the actual record from the database. This approach preserves 
    data integrity for linked entities (e.g., existing artworks, order histories) 
    and allows for future account restoration.

    Args:
        user_id (str or uuid.UUID): The ID of the currently logged-in user.

    Returns:
        tuple: A JSON-serializable dictionary containing a success or error message, 
        along with the appropriate HTTP status code (200, 404, or 500).
    """
    uid = _as_uuid(user_id)
    profile = artist_profile_repo.get_active_by_user_id(uid)
    if not profile:
        return {"error": "Artist profile not found"}, 404

    ok = artist_profile_repo.soft_delete(profile.id)
    if not ok:
        return {"error": "Could not delete profile"}, 500
    return {"message": "Artist profile deleted"}, 200
