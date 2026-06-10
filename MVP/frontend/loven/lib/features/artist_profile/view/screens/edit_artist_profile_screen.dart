import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_cubit.dart';
import 'package:loven/features/artist_profile/controller/artist_profile_state.dart';
import 'package:loven/features/artist_profile/data/services/artist_profile_image_storage_service.dart';
import 'package:loven/features/artist_profile/model/artist_model.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/home/controller/bloc/home_bloc.dart';
import 'package:loven/features/home/controller/bloc/home_event.dart';

class EditArtistProfileScreen extends StatefulWidget {
  const EditArtistProfileScreen({
    super.key,
    required this.artist,
  });

  final ArtistModel artist;

  @override
  State<EditArtistProfileScreen> createState() =>
      _EditArtistProfileScreenState();
}

class _EditArtistProfileScreenState extends State<EditArtistProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _shippingPolicyController;
  late final String _initialDisplayName;
  late final String _initialCity;
  late final String _initialBio;
  late final String _initialShippingPolicy;

  String? _selectedCity;

  final _picker = ImagePicker();
  final _imageStorageService = ArtistProfileImageStorageService();

  XFile? _selectedProfileImage;
  XFile? _selectedCoverImage;
  bool _isUploadingImages = false;

  final List<String> _cities = const [
    'Riyadh',
    'Jeddah',
    'Mecca',
    'Medina',
    'Dammam',
    'Khobar',
    'Dhahran',
    'Taif',
    'Tabuk',
    'Abha',
    'Hail',
    'Jazan',
    'Najran',
    'Al Bahah',
    'Al Ahsa',
    'Yanbu',
  ];

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.artist.displayName);
    final initialCity = widget.artist.city?.trim();
    _selectedCity =
        initialCity == null || initialCity.isEmpty ? null : initialCity;
    _bioController = TextEditingController(text: widget.artist.bio ?? '');
    _shippingPolicyController =
        TextEditingController(text: widget.artist.shippingPolicy ?? '');
    _initialDisplayName = widget.artist.displayName;
    _initialCity = widget.artist.city ?? '';
    _initialBio = widget.artist.bio ?? '';
    _initialShippingPolicy = widget.artist.shippingPolicy ?? '';
    _displayNameController.addListener(() => setState(() {}));
    _bioController.addListener(() => setState(() {}));
    _shippingPolicyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _shippingPolicyController.dispose();
    super.dispose();
  }

