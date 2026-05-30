import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:loven/core/res/theme/app_colors.dart';

import 'package:loven/features/auth/controller/cubit/auth_cubit.dart';
import 'package:loven/features/auth/controller/cubit/auth_state.dart';
import 'package:loven/features/auth/data/services/profile_image_storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  XFile? _selectedImage;

  final _imagePicker = ImagePicker();

  final _storageService =
      ProfileImageStorageService();

  bool initialized = false;

  @override
  void initState() {
    super.initState();

    context
        .read<AuthCubit>()
        .loadCurrentUser();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            theme.scaffoldBackgroundColor,
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: BlocConsumer<
          AuthCubit,
          AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content:
                    Text(state.message),
              ),
            );
          }

          if (state is AuthSuccess &&
              state.user != null &&
              !initialized) {
            initialized = true;

            nameController.text =
                state.user!.name;

            emailController.text =
                state.user!.email;
          }
        },

        builder: (context, state) {
          if (state is AuthLoading &&
              !initialized) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              32,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: FutureBuilder<Uint8List?>(
                    future: _selectedImage?.readAsBytes(),
                    builder: (context, snapshot) {
                      String? currentImageUrl;
                      
                      if (state is AuthSuccess &&
                      state.user != null) {
                        currentImageUrl =
                        state.user!.profileImageUrl;
                      }
                      
                      final hasCurrentImage =
                      currentImageUrl != null &&
                      currentImageUrl.isNotEmpty;
                      
                      ImageProvider<Object>? imageProvider;
                      
                      if (snapshot.hasData) {
                        imageProvider = MemoryImage(snapshot.data!);
                      } else if (hasCurrentImage) {
                        imageProvider = NetworkImage(currentImageUrl!);
                      }
                      
                      return CircleAvatar(
                        radius: 46,
                        backgroundColor:
                        AppColors.primaryPurple.withValues(
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

                _ProfileField(
                  label: 'Name',
                  controller:
                      nameController,
                ),

                const SizedBox(height: 18),

                _ProfileField(
                  label: 'Email',
                  controller:
                      emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      String?
                          profileImageUrl;

                      final authState =
                          context
                              .read<
                                  AuthCubit>()
                              .state;

                      if (_selectedImage !=
                              null &&
                          authState
                              is AuthSuccess &&
                          authState.user !=
                              null) {
                        profileImageUrl =
                            await _storageService
                                .uploadProfileImage(
                          imageFile:
                              _selectedImage!,
                          userId: authState
                              .user!.id,
                        );
                      }

                      if (!context.mounted) {
                        return;
                      }

                      context
                          .read<AuthCubit>()
                          .updateProfile(
                            name:
                                nameController
                                    .text
                                    .trim(),
                            email:
                                emailController
                                    .text
                                    .trim(),
                            profileImageUrl:
                                profileImageUrl,
                          );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          AppColors
                              .primaryBlue,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          28,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
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

class _ProfileField
    extends StatelessWidget {
  final String label;

  final TextEditingController
      controller;

  final TextInputType?
      keyboardType;

  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              theme.textTheme.bodyMedium
                  ?.copyWith(
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType:
              keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                theme.colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              borderSide: BorderSide(
                color:
                    Colors.grey.shade300,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              borderSide: BorderSide(
                color:
                    Colors.grey.shade300,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              borderSide:
                  const BorderSide(
                color:
                    AppColors
                        .primaryBlue,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}