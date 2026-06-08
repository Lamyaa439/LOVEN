import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_cubit.dart';
import 'package:loven/features/notifications/navigation/push_route_handler.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';

/// Wires FCM foreground, background-open, and cold-start push handling.
class PushNotificationService {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  DateTime? _lastHandledNavigationAt;

  Future<void> initialize({
    required GoRouter router,
    required AuthCubit authCubit,
    required NotificationsCubit notificationsCubit,
    required OrderRepository orderRepository,
  }) async {
    await authCubit.restoreSession();

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Push permission request failed: $e');
      }
    }

    _subscriptions.add(
      FirebaseMessaging.onMessage.listen(
        (message) => _onForegroundMessage(
          message,
          authCubit: authCubit,
          notificationsCubit: notificationsCubit,
        ),
      ),
    );

    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => unawaited(
          _handleOpenedMessage(
            message,
            router: router,
            authCubit: authCubit,
            notificationsCubit: notificationsCubit,
            orderRepository: orderRepository,
          ),
        ),
      ),
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _handleOpenedMessage(
        initialMessage,
        router: router,
        authCubit: authCubit,
        notificationsCubit: notificationsCubit,
        orderRepository: orderRepository,
      );
    }
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
  }

  void _onForegroundMessage(
    RemoteMessage message, {
    required AuthCubit authCubit,
    required NotificationsCubit notificationsCubit,
  }) {
    if (!authStateHasSession(authCubit.state)) {
      return;
    }

    unawaited(notificationsCubit.refreshNotifications());
  }

  Future<void> _handleOpenedMessage(
    RemoteMessage message, {
    required GoRouter router,
    required AuthCubit authCubit,
    required NotificationsCubit notificationsCubit,
    required OrderRepository orderRepository,
  }) async {
    if (!authStateHasSession(authCubit.state)) {
      return;
    }

    final now = DateTime.now();
    final lastHandled = _lastHandledNavigationAt;
    if (lastHandled != null &&
        now.difference(lastHandled) < const Duration(milliseconds: 800)) {
      return;
    }
    _lastHandledNavigationAt = now;

    final data = _normalizePayload(message.data);
    if (data.isEmpty) {
      return;
    }

    await PushRouteHandler.handle(
      data,
      router: router,
      authCubit: authCubit,
      notificationsCubit: notificationsCubit,
      orderRepository: orderRepository,
    );
  }

  Map<String, dynamic> _normalizePayload(Map<String, dynamic> data) {
    return Map<String, dynamic>.fromEntries(
      data.entries.map(
        (entry) => MapEntry(entry.key, entry.value?.toString()),
      ),
    );
  }
}
