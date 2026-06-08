/// MVC data models for the artist_profile feature.
///
/// No Domain layer: these classes are the single source of truth for JSON
/// coming from Flask (`_profile_to_dict` / `_artwork_to_dict`).

// =============================================================================
// ArtworkModel — maps `artworks` table / `_artwork_to_dict()`
// =============================================================================

/// One artwork listing as serialized by the backend.
///
/// Flask sends `price` and `shipping_fee` as **strings** (Python Decimal),
/// so [fromJson] uses [_parseDecimal] instead of a raw cast.

class ArtworkModel {
  final String id;
  final String artistProfileId;
  final String? artistDisplayName;
  final String? artistProfileImageUrl;
  final bool artistIsVerified;
  final String title;
  final String? description;
  final double? price;
  final int? quantityAvailable;
  final double? shippingFee;
  final String? artworkImageUrl;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const ArtworkModel({
    required this.id,
    required this.artistProfileId,
    this.artistDisplayName,
    this.artistProfileImageUrl,
    this.artistIsVerified = false,
    required this.title,
    this.description,
    this.price,
    this.quantityAvailable,
    this.shippingFee,
    this.artworkImageUrl,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Accepts a flat artwork map OR `{ "artwork": { ... } }` (GET/PATCH responses).
  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    final nestedArtwork = json['artwork'];
    final Map<String, dynamic> data = nestedArtwork is Map
        ? Map<String, dynamic>.from(nestedArtwork)
        : json;

    return ArtworkModel(
      id: data['id']?.toString() ?? '',
      artistProfileId: data['artist_profile_id']?.toString() ?? '',
      artistDisplayName: _parseString(data['artist_display_name']),
      artistProfileImageUrl: _parseString(data['artist_profile_image_url']),
      artistIsVerified: _parseBool(data['artist_is_verified']),
      title: data['title']?.toString() ?? '',
      description: _parseString(data['description']),
      price: _parseDecimal(data['price']),
      quantityAvailable: _parseInt(data['quantity_available']),
      shippingFee: _parseDecimal(data['shipping_fee']),
      artworkImageUrl: _parseString(data['artwork_image_url']),
      status: _parseString(data['status']),
      createdAt: _parseString(data['created_at']),
      updatedAt: _parseString(data['updated_at']),
    );
  }

  /// Builds the body for `PATCH /artworks/<id>`.
  ///
  /// **Collection-if** (`if (x != null) 'key': x`) sends only fields the user
  /// actually changed. Flask rejects empty PATCH bodies and ignores unknown keys
  /// via `_ARTIST_WRITABLE_FIELDS`.
  Map<String, dynamic> toJson() {
    return {
      if (title.isNotEmpty) 'title': title,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (quantityAvailable != null) 'quantity_available': quantityAvailable,
      if (shippingFee != null) 'shipping_fee': shippingFee,
      if (artworkImageUrl != null) 'artwork_image_url': artworkImageUrl,
      if (status != null) 'status': status,
    };
  }

  /// Safely parses Decimal-backed values that may arrive as `String` or `num`.
  static double? _parseDecimal(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String && value.isNotEmpty) return double.tryParse(value);
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String && value.isNotEmpty) return int.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}

// =============================================================================
// ArtistModel — maps `artist_profiles` table / `_profile_to_dict()`
// =============================================================================

/// Artist public profile as serialized by the backend.
class ArtistModel {
  final String id;
  final String userId;
  final String displayName;
  final String? city;
  final String? bio;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final bool isVerified;
  final String? shippingPolicy;
  final String? createdAt;
  final String? updatedAt;

  const ArtistModel({
    required this.id,
    required this.userId,
    required this.displayName,
    this.city,
    this.bio,
    this.profileImageUrl,
    this.coverImageUrl,
    this.isVerified = false,
    this.shippingPolicy,
    this.createdAt,
    this.updatedAt,
  });

  /// Accepts `{ "profile": { ... } }` (GET /me, GET /:id, PATCH /me) or flat map.
  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : json;

    return ArtistModel(
      id: data['id']?.toString() ?? '',
      userId: data['user_id']?.toString() ?? '',
      displayName: data['display_name'] as String? ?? '',
      city: data['city'] as String?,
      bio: data['bio'] as String?,
      profileImageUrl: data['profile_image_url'] as String?,
      coverImageUrl: data['cover_image_url'] as String?,
      isVerified: data['is_verified'] as bool? ?? false,
      shippingPolicy: data['shipping_policy'] as String?,
      createdAt: data['created_at'] as String?,
      updatedAt: data['updated_at'] as String?,
    );
  }

  /// Builds the body for `PATCH /artist-profiles/me`.
  ///
  /// Only non-null fields are included so partial updates do not overwrite
  /// untouched columns with null on the server.
  Map<String, dynamic> toJson() {
    return {
      if (displayName.isNotEmpty) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (city != null) 'city': city,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (shippingPolicy != null) 'shipping_policy': shippingPolicy,
    };
  }

  /// Parses `{ "artworks": [ {...}, ... ] }` from list endpoints.
  static List<ArtworkModel> parseArtworkList(Map<String, dynamic> json) {
    final raw = json['artworks'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => ArtworkModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
