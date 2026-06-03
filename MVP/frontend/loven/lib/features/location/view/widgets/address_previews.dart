import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';

class AddressSelectorPreview extends StatelessWidget {
  const AddressSelectorPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final addresses = _mockAddresses;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: Icons.local_shipping_outlined,
                title: 'Shipping Details',
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    _IconBubble(icon: Icons.bookmark_border),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Addresses',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${addresses.length} addresses available',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...addresses.map(
                (address) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CompactAddressTile(address: address),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Manage Addresses'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressBookPreview extends StatelessWidget {
  const AddressBookPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final addresses = _mockAddresses;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Address Book',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              itemCount: addresses.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    '${addresses.length} addresses saved',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.w700,
                        ),
                  );
                }

                return _AddressBookCard(
                  address: addresses[index - 1],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddAddressPreview extends StatelessWidget {
  const AddAddressPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.close),
        ),
        title: Text(
          'New Address',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _FieldSection(
                      label: 'Label (optional)',
                      child: TextFormField(
                        decoration: _inputDecoration(
                          hint: 'Home, Studio, etc.',
                          icon: Icons.sell_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FieldSection(
                      label: 'Full Name',
                      child: TextFormField(
                        decoration: _inputDecoration(
                          hint: 'Your full name',
                          icon: Icons.person_outline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _FieldSection(
                label: 'Email',
                child: TextFormField(
                  decoration: _inputDecoration(
                    hint: 'you@example.com',
                    icon: Icons.mail_outline,
                  ),
                ),
              ),
              _FieldSection(
                label: 'Phone',
                child: TextFormField(
                  decoration: _inputDecoration(
                    hint: '(555) 000-0000',
                    icon: Icons.phone_outlined,
                  ),
                ),
              ),
              _FieldSection(
                label: 'Address',
                child: TextFormField(
                  decoration: _inputDecoration(
                    hint: 'Street address, apt, suite',
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _FieldSection(
                      label: 'City',
                      child: TextFormField(
                        decoration: _inputDecoration(
                          hint: 'City',
                          icon: Icons.apartment_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FieldSection(
                      label: 'State',
                      child: TextFormField(
                        decoration: _inputDecoration(
                          hint: 'State / Province',
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
                    child: _FieldSection(
                      label: 'ZIP Code',
                      child: TextFormField(
                        decoration: _inputDecoration(
                          hint: '12345',
                          icon: Icons.markunread_mailbox_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FieldSection(
                      label: 'Country',
                      child: TextFormField(
                        initialValue: 'Saudi Arabia',
                        decoration: _inputDecoration(
                          hint: 'Country',
                          icon: Icons.public_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Set as default',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactAddressTile extends StatelessWidget {
  const _CompactAddressTile({
    required this.address,
  });

  final _Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _AddressLabel(address: address),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      const _DefaultBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  address.singleLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class _AddressBookCard extends StatelessWidget {
  const _AddressBookCard({
    required this.address,
  });

  final _Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: address.isDefault
              ? AppColors.primaryBlue.withValues(alpha: 0.28)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AddressLabel(address: address),
              const SizedBox(width: 8),
              if (address.isDefault)
                const _DefaultBadge()
              else
                TextButton(
                  onPressed: () {},
                  child: const Text('Set as default'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            address.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            address.multiline,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '${address.phone}      ${address.email}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black38,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Divider(
            color: Colors.black.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBubble(icon: icon),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 18,
        color: AppColors.deepPurple,
      ),
    );
  }
}

class _AddressLabel extends StatelessWidget {
  const _AddressLabel({
    required this.address,
  });

  final _Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        address.label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.deepPurple,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _FieldSection extends StatelessWidget {
  const _FieldSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.black.withValues(alpha: 0.04),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(
      icon,
      size: 18,
      color: AppColors.deepPurple,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.black.withValues(alpha: 0.08),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.black.withValues(alpha: 0.08),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.primaryBlue,
        width: 1.3,
      ),
    ),
  );
}

final _mockAddresses = [
  const _Address(
    label: 'Home',
    name: 'Aria Chen',
    street: '842 Mission Street, Apt 3B',
    city: 'San Francisco',
    region: 'California',
    postalCode: '94103',
    country: 'United States',
    phone: '(415) 555-0182',
    email: 'aria.chen@example.com',
    isDefault: true,
  ),
  const _Address(
    label: 'Studio',
    name: 'Aria Chen',
    street: '1446 Market Street, Suite 200',
    city: 'San Francisco',
    region: 'California',
    postalCode: '94102',
    country: 'United States',
    phone: '(415) 555-9400',
    email: 'aria@studiochen.com',
  ),
  const _Address(
    label: 'Gallery',
    name: 'Marcus Chen',
    street: '721 Broadway, Floor 4',
    city: 'Los Angeles',
    region: 'California',
    postalCode: '90014',
    country: 'United States',
    phone: '(310) 555-3371',
    email: 'marcus@example.com',
  ),
];

class _Address {
  const _Address({
    required this.label,
    required this.name,
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
    required this.phone,
    required this.email,
    this.isDefault = false,
  });

  final String label;
  final String name;
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final String country;
  final String phone;
  final String email;
  final bool isDefault;

  String get singleLine => '$street, $city, $region $postalCode';

  String get multiline => '$street\n$city, $region $postalCode\n$country';
}