bool get _hasChanges {
  return _displayNameController.text.trim() != _initialDisplayName.trim() ||
      (_selectedCity ?? '').trim() != _initialCity.trim() ||
      _bioController.text.trim() != _initialBio.trim() ||
      _shippingPolicyController.text.trim() != _initialShippingPolicy.trim() ||
      _selectedProfileImage != null ||
      _selectedCoverImage != null;
}

  Future<void> _pickProfileImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
    );
    if (image == null) return;
    setState(() => _selectedProfileImage = image);
  }

  Future<void> _pickCoverImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1400,
    );
    if (image == null) return;
    setState(() => _selectedCoverImage = image);
  }

  Future<void> _save() async {
    if (!_hasChanges) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields')),
      );
      return;
    }

    if (!authStateHasSession(context.read<AuthCubit>().state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please sign in again.')),
      );
      return;
    }

    setState(() => _isUploadingImages = true);

    try {
      String? profileImageUrl = widget.artist.profileImageUrl;
      String? coverImageUrl = widget.artist.coverImageUrl;

      if (_selectedProfileImage != null) {
        profileImageUrl = await _imageStorageService.uploadProfileImage(
          imageFile: _selectedProfileImage!,
          artistId: widget.artist.id,
        );
      }

      if (_selectedCoverImage != null) {
        coverImageUrl = await _imageStorageService.uploadCoverImage(
          imageFile: _selectedCoverImage!,
          artistId: widget.artist.id,
        );
      }

      if (!mounted) return;

      await context.read<ArtistProfileCubit>().updateProfileInfo(
            displayName: _displayNameController.text.trim(),
            city: _selectedCity?.trim(),
            bio: _bioController.text.trim(),
            shippingPolicy: _shippingPolicyController.text.trim(),
            profileImageUrl: profileImageUrl,
            coverImageUrl: coverImageUrl,
          );

      if (!mounted) return;

      final state = context.read<ArtistProfileCubit>().state;
      if (state.status == ArtistProfileStatus.error) {
        return;
      }

      if (state.status == ArtistProfileStatus.success) {
        context.read<HomeBloc>().add(FetchHomeData());
        context.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImages = false);
    }
  }

  List<String> get _cityOptions {
    final selected = _selectedCity;
    if (selected != null &&
        selected.isNotEmpty &&
        !_cities.contains(selected)) {
      return [selected, ..._cities];
    }
    return _cities;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArtistProfileCubit, ArtistProfileState>(
      listener: (context, state) {
        if (state.status == ArtistProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not update profile'),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == ArtistProfileStatus.loading || _isUploadingImages;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Artist profile'),
            leading: lovenPushedScreenBackLeading(context),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Update how collectors see your storefront.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _CoverSection(
                      artist: widget.artist,
                      selectedCoverImage: _selectedCoverImage,
                      onPickCover: isLoading ? null : _pickCoverImage,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _AvatarSection(
                      artist: widget.artist,
                      selectedProfileImage: _selectedProfileImage,
                      onPickProfileImage:
                          isLoading ? null : _pickProfileImage,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    CheckoutFieldSection(
                      label: 'Display name',
                      child: LovenTextField(
                        controller: _displayNameController,
                        hintText: 'Display name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Display name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    CheckoutFieldSection(
                      label: 'Location',
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: checkoutInputDecoration(
                          hint: 'Select city',
                          icon: Icons.location_on_outlined,
                        ),
                        items: _cityOptions
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                        onChanged: isLoading
                            ? null
                            : (value) => setState(() => _selectedCity = value),
                      ),
                    ),
                    CheckoutFieldSection(
                      label: 'Bio',
                      child: LovenTextField(
                        controller: _bioController,
                        hintText: 'Write a short artist bio',
                        maxLines: 7,
                      ),
                    ),
                    CheckoutFieldSection(
                      label: 'Shipping policy',
                      child: LovenTextField(
                        controller: _shippingPolicyController,
                        hintText: 'Describe shipping availability and timing',
                        maxLines: 3,
                      ),
                    ),
                    LovenPrimaryButton(
                      label: isLoading ? 'Saving…' : 'Save changes',
                      onPressed: (isLoading || !_hasChanges) ? null : _save,
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

class _CoverSection extends StatelessWidget {
  const _CoverSection({
    required this.artist,
    required this.selectedCoverImage,
    required this.onPickCover,
  });

  final ArtistModel artist;
  final XFile? selectedCoverImage;
  final VoidCallback? onPickCover;

  @override
  Widget build(BuildContext context) {
    final hasNetworkCover =
        artist.coverImageUrl != null && artist.coverImageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onPickCover,
      child: FutureBuilder<Uint8List?>(
        future: selectedCoverImage?.readAsBytes(),
        builder: (context, snapshot) {
          final hasSelectedImage = snapshot.hasData;
          DecorationImage? coverImage;

          if (hasSelectedImage) {
            coverImage = DecorationImage(
              image: MemoryImage(snapshot.data!),
              fit: BoxFit.cover,
            );
          } else if (hasNetworkCover) {
            coverImage = DecorationImage(
              image: NetworkImage(artist.coverImageUrl!),
              fit: BoxFit.cover,
            );
          }

          return Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: AppColors.surfaceSoft,
              image: coverImage,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (coverImage != null)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.scrim.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                Positioned(
  right: AppSpacing.sm,
  bottom: AppSpacing.sm,
  child: CircleAvatar(
    radius: AppSizes.iconMd,
    backgroundColor: AppColors.brandPrimary,
    child: IconButton(
      icon: Icon(
        Icons.camera_alt_outlined,
        size: AppSizes.iconSm,
        color: AppColors.textOnBrand,
      ),
      onPressed: onPickCover,
    ),
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

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.artist,
    required this.selectedProfileImage,
    required this.onPickProfileImage,
  });

  final ArtistModel artist;
  final XFile? selectedProfileImage;
  final VoidCallback? onPickProfileImage;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        artist.profileImageUrl != null && artist.profileImageUrl!.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: onPickProfileImage,
        child: FutureBuilder<Uint8List?>(
          future: selectedProfileImage?.readAsBytes(),
          builder: (context, snapshot) {
            final hasSelectedImage = snapshot.hasData;
            ImageProvider? imageProvider;

            if (hasSelectedImage) {
              imageProvider = MemoryImage(snapshot.data!);
            } else if (hasNetworkImage) {
              imageProvider = NetworkImage(artist.profileImageUrl!);
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: AppSizes.avatarLg / 2,
                  backgroundColor: AppColors.surfaceSoft,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(
                          artist.displayName.isNotEmpty
                              ? artist.displayName[0].toUpperCase()
                              : '?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.brandPrimary,
                              ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: AppSizes.iconMd,
                    backgroundColor: AppColors.brandPrimary,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: AppSizes.iconSm,
                      color: AppColors.textOnBrand,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
