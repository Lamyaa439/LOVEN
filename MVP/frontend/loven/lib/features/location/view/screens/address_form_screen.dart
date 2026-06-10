import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  static const _storage = FlutterSecureStorage();
  static const _addressKey = 'saved_delivery_address';

  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final governorateController = TextEditingController();
  final cityController = TextEditingController();
  final blockController = TextEditingController();
  final streetController = TextEditingController();
  final buildingController = TextEditingController();
  final floorController = TextEditingController();
  final flatController = TextEditingController();
  final avenueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final raw = await _storage.read(key: _addressKey);
    if (raw == null) return;

    final data = jsonDecode(raw);

    phoneController.text = data['phone'] ?? '';
    nameController.text = data['name'] ?? '';
    governorateController.text = data['governorate'] ?? '';
    cityController.text = data['city'] ?? '';
    blockController.text = data['block'] ?? '';
    streetController.text = data['street'] ?? '';
    buildingController.text = data['building'] ?? '';
    floorController.text = data['floor'] ?? '';
    flatController.text = data['flat'] ?? '';
    avenueController.text = data['avenue'] ?? '';
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    governorateController.dispose();
    cityController.dispose();
    blockController.dispose();
    streetController.dispose();
    buildingController.dispose();
    floorController.dispose();
    flatController.dispose();
    avenueController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final address = {
      'phone': phoneController.text.trim(),
      'name': nameController.text.trim(),
      'governorate': governorateController.text.trim(),
      'city': cityController.text.trim(),
      'block': blockController.text.trim(),
      'street': streetController.text.trim(),
      'building': buildingController.text.trim(),
      'floor': floorController.text.trim(),
      'flat': flatController.text.trim(),
      'avenue': avenueController.text.trim(),
    };

    await _storage.write(
      key: _addressKey,
      value: jsonEncode(address),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved')),
    );

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xxl,
        ),
        child: Column(
          children: [
            _AddressField(
              label: 'Phone',
              hint: 'Phone number',
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            _AddressField(
              label: 'Name',
              hint: 'Full name',
              controller: nameController,
            ),
            _AddressField(
              label: 'Governorate',
              hint: 'Governorate',
              controller: governorateController,
            ),
            _AddressField(
              label: 'City',
              hint: 'City',
              controller: cityController,
            ),
            _AddressField(
              label: 'Block',
              hint: 'Block',
              controller: blockController,
            ),
            _AddressField(
              label: 'Street name / number',
              hint: 'Street name / number',
              controller: streetController,
            ),
            _AddressField(
              label: 'Building name / number',
              hint: 'Building name / number',
              controller: buildingController,
            ),
            _AddressField(
              label: 'Floor (optional)',
              hint: 'Floor',
              controller: floorController,
            ),
            _AddressField(
              label: 'Flat (optional)',
              hint: 'Flat',
              controller: flatController,
            ),
            _AddressField(
              label: 'Avenue (optional)',
              hint: 'Avenue',
              controller: avenueController,
            ),
            const SizedBox(height: AppSpacing.lg),
            LovenPrimaryButton(
              label: 'Save address',
              onPressed: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          LovenTextField(
            controller: controller,
            hintText: hint,
            keyboardType: keyboardType,
          ),
        ],
      ),
    );
  }
}
