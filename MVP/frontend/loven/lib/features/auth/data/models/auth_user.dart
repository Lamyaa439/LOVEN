class AuthUser {
  final String id;
  final String name;
  final String email;
  final String systemRole;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.systemRole,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      systemRole: json['system_role'] ?? '',
    );
  }
}