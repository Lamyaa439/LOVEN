import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/order/controller/cubit/order_cubit.dart';
import 'package:loven/features/order/controller/cubit/order_state.dart';

class IncomingOrdersScreen extends StatefulWidget {
  const IncomingOrdersScreen({
    super.key,
    required this.artistProfileId,
  });

  final String artistProfileId;

  @override
  State<IncomingOrdersScreen> createState() =>
      _IncomingOrdersScreenState();
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Incoming Orders'),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is OrderError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(
                child: Text('No incoming orders yet.'),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
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
  State<_IncomingOrderCard> createState() =>
      _IncomingOrderCardState();
}

class _IncomingOrderCardState extends State<_IncomingOrderCard> {
  late String _selectedStatus;
  late final TextEditingController _shippingCompanyController;
  late final TextEditingController _trackingNumberController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _selectedStatus =
        widget.order['status']?.toString() ?? 'pending';

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

    if (orderId == null || orderId.isEmpty) {
      return;
    }

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

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        orderId: orderId,
        status: _selectedStatus,
        shippingCompany:
            _shippingCompanyController.text.trim().isEmpty
                ? null
                : _shippingCompanyController.text.trim(),
        trackingNumber:
            _trackingNumberController.text.trim().isEmpty
                ? null
                : _trackingNumberController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order updated'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final id = widget.order['id']?.toString() ?? '';
    final total = widget.order['total_amount']?.toString() ?? '0';
    final createdAt = widget.order['created_at']?.toString() ?? '';
    final items = widget.order['items'];

    final itemCount = items is List ? items.length : 0;
    final showShippingFields = _selectedStatus == 'shipped';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor:
                    AppColors.primaryPurple.withValues(alpha: 0.18),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${id.length > 8 ? id.substring(0, 8) : id}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      createdAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$total SAR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '$itemCount item(s)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Order Status',
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
              DropdownMenuItem(
                value: 'paid',
                child: Text('Paid'),
              ),
              DropdownMenuItem(
                value: 'shipped',
                child: Text('Shipped'),
              ),
              DropdownMenuItem(
                value: 'delivered',
                child: Text('Delivered'),
              ),
              DropdownMenuItem(
                value: 'cancelled',
                child: Text('Cancelled'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedStatus = value;
              });
            },
          ),

          if (showShippingFields) ...[
            const SizedBox(height: 12),

            _ShippingField(
              controller: _shippingCompanyController,
              label: 'Shipping Company',
              hint: 'Example: Aramex, DHL, FedEx',
            ),

            const SizedBox(height: 12),

            _ShippingField(
              controller: _trackingNumberController,
              label: 'Tracking Number',
              hint: 'Enter tracking number',
            ),
          ],

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isSaving ? 'Saving...' : 'Save Order Update',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingField extends StatelessWidget {
  const _ShippingField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}