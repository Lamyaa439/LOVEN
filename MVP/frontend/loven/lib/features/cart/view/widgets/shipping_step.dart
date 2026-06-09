import 'package:flutter/material.dart';

import 'package:loven/features/cart/view/screens/checkout_screen.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/cart/view/widgets/checkout_stepper.dart';

class ShippingStep extends StatelessWidget {
  const ShippingStep({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
    required this.regionController,
    required this.zipController,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController regionController;
  final TextEditingController zipController;
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;

  static const countries = [
    'Saudi Arabia',
    'United Arab Emirates',
    'Kuwait',
    'Qatar',
    'Bahrain',
    'Oman',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CheckoutStepper(activeStep: CheckoutStep.shipping),
        const SizedBox(height: 24),
        const SectionTitle(
          icon: Icons.local_shipping_outlined,
          title: 'Shipping Details',
        ),
        const SizedBox(height: 18),
        FieldSection(
          label: 'Full Name',
          child: TextFormField(
            controller: nameController,
            decoration: checkoutDecoration(
              hint: 'Full name',
              icon: Icons.person_outline,
            ),
          ),
        ),
        FieldSection(
          label: 'Email',
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: checkoutDecoration(
              hint: 'Email',
              icon: Icons.mail_outline,
            ),
          ),
        ),
        FieldSection(
          label: 'Phone',
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: checkoutDecoration(
              hint: 'Phone',
              icon: Icons.phone_outlined,
            ),
          ),
        ),
        FieldSection(
          label: 'Address',
          child: TextFormField(
            controller: addressController,
            decoration: checkoutDecoration(
              hint: 'Address',
              icon: Icons.location_on_outlined,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FieldSection(
                label: 'City',
                child: TextFormField(
                  controller: cityController,
                  decoration: checkoutDecoration(
                    hint: 'City',
                    icon: Icons.apartment_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FieldSection(
                label: 'Region',
                child: TextFormField(
                  controller: regionController,
                  decoration: checkoutDecoration(
                    hint: 'Region',
                    icon: Icons.explore_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: FieldSection(
                label: 'ZIP Code',
                child: TextFormField(
                  controller: zipController,
                  keyboardType: TextInputType.number,
                  decoration: checkoutDecoration(
                    hint: 'ZIP code',
                    icon: Icons.markunread_mailbox_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FieldSection(
                label: 'Country',
                child: DropdownButtonFormField<String>(
                  value: selectedCountry,
                  decoration: checkoutDecoration(
                    hint: 'Select country',
                    icon: Icons.public_outlined,
                  ),
                  items: countries
                      .map(
                        (country) => DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        ),
                      )
                      .toList(),
                  onChanged: onCountryChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}