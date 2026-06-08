import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._repository, {
    AuthCubit? authCubit,
  })  : _authCubit = authCubit,
        super(NotificationsInitial());

  static const int _defaultLimit = 20;

  final NotificationsRepository _repository;
  final AuthCubit? _authCubit;

  bool get _hasSession {
    final auth = _authCubit;
    if (auth == null) {
      return false;
    }
    return authStateHasSession(auth.state);
  }

  void resetForSignedOut() {
    if (isClosed) {
      return;
    }
    emit(NotificationsInitial());
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (!_hasSession) {
      resetForSignedOut();
      return;
    }

    if (isClosed) {
      return;
    }

    if (!refresh && state is NotificationsLoaded) {
      return;
    }

    emit(NotificationsLoading());

    try {
      final data = await _repository.listNotifications(
        limit: _defaultLimit,
        offset: 0,
      );

      if (isClosed) {
        return;
      }

      emit(_parseListResponse(data, offset: 0));
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> refreshNotifications() async {
    if (!_hasSession || isClosed) {
      return;
    }

    final previous = state;
    if (previous is NotificationsLoaded) {
      emit(previous.copyWith(isLoadingMore: false));
    } else {
      emit(NotificationsLoading());
    }

    try {
      final data = await _repository.listNotifications(
        limit: _defaultLimit,
        offset: 0,
      );

      if (isClosed) {
        return;
      }

      emit(_parseListResponse(data, offset: 0));
    } catch (e) {
      if (isClosed) {
        return;
      }
      if (previous is NotificationsLoaded) {
        emit(previous);
        return;
      }
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (!_hasSession || isClosed) {
      return;
    }

    final current = state;
    if (current is! NotificationsLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final nextOffset = current.offset + current.notifications.length;

    try {
      final data = await _repository.listNotifications(
        limit: current.limit,
        offset: nextOffset,
      );

      if (isClosed) {
        return;
      }

      final page = _parseNotifications(data['notifications']);
      emit(
        NotificationsLoaded(
          notifications: [...current.notifications, ...page],
          unreadCount: _parseInt(data['unread_count'], current.unreadCount),
          totalCount: _parseInt(data['total_count'], current.totalCount),
          limit: _parseInt(data['limit'], current.limit),
          offset: nextOffset,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (!_hasSession || isClosed) {
      return;
    }

    final current = state;
    if (current is! NotificationsLoaded) {
      return;
    }

    final index = current.notifications.indexWhere((n) => n.id == notificationId);
    if (index < 0) {
      return;
    }

    final target = current.notifications[index];
    if (target.isRead) {
      return;
    }

    try {
      await _repository.markRead(notificationId);

      if (isClosed) {
        return;
      }

      final updated = List<NotificationModel>.from(current.notifications);
      updated[index] = NotificationModel(
        id: target.id,
        userId: target.userId,
        type: target.type,
        title: target.title,
        body: target.body,
        referenceId: target.referenceId,
        referenceType: target.referenceType,
        isRead: true,
        createdAt: target.createdAt,
        updatedAt: target.updatedAt,
      );

      final newUnread = current.unreadCount > 0 ? current.unreadCount - 1 : 0;

      emit(
        current.copyWith(
          notifications: updated,
          unreadCount: newUnread,
        ),
      );
    } catch (_) {
      // Keep list state; caller may surface error if needed.
    }
  }

  Future<void> markAllAsRead() async {
    if (!_hasSession || isClosed) {
      return;
    }

    final current = state;
    if (current is! NotificationsLoaded) {
      return;
    }

    if (current.unreadCount == 0) {
      return;
    }

    try {
      await _repository.markAllRead();

      if (isClosed) {
        return;
      }

      final updated = current.notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              body: n.body,
              referenceId: n.referenceId,
              referenceType: n.referenceType,
              isRead: true,
              createdAt: n.createdAt,
              updatedAt: n.updatedAt,
            ),
          )
          .toList();

      emit(
        current.copyWith(
          notifications: updated,
          unreadCount: 0,
        ),
      );
    } catch (_) {
      // Keep prior state on failure.
    }
  }

  NotificationsLoaded _parseListResponse(
    Map<String, dynamic> data, {
    required int offset,
  }) {
    return NotificationsLoaded(
      notifications: _parseNotifications(data['notifications']),
      unreadCount: _parseInt(data['unread_count'], 0),
      totalCount: _parseInt(data['total_count'], 0),
      limit: _parseInt(data['limit'], _defaultLimit),
      offset: offset,
    );
  }

  List<NotificationModel> _parseNotifications(dynamic raw) {
    if (raw is! List) {
      return [];
    }

    return raw
        .whereType<Map>()
        .map((item) => NotificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  int _parseInt(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
