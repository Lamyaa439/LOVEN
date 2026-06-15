import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';
import 'package:loven/features/order/view/widgets/order_item_display.dart';

class IncomingOrdersScreen extends StatefulWidget {
  const IncomingOrdersScreen({
    super.key,
    required this.artistProfileId,
  });

  final String artistProfileId;

  @override
  State<IncomingOrdersScreen> createState() => _IncomingOrdersScreenState();
}

class _IncomingOrdersScreenState extends State<IncomingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().getArtistOrders(
          artistProfileId: widget.artistProfileId,
        );
  }

  Future<void> _refreshOrders() {
    return context.read<OrderCubit>().getArtistOrders(
          artistProfileId: widget.artistProfileId,
        );
  }

  Future<void> _updateOrder({
    required String orderId,
    required String status,
    String? shippingCompany,
    String? trackingNumber,
  }) async {
    await context.read<OrderCubit>().updateOrderStatus(
          orderId: orderId,
          status: status,
          shippingCompany: shippingCompany,
          trackingNumber: trackingNumber,
        );

    if (!mounted) return;
    await _refreshOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: lovenPushedScreenBackLeading(context),
        title: const Text('Incoming Orders'),
        centerTitle: true,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const GalleryLoadingState(message: 'Loading orders…');
          }

          if (state is OrderError) {
            return GalleryEmptyState(
                backgroundColor: Theme.of(context).colorScheme.surface,
              icon: Icons.error_outline_rounded,
              title: 'Could not load orders',
              subtitle: state.message,
            );
          }

          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return GalleryEmptyState(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                icon: Icons.inventory_2_outlined,
                title: 'No incoming orders yet',
                subtitle: 'Orders for your artworks will appear here.',
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.screenPadding,
                  AppSpacing.screenPadding,
                  AppSizes.shellFloatingNavClearance + AppSpacing.lg,
                ),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final order = Map<String, dynamic>.from(
                    state.orders[index] as Map,
                  );
                  return _IncomingOrderCard(
                    order: order,
                    onSave: _updateOrder,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _IncomingOrderCard extends StatefulWidget {
  const _IncomingOrderCard({
    required this.order,
    required this.onSave,
  });

  final Map<String, dynamic> order;
  final Future<void> Function({
    required String orderId,
    required String status,
    String? shippingCompany,
    String? trackingNumber,
  }) onSave;

  @override
  State<_IncomingOrderCard> createState() => _IncomingOrderCardState();
}

class _IncomingOrderCardState extends State<_IncomingOrderCard> {
  late String _selectedStatus;
  late final TextEditingController _shippingCompanyController;
  late final TextEditingController _trackingNumberController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order['status']?.toString() ?? 'pending';
    _shippingCompanyController = TextEditingController(
      text: widget.order['shipping_company']?.toString() ?? '',
    );
    _trackingNumberController = TextEditingController(
      text: widget.order['tracking_number']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _shippingCompanyController.dispose();
    _trackingNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final orderId = widget.order['id']?.toString();
    if (orderId == null || orderId.isEmpty) return;

    if (_selectedStatus == 'shipped') {
      if (_shippingCompanyController.text.trim().isEmpty ||
          _trackingNumberController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Shipping company and tracking number are required when shipped.',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        orderId: orderId,
        status: _selectedStatus,
        shippingCompany: _shippingCompanyController.text.trim().isEmpty
            ? null
            : _shippingCompanyController.text.trim(),
        trackingNumber: _trackingNumberController.text.trim().isEmpty
            ? null
            : _trackingNumberController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final id = widget.order['id']?.toString() ?? '';
    final total = widget.order['total_amount']?.toString() ?? '0';
    final createdAt = widget.order['created_at']?.toString() ?? '';
        final buyerPayload = widget.order['buyer'];
final buyer = buyerPayload is Map
    ? Map<String, dynamic>.from(buyerPayload)
    : <String, dynamic>{};

final buyerLabel = buyer['full_name']?.toString().trim().isNotEmpty == true
    ? buyer['full_name'].toString()
    : buyer['username']?.toString().trim().isNotEmpty == true
        ? buyer['username'].toString()
        : buyer['email']?.toString().trim().isNotEmpty == true
            ? buyer['email'].toString()
            : 'Buyer account';
    final displayItems = OrderItemDisplay.listFromOrder(widget.order);
final itemCount = displayItems.isEmpty
    ? 0
    : displayItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final showShippingFields =
        _selectedStatus == 'shipped' || _selectedStatus == 'delivered';

    return LovenSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.avatarMd,
                height: AppSizes.avatarMd,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: AppSizes.iconMd,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Order #${id.length > 8 ? id.substring(0, 8) : id}',
        style: theme.textTheme.titleSmall,
      ),

      if (createdAt.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xxs),
        Text(
          createdAt,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],

      const SizedBox(height: AppSpacing.xxs),

      Text(
        buyerLabel,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    ],
  ),
),
              Text(
                '$total SAR',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$itemCount item(s)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          if (displayItems.isNotEmpty) ...[
  const SizedBox(height: AppSpacing.md),
  ...displayItems.map(
    (item) => OrderItemRow(item: item),
  ),
],
          const SizedBox(height: AppSpacing.lg),
          CheckoutFieldSection(
            label: 'Order status',
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: checkoutInputDecoration(
                hint: 'Select status',
                icon: Icons.local_shipping_outlined,
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'paid', child: Text('Paid')),
                DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedStatus = value);
              },
            ),
          ),
          if (showShippingFields) ...[
            CheckoutFieldSection(
              label: 'Shipping company',
              child: LovenTextField(
                controller: _shippingCompanyController,
                hintText: 'Example: Aramex, DHL, FedEx',
                prefixIcon: const Icon(Icons.business_outlined, size: 20),
              ),
            ),
            CheckoutFieldSection(
              label: 'Tracking number',
              child: LovenTextField(
                controller: _trackingNumberController,
                hintText: 'Enter tracking number',
                prefixIcon: const Icon(Icons.numbers_outlined, size: 20),
              ),
            ),
          ],
          LovenPrimaryButton(
            label: _isSaving ? 'Saving…' : 'Save order update',
            onPressed: _isSaving ? null : _save,
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }
}
