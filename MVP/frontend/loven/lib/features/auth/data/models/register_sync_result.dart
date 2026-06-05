/// Result of LOVEN backend register-sync after Firebase client signup.
///
/// No LOVEN JWT is included — verification and login exchange happen later.
class RegisterSyncResult {
  const RegisterSyncResult({
    required this.email,
    required this.userId,
    required this.verificationRequired,
    required this.message,
  });

  final String email;
  final String userId;
  final bool verificationRequired;
  final String message;

  factory RegisterSyncResult.fromJson(Map<String, dynamic> json) {
    return RegisterSyncResult(
      email: json['email']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      verificationRequired: json['verification_required'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}
