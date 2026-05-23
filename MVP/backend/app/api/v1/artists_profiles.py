from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.services.facade.artists_profile_facade import ArtistsProfileFacade
from app.services.facade.artwork_facade import ArtworkFacade

artist_profiles_bp = Blueprint(
    "artist_profiles", __name__, url_prefix="/artist-profiles"
)

# ----------------- Helper Functions -----------------

def _json_body():
    """
    Safely extracts the JSON payload from the current request.
    
    Returns:
        dict: The parsed JSON data if valid and present; otherwise, an empty dictionary.
    """
    return request.get_json(silent=True) or {}


def _pagination_args():
    """
    Retrieves pagination parameters (limit and offset) from the request's query string.

    Returns:
        tuple: A pair of integers (limit, offset). Defaults to (20, 0) if not provided.
    """
    limit = request.args.get("limit", 20, type=int)
    offset = request.args.get("offset", 0, type=int)
    return limit, offset

# فلترة للأعمال الفنية حسب حالتها (متاح، مباع ، ..)
def _optional_status(default="available"):
    """
    Parses an optional status filter from the query parameters.
    
    Args:
        default (str): The status to use if none is provided. Defaults to "available".
        
    Returns:
        str or None: The cleaned status string, or None if the status is explicitly 
        set to "all" or left empty.
    """
    raw = request.args.get("status", default)
    if raw is None or str(raw).strip().lower() in ("", "all"):
        return None
    return str(raw).strip()

# --------------- Routes (API) ----------------

# إنشاء بروفايل الفنان
@artist_profiles_bp.post("")
@jwt_required()
def create_profile():
    """
    Create (or restore) the authenticated user's artist profile.

    JSON body:
        - display_name (required for new profiles)
        - city, bio, shipping_policy, profile_image_url (optional)
    """
    data = _json_body()
    if not data.get("display_name"):
        return jsonify({"error": "display_name is required"}), 400

    result, status_code = ArtistsProfileFacade.create(get_jwt_identity(), data)
    return jsonify(result), status_code

# استعراض البروفايل 
@artist_profiles_bp.route("/me", methods=["GET", "OPTIONS"])
@jwt_required(optional=True)
def get_my_profile():
    if request.method == "OPTIONS":
        return jsonify({}), 200

    result, status_code = ArtistsProfileFacade.get_my_profile(get_jwt_identity())
    return jsonify(result), status_code

# تحديث البروفايل
@artist_profiles_bp.patch("/me")
@jwt_required()
def update_my_profile():
    """
    Update the authenticated user's artist profile.

    JSON body (any of):
        display_name, city, bio, shipping_policy, profile_image_url
    """
    data = _json_body()
    if not data:
        return jsonify({"error": "Request body is required"}), 400

    result, status_code = ArtistsProfileFacade.update(get_jwt_identity(), data)
    return jsonify(result), status_code

# حذف البروفايل
@artist_profiles_bp.delete("/me")
@jwt_required()
def delete_my_profile():
    """Soft-delete the authenticated user's artist profile."""
    result, status_code = ArtistsProfileFacade.delete(get_jwt_identity())
    return jsonify(result), status_code

# استعراض قائمة الفنانين للمستخدم العادي
@artist_profiles_bp.get("")
def list_profiles():
    """Public paginated list of active artist profiles."""
    limit, offset = _pagination_args()
    result, status_code = ArtistsProfileFacade.list_profiles(
        limit=limit, offset=offset
    )
    return jsonify(result), status_code

# البحث عن فنان عبر اسمه
@artist_profiles_bp.get("/by-name/<display_name>")
def get_profile_by_display_name(display_name):
    """Public lookup by unique display name (handle)."""
    result, status_code = ArtistsProfileFacade.get_by_display_name(display_name)
    return jsonify(result), status_code

# استعراض لوحات الفنان عند الدخول لبروفايله
@artist_profiles_bp.get("/<profile_id>/artworks")
def list_profile_artworks(profile_id):
    """Public artworks for an artist profile page."""
    limit, offset = _pagination_args()
    status = _optional_status(default="available")
    result, status_code = ArtworkFacade.list_for_profile(
        profile_id, limit=limit, offset=offset, status=status
    )
    return jsonify(result), status_code

# عدد الاعمال للفنان
@artist_profiles_bp.get("/<profile_id>/artworks/count")
def count_profile_artworks(profile_id):
    """Public count of artworks for an artist profile."""
    result, status_code = ArtworkFacade.count_for_profile(profile_id)
    return jsonify(result), status_code


@artist_profiles_bp.get("/<profile_id>")
def get_profile_by_id(profile_id):
    """Public lookup by artist profile UUID."""
    result, status_code = ArtistsProfileFacade.get_by_id(profile_id)
    return jsonify(result), status_code
