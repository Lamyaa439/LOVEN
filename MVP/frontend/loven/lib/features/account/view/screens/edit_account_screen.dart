import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loven/core/res/theme/app_colors.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';
import 'package:loven/features/account/controller/cubit/account_state.dart';
import 'package:loven/features/account/data/services/profile_image_storage_service.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';

/// Edit signed-in account profile (`/profile/edit`).
///
/// Persists via [AccountCubit.updateAccount]; image upload via account storage service.
class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  XFile? _selectedImage;
  final _imagePicker = ImagePicker();
  bool initialized = false;
  bool _isLoadingInitial = false;

  @override
  void initState() {
    super.initState();
    final sessionUser =
        authStateSessionUser(context.read<AuthCubit>().state);
    if (sessionUser != null) {
      initialized = true;
      nameController.text = sessionUser.name;
      emailController.text = sessionUser.email;
      return;
    }

    _isLoadingInitial = true;
    context.read<AccountCubit>().loadAccount().whenComplete(() {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 800,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = pickedFile;
    });
  }

  AuthUser? _profileFromState(AccountState accountState) {
    return switch (accountState) {
      AccountLoaded(:final user) => user,
      AccountFailure(:final user) => user,
      _ => authStateSessionUser(context.read<AuthCubit>().state),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: BlocConsumer<AccountCubit, AccountState>(
        listener: (context, state) {
          if (state is AccountFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is AccountLoaded && !initialized) {
            initialized = true;
            nameController.text = state.user.name;
            emailController.text = state.user.email;
          }
        },
        builder: (context, accountState) {
          if (_isLoadingInitial && !initialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final profile = _profileFromState(accountState);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: FutureBuilder<Uint8List?>(
                    future: _selectedImage?.readAsBytes(),
                    builder: (context, snapshot) {
                      final currentImageUrl = profile?.profileImageUrl;
                      final hasCurrentImage =
                          currentImageUrl != null && currentImageUrl.isNotEmpty;

                      ImageProvider<Object>? imageProvider;

                      if (snapshot.hasData) {
                        imageProvider = MemoryImage(snapshot.data!);
                      } else if (hasCurrentImage) {
                        imageProvider = NetworkImage(currentImageUrl);
                      }

                      return CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primaryPurple.withValues(
                          alpha: 0.25,
                        ),
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 36,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                _AccountField(
                  label: 'Name',
                  controller: nameController,
                ),
                const SizedBox(height: 18),
                _AccountField(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      String? profileImageUrl;

                      final sessionUser =
                          authStateSessionUser(context.read<AuthCubit>().state);
                      if (_selectedImage != null && sessionUser != null) {
                        profileImageUrl = await context
                            .read<ProfileImageStorageService>()
                            .uploadProfileImage(
                          imageFile: _selectedImage!,
                          userId: sessionUser.id,
                        );
                      }

                      if (!context.mounted) {
                        return;
                      }

                      context.read<AccountCubit>().updateAccount(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            profileImageUrl: profileImageUrl,
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text('Save Changes'),
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

class _AccountField extends StatelessWidget {
  const _AccountField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
