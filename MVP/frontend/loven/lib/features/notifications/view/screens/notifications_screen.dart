import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_cubit.dart';
import 'package:loven/features/notifications/controller/cubit/notifications_state.dart';
import 'package:loven/features/notifications/navigation/notification_route_resolver.dart';
import 'package:loven/features/notifications/view/widgets/notification_list_tile.dart';
import 'package:loven/features/order/data/repositories/order_repository.dart';
import 'package:flutter/cupertino.dart';
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationsCubit>().refreshNotifications();
    });
  }

  Future<void> _onNotificationTap(
    NotificationsLoaded state,
    int index,
  ) async {
    final notification = state.notifications[index];
    final cubit = context.read<NotificationsCubit>();

    if (notification.isUnread) {
      await cubit.markAsRead(notification.id);
    }

    if (!mounted) return;

    await NotificationRouteResolver.open(
      context,
      notification: notification,
      orderRepository: context.read<OrderRepository>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: lovenPushedScreenBackLeading(context),
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is! NotificationsLoaded || state.unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () {
                  context.read<NotificationsCubit>().markAllAsRead();
                },
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const GalleryLoadingState(
              message: 'Loading notifications…',
            );
          }

          if (state is NotificationsError) {
            return GalleryEmptyState(
                backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.error_outline,
              title: 'Could not load notifications',
              subtitle: state.message,
              actionLabel: 'Retry',
              onAction: () {
                context.read<NotificationsCubit>().refreshNotifications();
              },
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return CustomScrollView(
  physics: const BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  ),
  slivers: [
    CupertinoSliverRefreshControl(
      onRefresh: () async {
        await context.read<NotificationsCubit>().refreshNotifications();
      },
    ),
    SliverFillRemaining(
      hasScrollBody: false,
      child: GalleryEmptyState(
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: Icons.notifications_none_outlined,
        title: 'No notifications yet',
        subtitle:
            'Updates about orders and activity will appear here.',
      ),
    ),
  ],
);
            }

return NotificationListener<ScrollNotification>(
  onNotification: (scrollInfo) {
    if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 120 &&
        state.hasMore &&
        !state.isLoadingMore) {
      context.read<NotificationsCubit>().loadMore();
    }
    return false;
  },
  child: CustomScrollView(
    physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    slivers: [
      CupertinoSliverRefreshControl(
        onRefresh: () async {
          await context.read<NotificationsCubit>().refreshNotifications();
        },
      ),

      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.notifications.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: SizedBox(
                    width: AppSizes.iconMd,
                    height: AppSizes.iconMd,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final notification = state.notifications[index];

            return Column(
              children: [
                NotificationListTile(
                  notification: notification,
                  onTap: () => _onNotificationTap(state, index),
                ),
                Divider(
                  height: 1,
                  color: AppColors.borderLight,
                ),
              ],
            );
          },
          childCount:
              state.notifications.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),

      const SliverToBoxAdapter(
        child: SizedBox(
          height: AppSizes.shellFloatingNavClearance + AppSpacing.lg,
        ),
      ),
    ],
  ),
);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
