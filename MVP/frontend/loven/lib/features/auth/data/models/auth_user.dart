/// LOVEN session identity returned by `GET /account/me` and held in [AuthSuccess].
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String systemRole;
  final String? profileImageUrl;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.systemRole,
    this.profileImageUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      systemRole: json['system_role'] ?? '',
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }
}
