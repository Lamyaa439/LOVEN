"""
Shared UUID normalization helpers.
"""

import uuid


def as_uuid(value):
    """
    Normalize JWT / string IDs to uuid.UUID for DB comparisons.

    Supports UUID objects, string UUIDs, and None.
    """
    if value is None:
        return None
    if isinstance(value, uuid.UUID):
        return value
    return uuid.UUID(str(value))
