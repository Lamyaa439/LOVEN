import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/view/models/order_success_extra.dart';
import 'package:flutter/cupertino.dart';

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

  Future<void> _copyOrderReference(BuildContext context) async {
    final orderId = extra.orderId;
    if (orderId == null || orderId.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: orderId));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order reference copied')),
    );
  }

  String _shortOrderId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }

  String _itemsLabel(int count) {
    if (count == 1) return '1 item';
    return '$count items';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderId = extra.orderId;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      Container(
                        width: AppSizes.avatarXl + AppSpacing.xxl,
                        height: AppSizes.avatarXl + AppSpacing.xxl,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: AppSizes.avatarLg,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Payment confirmed',
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
                        'Your order is saved to your LOVEN account and will appear in Order History.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      LovenSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order summary',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                const _PaidChip(),
                              ],
                            ),
                            if (orderId != null && orderId.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Order #${_shortOrderId(orderId)}',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              InkWell(
                                onTap: () => _copyOrderReference(context),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.xxs,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          orderId,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppColors.textMuted,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Icon(
                                        Icons.copy_rounded,
                                        size: AppSizes.iconSm,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.md),
                            _SummaryRow(
                              label: 'Items',
                              value: _itemsLabel(extra.itemCount),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _SummaryRow(
                              label: 'Total',
                              value:
                                  'SAR ${extra.totalAmount.toStringAsFixed(2)}',
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
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaidChip extends StatelessWidget {
  const _PaidChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        'Paid',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: emphasize
                ? theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.brandPrimary,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
