from app.core.uuid_utils import as_uuid
from app.persistence.repositories.user_repo import UserRepository

user_repo = UserRepository()


def _is_admin(user_id):
    user = user_repo.get_user_by_id(as_uuid(user_id))
    return user is not None and user.system_role == "admin"


def _parse_pagination(limit, offset, max_limit=100):
    try:
        limit = int(limit)
        offset = int(offset)
    except (TypeError, ValueError):
        return None, None, ({"error": "limit and offset must be integers"}, 400)

    if limit < 1 or limit > max_limit:
        return None, None, ({"error": f"limit must be between 1 and {max_limit}"}, 400)

    if offset < 0:
        return None, None, ({"error": "offset must be non-negative"}, 400)

    return limit, offset, None


def list_users(admin_user_id, limit=50, offset=0):
    if not _is_admin(admin_user_id):
        return {"error": "Admin access required"}, 403

    limit, offset, err = _parse_pagination(limit, offset)

    if err:
        return err

    users = user_repo.list_active_records(
        limit=limit,
        offset=offset,
    )

    return {
        "users": [user.to_dict() for user in users],
        "limit": limit,
        "offset": offset,
    }, 200


def update_user_active_status(admin_user_id, target_user_id, is_active):
    if not _is_admin(admin_user_id):
        return {"error": "Admin access required"}, 403

    if is_active is None:
        return {"error": "is_active is required"}, 400

    if not isinstance(is_active, bool):
        return {"error": "is_active must be a boolean"}, 400

    target_user = user_repo.get_user_by_id(as_uuid(target_user_id))

    if not target_user:
        return {"error": "User not found"}, 404

    if str(target_user.id) == str(admin_user_id):
        return {"error": "Admin cannot disable their own account"}, 400

    updated_user = user_repo.update_active_status(
        as_uuid(target_user_id),
        is_active,
    )

    return {
        "message": "User status updated",
        "user": updated_user.to_dict(),
    }, 200