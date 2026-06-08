import '../../data/models/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int totalCount;
  final int limit;
  final int offset;
  final bool isLoadingMore;

  NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
    required this.limit,
    required this.offset,
    this.isLoadingMore = false,
  });

  bool get hasMore => offset + notifications.length < totalCount;

  NotificationsLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    int? totalCount,
    int? limit,
    int? offset,
    bool? isLoadingMore,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}
