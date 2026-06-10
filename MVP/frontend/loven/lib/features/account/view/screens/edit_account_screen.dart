import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/account/controller/cubit/account_cubit.dart';
import 'package:loven/features/account/controller/cubit/account_state.dart';
import 'package:loven/features/account/data/services/profile_image_storage_service.dart';
import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/models/auth_user.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';

/// Edit signed-in account profile (`/profile/edit`).
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final sessionUser = authStateSessionUser(context.read<AuthCubit>().state);
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

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
      );
      return;
    }

    if (!authStateHasSession(context.read<AuthCubit>().state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please sign in again.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? profileImageUrl;
      final sessionUser = authStateSessionUser(context.read<AuthCubit>().state);

      if (_selectedImage != null && sessionUser != null) {
        profileImageUrl = await context
            .read<ProfileImageStorageService>()
            .uploadProfileImage(
              imageFile: _selectedImage!,
              userId: sessionUser.id,
            );
      }

      if (!mounted) return;

      await context.read<AccountCubit>().updateAccount(
            name: name,
            email: email,
            profileImageUrl: profileImageUrl,
          );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $e')),
      );
    }
  }

  void _handleAccountStateChange(AccountState state) {
    if (state is AccountLoaded && !initialized) {
      initialized = true;
      nameController.text = state.user.name;
      emailController.text = state.user.email;
      return;
    }

    if (!_isSaving) return;

    if (state is AccountFailure) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      return;
    }

    if (state is AccountLoaded) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      if (context.canPop()) {
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Account details'),
        leading: lovenPushedScreenBackLeading(context),
      ),
      body: BlocConsumer<AccountCubit, AccountState>(
        listener: (context, state) => _handleAccountStateChange(state),
        builder: (context, accountState) {
          if (_isLoadingInitial && !initialized) {
            return const GalleryLoadingState(message: 'Loading profile…');
          }

          final profile = _profileFromState(accountState);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.md,
              AppSpacing.screenPadding,
              AppSizes.shellFloatingNavClearance + AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update your LOVEN sign-in details.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: FutureBuilder<Uint8List?>(
                      future: _selectedImage?.readAsBytes(),
                      builder: (context, snapshot) {
                        final currentImageUrl = profile?.profileImageUrl;
                        final hasCurrentImage =
                            currentImageUrl != null &&
                                currentImageUrl.isNotEmpty;

                        ImageProvider<Object>? imageProvider;

                        if (snapshot.hasData) {
                          imageProvider = MemoryImage(snapshot.data!);
                        } else if (hasCurrentImage) {
                          imageProvider = NetworkImage(currentImageUrl);
                        }

                        return Stack(
                          children: [
                            CircleAvatar(
                              radius: AppSizes.avatarXl / 2,
                              backgroundColor: AppColors.surfaceSoft,
                              backgroundImage: imageProvider,
                              child: imageProvider == null
                                  ? Icon(
                                      Icons.camera_alt_outlined,
                                      size: AppSizes.iconLg,
                                      color: AppColors.textMuted,
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
                                  Icons.edit_outlined,
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
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                CheckoutFieldSection(
                  label: 'Name',
                  child: LovenTextField(
                    controller: nameController,
                    hintText: 'Your name',
                  ),
                ),
                CheckoutFieldSection(
                  label: 'Email',
                  child: LovenTextField(
                    controller: emailController,
                    hintText: 'Your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                LovenPrimaryButton(
                  label: _isSaving ? 'Saving…' : 'Save changes',
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _saveChanges,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
