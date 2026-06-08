/// In-app notification row from `GET /api/v1/notifications/`.
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final String? createdAt;
  final String? updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    this.createdAt,
    this.updatedAt,
  });

  bool get isUnread => !isRead;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      referenceId: json['reference_id']?.toString(),
      referenceType: json['reference_type']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
