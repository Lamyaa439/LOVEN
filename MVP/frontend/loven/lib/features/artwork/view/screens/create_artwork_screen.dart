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
  State<CreateArtworkScreen> createState() =>
      _CreateArtworkScreenState();
}

class _CreateArtworkScreenState
    extends State<CreateArtworkScreen> {
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

    if (authState is! AuthSuccess || authState.user == null) {
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
      final imageUrl =
          await _storageService.uploadArtworkImage(
        imageFile: _selectedImage!,
        artistId: authState.user!.id,
      );

      if (!mounted) return;

      context.read<ArtworkCubit>().createArtwork(
            title: titleController.text.trim(),
            description:
                descriptionController.text.trim(),
            price: double.parse(
              priceController.text.trim(),
            ),
            quantityAvailable: int.parse(
              quantityController.text.trim(),
            ),
            shippingFee: double.parse(
              shippingFeeController.text.trim(),
            ),
            artworkImageUrl: imageUrl,
          );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image upload failed: $e',
          ),
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
    final theme = Theme.of(context);

    return BlocConsumer<ArtworkCubit, ArtworkState>(
      listener: (context, state) {
        if (state is ArtworkLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Artwork uploaded successfully'),
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
        final isLoading =
            state is ArtworkLoading || _isUploadingImage;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Upload Artwork'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Artwork Image',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _ArtworkImagePicker(
                    selectedImage: _selectedImage,
                    onTap: _pickArtworkImage,
                  ),

                  const SizedBox(height: 22),

                  _InputField(
                    controller: titleController,
                    label: 'Title',
                    validatorMessage:
                        'Title is required',
                  ),

                  const SizedBox(height: 14),

                  _InputField(
                    controller:
                        descriptionController,
                    label: 'Description',
                    validatorMessage:
                        'Description is required',
                    maxLines: 4,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _InputField(
                          controller:
                              priceController,
                          label: 'Price',
                          validatorMessage:
                              'Price is required',
                          keyboardType:
                              TextInputType.number,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _InputField(
                          controller:
                              shippingFeeController,
                          label: 'Shipping',
                          validatorMessage:
                              'Shipping fee is required',
                          keyboardType:
                              TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _InputField(
                    controller:
                        quantityController,
                    label: 'Quantity Available',
                    validatorMessage:
                        'Quantity is required',
                    keyboardType:
                        TextInputType.number,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed:
                          isLoading ? null : _submit,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.cloud_upload_outlined,
                            ),
                      label: Text(
                        isLoading
                            ? 'Uploading...'
                            : 'Upload Artwork',
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        textStyle: theme
                            .textTheme.bodyMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Uint8List?>(
        future: selectedImage?.readAsBytes(),
        builder: (context, snapshot) {
          final hasImage = snapshot.hasData;

          return Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryPurple
                    .withValues(alpha: 0.18),
              ),
              image: hasImage
                  ? DecorationImage(
                      image: MemoryImage(
                        snapshot.data!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(alpha: 0.45),
                        borderRadius:
                            BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            AppColors.primaryPurple
                                .withValues(
                          alpha: 0.16,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.primaryBlue,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Tap to upload artwork image',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'JPG or PNG, recommended square image',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String validatorMessage;
  final TextInputType keyboardType;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.validatorMessage,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return validatorMessage;
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}