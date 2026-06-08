import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_cubit.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';

/// Maps FCM data payloads to app routes using the backend push contract.
class PushRouteHandler {
  PushRouteHandler._();

  static Future<void> handle(
    Map<String, dynamic> data, {
    required GoRouter router,
    required AuthCubit authCubit,
    required NotificationsCubit notificationsCubit,
    required OrderRepository orderRepository,
  }) async {
    if (!authStateHasSession(authCubit.state)) {
      return;
    }

    await notificationsCubit.refreshNotifications();

    final action = _resolveAction(data);
    if (action == null) {
      return;
    }

    switch (action) {
      case 'open_home_screen':
        router.go(AppRoutes.home);
        return;

      case 'open_notifications':
        router.push(AppRoutes.notifications);
        return;

      case 'open_cart':
        router.push(AppRoutes.cart);
        return;

      case 'open_order_details':
        final orderId = _resolveOrderId(data);
        await _openOrderDetails(
          router,
          orderRepository: orderRepository,
          orderId: orderId,
        );
        return;

      default:
        return;
    }
  }

  static String? _resolveAction(Map<String, dynamic> data) {
    final action = _stringValue(data['action']);
    if (action != null && action.isNotEmpty) {
      return action;
    }

    return _actionForType(_stringValue(data['type']));
  }

  static String? _actionForType(String? type) {
    switch (type) {
      case 'welcome':
        return 'open_home_screen';
      case 'order_new_artist':
      case 'artist_order_reminder':
      case 'order_status':
      case 'payment_success':
        return 'open_order_details';
      case 'feedback_submitted':
        return 'open_notifications';
      case 'cart_inactivity':
        return 'open_cart';
      default:
        return null;
    }
  }

  static String? _resolveOrderId(Map<String, dynamic> data) {
    final orderId = _stringValue(data['order_id']);
    if (orderId != null && orderId.isNotEmpty) {
      return orderId;
    }

    final referenceType = _stringValue(data['reference_type']);
    final referenceId = _stringValue(data['reference_id']);
    if (referenceType == 'order' && referenceId != null && referenceId.isNotEmpty) {
      return referenceId;
    }

    if (referenceId != null && referenceId.isNotEmpty) {
      return referenceId;
    }

    return null;
  }

  static Future<void> _openOrderDetails(
    GoRouter router, {
    required OrderRepository orderRepository,
    required String? orderId,
  }) async {
    if (orderId == null || orderId.isEmpty) {
      router.go(AppRoutes.home);
      return;
    }

    try {
      final data = await orderRepository.getOrderById(orderId);
      final rawOrder = data['order'];

      if (rawOrder is! Map) {
        router.go(AppRoutes.home);
        return;
      }

      final order = Map<String, dynamic>.from(rawOrder);
      router.push(AppRoutes.ordersDetails, extra: order);
    } catch (_) {
      router.go(AppRoutes.home);
    }
  }

  static String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
