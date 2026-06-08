import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/features/notifications/data/models/notification_model.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';

/// Routes in-app notification taps to the appropriate screen.
class NotificationRouteResolver {
  NotificationRouteResolver._();

  static Future<void> open(
    BuildContext context, {
    required NotificationModel notification,
    required OrderRepository orderRepository,
  }) async {
    switch (notification.type) {
      case 'welcome':
        context.go(AppRoutes.home);
        return;

      case 'order_new_artist':
      case 'artist_order_reminder':
      case 'order_status':
      case 'payment_success':
        await _openOrderDetails(
          context,
          orderRepository: orderRepository,
          orderId: notification.referenceId,
        );
        return;

      case 'feedback_submitted':
        return;

      case 'cart_inactivity':
        context.push(AppRoutes.cart);
        return;

      default:
        return;
    }
  }

  static Future<void> _openOrderDetails(
    BuildContext context, {
    required OrderRepository orderRepository,
    required String? orderId,
  }) async {
    if (orderId == null || orderId.isEmpty) {
      _showNotFound(context);
      return;
    }

    try {
      final data = await orderRepository.getOrderById(orderId);
      if (!context.mounted) {
        return;
      }

      final rawOrder = data['order'];

      if (rawOrder is! Map) {
        _showNotFound(context);
        return;
      }

      final order = Map<String, dynamic>.from(rawOrder);
      context.push(AppRoutes.ordersDetails, extra: order);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showNotFound(context);
    }
  }

  static void _showNotFound(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order not found')),
    );
  }
}
