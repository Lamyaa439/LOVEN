import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../model/artist_model.dart';

class EditArtistProfilePreview extends StatelessWidget {
  const EditArtistProfilePreview({
    super.key,
    required this.artist,
    this.isSaving = false,
  });

  final ArtistModel artist;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: isSaving ? null : () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(isSaving ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          child: Column(
            children: [
              _CoverSection(),
              const SizedBox(height: 26),
              _AvatarSection(artist: artist),
              const SizedBox(height: 30),

              _FieldSection(
                label: 'Display Name',
                child: TextFormField(
                  initialValue: artist.displayName,
                  decoration: _decoration(
                    hint: 'Display name',
                    icon: Icons.person_outline,
                  ),
                ),
              ),

              _FieldSection(
                label: 'Location',
                child: DropdownButtonFormField<String>(
                  value: artist.city,
                  decoration: _decoration(
                    hint: 'Select city',
                    icon: Icons.location_on_outlined,
                  ),
                  items: const [
                    'Riyadh',
                    'Jeddah',
                    'Dammam',
                    'Khobar',
                    'Mecca',
                    'Medina',
                  ].map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),

              _FieldSection(
                label: 'Artist Category',
                child: TextFormField(
                  initialValue: 'Digital Artist / Illustrator',
                  decoration: _decoration(
                    hint: 'Artist category',
                    icon: Icons.palette_outlined,
                  ),
                ),
              ),

              _FieldSection(
                label: 'Bio',
                child: TextFormField(
                  initialValue: artist.bio,
                  maxLines: 6,
                  maxLength: 500,
                  decoration: _decoration(
                    hint: 'Write a short artist bio',
                    icon: Icons.notes_outlined,
                    alignLabelWithHint: true,
                  ),
                ),
              ),

              _FieldSection(
                label: 'Shipping Policy',
                child: TextFormField(
                  initialValue: artist.shippingPolicy,
                  maxLines: 3,
                  decoration: _decoration(
                    hint: 'Describe shipping availability and timing',
                    icon: Icons.local_shipping_outlined,
                    alignLabelWithHint: true,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              _DangerSection(),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _decoration({
  required String hint,
  required IconData icon,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(icon, size: 18),
    alignLabelWithHint: alignLabelWithHint,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
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

class _CoverSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 138,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.deepPurple,
            AppColors.primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -24,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -34,
            bottom: -42,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image_outlined, size: 15),
              label: const Text('Change Cover'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.artist,
  });

  final ArtistModel artist;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        artist.profileImageUrl != null && artist.profileImageUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primaryPurple,
          backgroundImage:
              hasImage ? NetworkImage(artist.profileImageUrl!) : null,
          child: hasImage
              ? null
              : Text(
                  artist.displayName.isNotEmpty
                      ? artist.displayName[0].toUpperCase()
                      : '?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                      ),
                ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.45,
                ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DangerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FieldSection(
      label: 'Account',
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, size: 17),
          label: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Sign Out'),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            backgroundColor: Colors.red.withValues(alpha: 0.055),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}