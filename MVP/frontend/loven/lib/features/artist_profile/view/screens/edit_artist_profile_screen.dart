import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/res/theme/app_colors.dart';
import '../../controller/artist_profile_cubit.dart';
import '../../controller/artist_profile_state.dart';
import '../../data/services/artist_profile_image_storage_service.dart';
import '../../model/artist_model.dart';

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
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;
  late final TextEditingController _shippingPolicyController;

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
    _cityController = TextEditingController(text: widget.artist.city ?? '');
    _bioController = TextEditingController(text: widget.artist.bio ?? '');
    _shippingPolicyController =
        TextEditingController(text: widget.artist.shippingPolicy ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _shippingPolicyController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
    );

    if (image == null) return;

    setState(() {
      _selectedProfileImage = image;
    });
  }

  Future<void> _pickCoverImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1400,
    );

    if (image == null) return;

    setState(() {
      _selectedCoverImage = image;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploadingImages = true;
    });

    try {
      String? profileImageUrl = widget.artist.profileImageUrl;
      String? coverImageUrl = widget.artist.coverImageUrl;

      if (_selectedProfileImage != null) {
        profileImageUrl = await _imageStorageService.uploadProfileImage(
          imageFile: _selectedProfileImage!,
          artistId: widget.artist.id,
        );
        print('UPLOADED PROFILE URL: $profileImageUrl');
      }

      if (_selectedCoverImage != null) {
        coverImageUrl = await _imageStorageService.uploadCoverImage(
          imageFile: _selectedCoverImage!,
          artistId: widget.artist.id,
        );
        print('UPLOADED COVER URL: $coverImageUrl');
      }

      if (!mounted) return;

      await context.read<ArtistProfileCubit>().updateProfileInfo(
            displayName: _displayNameController.text.trim(),
            city: _cityController.text.trim(),
            bio: _bioController.text.trim(),
            shippingPolicy: _shippingPolicyController.text.trim(),
            profileImageUrl: profileImageUrl,
            coverImageUrl: coverImageUrl,
          );

      if (!mounted) return;

      final state = context.read<ArtistProfileCubit>().state;

      if (state.status == ArtistProfileStatus.success) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update profile: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
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
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.red.shade400,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.3,
        ),
      ),
    );
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
                  onPressed: isLoading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(isLoading ? 'Saving...' : 'Save'),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _CoverSection(
                      artist: widget.artist,
                      selectedCoverImage: _selectedCoverImage,
                      onPickCover: isLoading ? null : _pickCoverImage,
                    ),
                    const SizedBox(height: 26),
                    _AvatarSection(
                      artist: widget.artist,
                      selectedProfileImage: _selectedProfileImage,
                      onPickProfileImage:
                          isLoading ? null : _pickProfileImage,
                    ),
                    const SizedBox(height: 30),
                    EditProfileField(
                      label: 'Display Name',
                      child: TextFormField(
                        controller: _displayNameController,
                        decoration: _inputDecoration(
                          hint: 'Display name',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Display name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    EditProfileField(
                      label: 'Location',
                      child: DropdownButtonFormField<String>(
                        value: _cityController.text.isEmpty
                            ? null
                            : _cityController.text,
                        decoration: _inputDecoration(
                          hint: 'Select city',
                          icon: Icons.location_on_outlined,
                        ),
                        items: _cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _cityController.text = value ?? '';
                        },
                      ),
                    ),
                    EditProfileField(
                      label: 'Artist Category',
                      child: TextFormField(
                        initialValue: 'Digital Artist / Illustrator',
                        decoration: _inputDecoration(
                          hint: 'Artist category',
                          icon: Icons.palette_outlined,
                        ),
                      ),
                    ),
                    EditProfileField(
                      label: 'Bio',
                      child: TextFormField(
                        controller: _bioController,
                        maxLines: 7,
                        maxLength: 500,
                        decoration: _inputDecoration(
                          hint: 'Write a short artist bio',
                          icon: Icons.notes_outlined,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    EditProfileField(
                      label: 'Shipping Policy',
                      child: TextFormField(
                        controller: _shippingPolicyController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          hint: 'Describe shipping availability and timing',
                          icon: Icons.local_shipping_outlined,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AccountSection(
                      onSignOut: () {},
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
            height: 132,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: coverImage == null
                  ? const LinearGradient(
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.deepPurple,
                        AppColors.primaryBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              image: coverImage,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (coverImage == null) ...[
                  Positioned(
                    right: -18,
                    top: -12,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 118,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Positioned(
                    left: -16,
                    bottom: -20,
                    child: Icon(
                      Icons.brush_outlined,
                      size: 112,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ],
                if (coverImage != null)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: FilledButton.icon(
                    onPressed: onPickCover,
                    icon: const Icon(Icons.image_outlined, size: 15),
                    label: const Text('Change Cover'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.88),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
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
        artist.profileImageUrl != null &&
        artist.profileImageUrl!.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: onPickProfileImage,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FutureBuilder<Uint8List?>(
              future: selectedProfileImage?.readAsBytes(),
              builder: (context, snapshot) {
                final hasSelectedImage = snapshot.hasData;

                ImageProvider? imageProvider;

                if (hasSelectedImage) {
                  imageProvider = MemoryImage(snapshot.data!);
                } else if (hasNetworkImage) {
                  imageProvider =
                      NetworkImage(artist.profileImageUrl!);
                }

                return CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primaryPurple,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(
                          artist.displayName.isNotEmpty
                              ? artist.displayName[0]
                                  .toUpperCase()
                              : '?',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color:
                                    AppColors.primaryBlue,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                        )
                      : null,
                );
              },
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: CircleAvatar(
                radius: 15,
                backgroundColor:
                    AppColors.primaryBlue,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileField extends StatelessWidget {
  const EditProfileField({
    super.key,
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

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.onSignOut,
  });

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.45,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: onSignOut,
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
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}