import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';

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
      appBar: AppBar(
        leading: lovenPushedScreenBackLeading(context),
        centerTitle: true,
        title: const Text('Saved Addresses'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSizes.shellFloatingNavClearance + AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Icon(
                  Icons.location_on_outlined,
                  size: AppSizes.iconLg,
                  color: AppColors.brandPrimary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Delivery address',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            LovenSurfaceCard(
              onTap: _openAddressForm,
              child: Row(
                children: [
                  Container(
                    width: AppSizes.avatarSm,
                    height: AppSizes.avatarSm,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: AppSizes.iconMd,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      addressText,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            if (hasAddress) ...[
              const SizedBox(height: AppSpacing.lg),
              _AddressDetail(label: 'Name', value: _address!['name']),
              _AddressDetail(label: 'Phone', value: _address!['phone']),
              _AddressDetail(
                label: 'Governorate',
                value: _address!['governorate'],
              ),
              _AddressDetail(label: 'Building', value: _address!['building']),
            ],
            const Spacer(),
            LovenPrimaryButton(
              label: hasAddress ? 'Edit address' : 'Add address',
              onPressed: _openAddressForm,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressDetail extends StatelessWidget {
  const _AddressDetail({
    required this.label,
    required this.value,
  });

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}
