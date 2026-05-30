class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String systemRole;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.systemRole,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
      systemRole: json['system_role'] ?? '',
    );
  }
}