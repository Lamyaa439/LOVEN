import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_state.dart';
import 'package:loven/features/artwork/data/services/artwork_image_storage_service.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';

class CreateArtworkScreen extends StatefulWidget {
  const CreateArtworkScreen({super.key});

  @override
  State<CreateArtworkScreen> createState() => _CreateArtworkScreenState();
}

class _CreateArtworkScreenState extends State<CreateArtworkScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final shippingFeeController = TextEditingController();

  final _picker = ImagePicker();
  final _storageService = ArtworkImageStorageService();

  XFile? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    shippingFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickArtworkImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
      maxWidth: 1200,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = pickedFile;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an artwork image'),
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;

    if (!authStateHasSession(authState)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again before uploading artwork'),
        ),
      );
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await _storageService.uploadArtworkImage(
        imageFile: _selectedImage!,
        artistId: authStateSessionUser(authState)!.id,
      );

      if (!mounted) return;

      context.read<ArtworkCubit>().createArtwork(
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            price: double.parse(priceController.text.trim()),
            quantityAvailable: int.parse(quantityController.text.trim()),
            shippingFee: double.parse(shippingFeeController.text.trim()),
            artworkImageUrl: imageUrl,
          );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArtworkCubit, ArtworkState>(
      listener: (context, state) {
        if (state is ArtworkLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artwork uploaded successfully'),
            ),
          );

          context.read<HomeBloc>().add(FetchHomeData());
          context.pop(true);
        }

        if (state is ArtworkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ArtworkLoading || _isUploadingImage;

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ArtworkImagePicker(
                      selectedImage: _selectedImage,
                      onTap: isLoading ? null : _pickArtworkImage,
                    ),
                    const SizedBox(height: 26),

                    _FieldSection(
                      label: 'Artwork Title',
                      child: _InputField(
                        controller: titleController,
                        hint: 'Enter artwork title',
                        icon: Icons.title,
                        validatorMessage: 'Title is required',
                      ),
                    ),

                    _FieldSection(
                      label: 'Description',
                      child: _InputField(
                        controller: descriptionController,
                        hint: 'Describe your artwork',
                        icon: Icons.notes_outlined,
                        validatorMessage: 'Description is required',
                        maxLines: 5,
                        alignLabelWithHint: true,
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _FieldSection(
                            label: 'Price',
                            child: _InputField(
                              controller: priceController,
                              hint: 'Price',
                              icon: Icons.payments_outlined,
                              validatorMessage: 'Price is required',
                              keyboardType: TextInputType.number,
                              suffixText: 'SAR',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FieldSection(
                            label: 'Shipping',
                            child: _InputField(
                              controller: shippingFeeController,
                              hint: 'Shipping',
                              icon: Icons.local_shipping_outlined,
                              validatorMessage: 'Shipping fee is required',
                              keyboardType: TextInputType.number,
                              suffixText: 'SAR',
                            ),
                          ),
                        ),
                      ],
                    ),

                    _FieldSection(
                      label: 'Quantity',
                      child: _InputField(
                        controller: quantityController,
                        hint: 'Quantity available',
                        icon: Icons.inventory_2_outlined,
                        validatorMessage: 'Quantity is required',
                        keyboardType: TextInputType.number,
                      ),
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
                        onPressed: isLoading ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          isLoading ? 'Uploading...' : 'Publish Artwork',
                        ),
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
          ),
        );
      },
    );
  }
}

class _ArtworkImagePicker extends StatelessWidget {
  const _ArtworkImagePicker({
    required this.selectedImage,
    required this.onTap,
  });

  final XFile? selectedImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Uint8List?>(
        future: selectedImage?.readAsBytes(),
        builder: (context, snapshot) {
          final hasImage = snapshot.hasData;

          return Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: hasImage
                  ? null
                  : const LinearGradient(
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.deepPurple,
                        AppColors.primaryBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              image: hasImage
                  ? DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage ? const _SelectedImageOverlay() : const _EmptyImageState(),
          );
        },
      ),
    );
  }
}

class _EmptyImageState extends StatelessWidget {
  const _EmptyImageState();

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}

class _SelectedImageOverlay extends StatelessWidget {
  const _SelectedImageOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.32),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 15,
                  color: Colors.black87,
                ),
                SizedBox(width: 6),
                Text(
                  'Change Image',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
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

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validatorMessage,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixText,
    this.alignLabelWithHint = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String validatorMessage;
  final TextInputType keyboardType;
  final int maxLines;
  final String? suffixText;
  final bool alignLabelWithHint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMessage;
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          icon,
          size: 18,
          color: AppColors.deepPurple,
        ),
        suffixText: suffixText,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade400,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1.3,
          ),
        ),
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