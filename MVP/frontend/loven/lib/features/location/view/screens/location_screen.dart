import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/res/theme/app_colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const _storage = FlutterSecureStorage();
  static const _addressKey = 'saved_delivery_address';

  Map<String, dynamic>? _address;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final raw = await _storage.read(key: _addressKey);

    if (!mounted) return;

    setState(() {
      _address = raw == null ? null : jsonDecode(raw);
    });
  }

  Future<void> _openAddressForm() async {
    await context.push(AppRoutes.locationAddressForm);
    await _loadAddress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAddress = _address != null;

    final addressText = hasAddress
        ? '${_address!['city'] ?? ''}, Block ${_address!['block'] ?? ''}, ${_address!['street'] ?? ''}'
        : 'Add your delivery address';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Saved Addresses'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Delivery Address',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            InkWell(
              onTap: _openAddressForm,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppColors.primaryPurple.withValues(alpha: 0.25),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        addressText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),

            if (hasAddress) ...[
              const SizedBox(height: 16),
              _AddressDetail(label: 'Name', value: _address!['name']),
              _AddressDetail(label: 'Phone', value: _address!['phone']),
              _AddressDetail(label: 'Governorate', value: _address!['governorate']),
              _AddressDetail(label: 'Building', value: _address!['building']),
            ],

            const SizedBox(height: 24),

            Text(
              'Save Address As',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                _AddressChip(label: 'Home', selected: true),
                SizedBox(width: 10),
                _AddressChip(label: 'Office', selected: false),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _openAddressForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(hasAddress ? 'Edit Address' : 'Add Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressDetail extends StatelessWidget {
  final String label;
  final dynamic value;

  const _AddressDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _AddressChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _AddressChip({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: selected
          ? AppColors.primaryPurple.withValues(alpha: 0.25)
          : Theme.of(context).colorScheme.surface,
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryBlue : Colors.grey,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected ? AppColors.primaryBlue : Colors.grey.shade300,
      ),
    );
  }
}