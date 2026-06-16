import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_cubit.dart';
import 'package:loven/features/artwork/controller/cubit/artwork_state.dart';
import 'package:loven/features/artwork/data/services/artwork_image_storage_service.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

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

  String? _selectedCategory;

List<String> _artworkCategories(AppLocalizations l10n) => [
  l10n.oilPainting,
  l10n.calligraphy,
  l10n.photography,
  l10n.digitalArt,
];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final profileCubit = context.read<ArtistProfileCubit>();
      if (profileCubit.state.artist == null) {
        profileCubit.fetchMyProfileData();
      }
    });
  }

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

    setState(() => _selectedImage = pickedFile);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.pleaseSelectArtworkImage)),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;

    if (!authStateHasSession(authState)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseLoginAgain),
        ),
      );
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      final profileCubit = context.read<ArtistProfileCubit>();
      await profileCubit.fetchMyProfileData();

      if (!mounted) return;

      final imageUrl = await _storageService.uploadArtworkImage(
        imageFile: _selectedImage!,
        artistId: authStateSessionUser(authState)!.id,
      );

      if (!mounted) return;

      final artist = profileCubit.state.artist;
      final isVerifiedArtist = artist?.isVerified ?? false;

      context.read<ArtworkCubit>().createArtwork(
            title: titleController.text.trim(),
            description:
    '[Category: $_selectedCategory]\n${descriptionController.text.trim()}',
            price: double.parse(priceController.text.trim()),
            quantityAvailable: int.parse(quantityController.text.trim()),
            shippingFee: double.parse(shippingFeeController.text.trim()),
            artworkImageUrl: imageUrl,
            status: isVerifiedArtist ? 'available' : 'hidden',
          );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.imageUploadFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ArtworkCubit, ArtworkState>(
      listener: (context, state) {
        if (state is ArtworkLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.artworkUploadedSuccessfully)),
          );

          context.read<HomeBloc>().add(FetchHomeData());
          context.pop(true);
        }

        if (state is ArtworkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ArtworkLoading || _isUploadingImage;
        final artist = context.watch<ArtistProfileCubit>().state.artist;
        final isVerifiedArtist = artist?.isVerified ?? false;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(l10n.uploadArtwork),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.xxxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ArtworkImagePicker(
                      selectedImage: _selectedImage,
                      onTap: isLoading ? null : _pickArtworkImage,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    CheckoutFieldSection(
                      label: l10n.artworkTitle,
                      child: LovenTextField(
                        controller: titleController,
                        hintText: l10n.enterArtworkTitle,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.titleIsRequired;
                          }
                          return null;
                        },
                      ),
                    ),
CheckoutFieldSection(
  label: l10n.category,
  child: LovenSurfaceCard(
    onTap: isLoading
        ? null
        : () async {
            final selected = await showModalBottomSheet<String>(
              context: context,
              showDragHandle: true,
              builder: (sheetContext) {
                final categories = _artworkCategories(l10n);

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: categories.map((category) {
                        final isSelected = category == _selectedCategory;

                        return ListTile(
                          title: Text(category),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded)
                              : null,
                          onTap: () => Navigator.pop(sheetContext, category),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );

            if (selected != null) {
              setState(() => _selectedCategory = selected);
            }
          },
    child: Row(
      children: [
        const Icon(Icons.category_outlined, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            _selectedCategory ?? l10n.selectCategory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _selectedCategory == null
                      ? AppColors.textMuted
                      : null,
                ),
          ),
        ),
        const Icon(Icons.keyboard_arrow_down_rounded),
      ],
    ),
  ),
),
                    CheckoutFieldSection(
                      label: l10n.description,
                      child: LovenTextField(
                        controller: descriptionController,
                        hintText: l10n.describeYourArtwork,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.descriptionIsRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CheckoutFieldSection(
                            label: l10n.priceSAR,
                            child: LovenTextField(
                              controller: priceController,
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.required;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CheckoutFieldSection(
                            label: l10n.shippingSAR,
                            child: LovenTextField(
                              controller: shippingFeeController,
                              hintText: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.required;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    CheckoutFieldSection(
                      label: l10n.quantity,
                      child: LovenTextField(
                        controller: quantityController,
                        hintText: l10n.quantityAvailable,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.quantityIsRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    LovenSurfaceCard(
                      child: Row(
                        children: [
                          Icon(
                            isVerifiedArtist
                                ? Icons.check_circle_outline
                                : Icons.visibility_outlined,
                            color: isVerifiedArtist
                                ? AppColors.success
                                : AppColors.textMuted,
                            size: AppSizes.iconMd,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isVerifiedArtist
                                      ? l10n.availableForSale
                                      : l10n.portfolioShowcaseOnly,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  isVerifiedArtist
                                      ? l10n.willBeListedForPurchase
                                      : l10n.visibleInPortfolioUntilVerified,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isVerifiedArtist) ...[
                      const SizedBox(height: AppSpacing.md),
                      LovenSurfaceCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.warning,
                              size: AppSizes.iconMd,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.portfolioMode,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    l10n.unverifiedArtistNote,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sectionGap),
                    LovenPrimaryButton(
                      label: isLoading
                          ? l10n.uploading
                          : isVerifiedArtist
                              ? l10n.publishArtwork
                              : l10n.saveToPortfolio,
                      icon: Icons.cloud_upload_outlined,
                      onPressed: isLoading ? null : _submit,
                      isLoading: isLoading,
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
            height: AppSizes.discoverFeaturedHeight + AppSpacing.xxl,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: AppColors.surfaceSoft,
              border: Border.all(color: AppColors.borderLight),
              image: hasImage
                  ? DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.scrim.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: LovenSecondaryButton(
                          label: AppLocalizations.of(context)!.changeImage,
                          onPressed: onTap,
                          expand: false,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: AppSizes.avatarLg,
                        height: AppSizes.avatarLg,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.brandPrimary,
                          size: AppSizes.iconLg,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppLocalizations.of(context)!.addArtworkImage,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        AppLocalizations.of(context)!.pngOrJpg,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
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
