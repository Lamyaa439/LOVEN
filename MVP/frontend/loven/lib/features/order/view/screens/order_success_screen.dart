import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/view/models/order_success_extra.dart';

/// Post-checkout confirmation — uses only data available at order time.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.extra,
  });

  final OrderSuccessExtra extra;

  void _goHome(BuildContext context) {
    context.read<HomeBloc>().add(FetchHomeData());
    context.go(AppRoutes.home);
  }

  void _viewOrders(BuildContext context) {
    context.read<OrderCubit>().getMyOrders();
    context.go(AppRoutes.ordersHistory);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: AppSizes.avatarXl + AppSpacing.xxl,
                  height: AppSizes.avatarXl + AppSpacing.xxl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: AppSizes.avatarLg,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Order placed',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Thank you, ${extra.userLabel}.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your order has been recorded under your LOVEN account.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                LovenSurfaceCard(
                  child: Column(
                    children: [
                      if (extra.orderId != null && extra.orderId!.isNotEmpty)
                        _SummaryRow(
                          label: 'Order reference',
                          value: extra.orderId!,
                        ),
                      if (extra.orderId != null && extra.orderId!.isNotEmpty)
                        const SizedBox(height: AppSpacing.sm),
                      _SummaryRow(
                        label: 'Items',
                        value: '${extra.itemCount}',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SummaryRow(
                        label: 'Total',
                        value: 'SAR ${extra.totalAmount.toStringAsFixed(2)}',
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                LovenPrimaryButton(
                  label: 'Back to home',
                  icon: Icons.home_outlined,
                  onPressed: () => _goHome(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                LovenSecondaryButton(
                  label: 'View order history',
                  expand: true,
                  onPressed: () => _viewOrders(context),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: emphasize
              ? theme.textTheme.titleSmall
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
