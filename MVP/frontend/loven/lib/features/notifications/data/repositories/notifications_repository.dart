import 'package:loven/core/network/api_constants.dart';

// Data-access layer for the authenticated user's in-app notifications.

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Map<String, dynamic> _asMap(dynamic data) {
    return Map<String, dynamic>.from(data as Map);
  }

  /// Lists notifications (`GET /notifications/`).
  Future<Map<String, dynamic>> listNotifications({
    int limit = 20,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.notifications,
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'unread_only': unreadOnly,
      },
    );

    return _asMap(response.data);
  }

  /// Marks one notification as read (`PATCH /notifications/{id}/read`).
  Future<Map<String, dynamic>> markRead(String notificationId) async {
    final response = await _apiClient.patch(
      ApiConstants.notificationRead(notificationId),
    );

    return _asMap(response.data);
  }

  /// Marks all notifications as read (`PATCH /notifications/read-all`).
  Future<Map<String, dynamic>> markAllRead() async {
    final response = await _apiClient.patch(
      ApiConstants.notificationsReadAll,
    );

    return _asMap(response.data);
  }
}
