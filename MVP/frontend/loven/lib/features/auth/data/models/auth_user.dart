import 'package:loven/l10n/generated/app_localizations.dart';

/// LOVEN session identity returned by `GET /account/me` and held in [AuthSuccess].
class AuthUser {
  static const String roleArtist = 'artist';
  static const String roleCustomer = 'customer';

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

  String getLocalizedRole(AppLocalizations l10n) {
    if (systemRole == roleArtist) return l10n.artist;
    return l10n.customer;
  }

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
