import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/res/theme/app_colors.dart';

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
      const SnackBar(
        content: Text('Address saved'),
      ),
    );

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Address'),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          children: [
            _AddressField(
              label: 'Phone',
              hint: 'Phone',
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            _AddressField(
              label: 'Name',
              hint: 'Name',
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
              hint: 'Floor (optional)',
              controller: floorController,
            ),
            _AddressField(
              label: 'Flat (optional)',
              hint: 'Flat (optional)',
              controller: flatController,
            ),
            _AddressField(
              label: 'Avenue (optional)',
              hint: 'Avenue (optional)',
              controller: avenueController,
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text('Save Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _AddressField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}