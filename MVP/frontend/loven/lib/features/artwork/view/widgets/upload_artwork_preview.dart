import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';

class UploadArtworkPreview extends StatelessWidget {
  const UploadArtworkPreview({
    super.key,
    this.isSubmitting = false,
  });

  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Upload Artwork',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ArtworkImagePicker(),
              const SizedBox(height: 26),

              _FieldSection(
                label: 'Artwork Title',
                child: TextFormField(
                  initialValue: 'Lavender Memory',
                  decoration: _decoration(
                    hint: 'Enter artwork title',
                    icon: Icons.title,
                  ),
                ),
              ),

              _FieldSection(
                label: 'Description',
                child: TextFormField(
                  initialValue:
                      'A soft abstract piece inspired by color, memory, and quiet landscapes.',
                  maxLines: 5,
                  decoration: _decoration(
                    hint: 'Describe your artwork',
                    icon: Icons.notes_outlined,
                    alignLabelWithHint: true,
                  ),
                ),
              ),

              _FieldSection(
                label: 'Category',
                child: DropdownButtonFormField<String>(
                  value: 'Digital Art',
                  decoration: _decoration(
                    hint: 'Select category',
                    icon: Icons.palette_outlined,
                  ),
                  items: const [
                    'Digital Art',
                    'Painting',
                    'Illustration',
                    'Photography',
                    'Mixed Media',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _FieldSection(
                      label: 'Price',
                      child: TextFormField(
                        initialValue: '450',
                        keyboardType: TextInputType.number,
                        decoration: _decoration(
                          hint: 'Price',
                          icon: Icons.payments_outlined,
                        ).copyWith(
                          suffixText: 'SAR',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FieldSection(
                      label: 'Quantity',
                      child: TextFormField(
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        decoration: _decoration(
                          hint: 'Qty',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              _FieldSection(
                label: 'Availability',
                child: Row(
                  children: const [
                    Expanded(
                      child: _AvailabilityChip(
                        label: 'Available',
                        selected: true,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _AvailabilityChip(
                        label: 'Draft',
                        selected: false,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : () {},
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(isSubmitting ? 'Uploading...' : 'Publish Artwork'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtworkImagePicker extends StatelessWidget {
  const _ArtworkImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
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
            top: -30,
            right: -30,
            child: _SoftCircle(size: 150, opacity: 0.12),
          ),
          Positioned(
            bottom: -42,
            left: -38,
            child: _SoftCircle(size: 190, opacity: 0.08),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Add Artwork Image',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'PNG, JPG up to 10MB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
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

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? AppColors.primaryBlue
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
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