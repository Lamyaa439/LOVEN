/// ========================================================================
/// Signup Page
///
/// Implements the Figma "Sign Up" screens (2.2, 2.3, 2.4).
///
/// Design system compliance:
/// - All typography via `Theme.of(context).textTheme.*`.
/// - All colors via `Theme.of(context).colorScheme.*` or [AppColors].
/// - Input styling inherited from `inputDecorationTheme` in [AppTheme].
/// - Button styling inherited from `elevatedButtonTheme`; only the shape
///   is overridden to match the Figma pill radius.
///
/// UX features:
/// - Real-time debounced email validation against the backend.
/// - Live password strength checklist with per-rule feedback.
/// - Sliver layout for seamless keyboard avoidance.
/// - Programmatic focus advancement between fields.
/// ========================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/res/theme/app_colors.dart';

import '../../controller/cubit/auth_cubit.dart';
import '../../controller/cubit/auth_state.dart';

class SignupPage extends StatefulWidget {
  final bool fromGuest;

  const SignupPage({
    super.key,
    this.fromGuest = false,
  });

  @override
  State<SignupPage> createState() =>
      _SignupPageState();
}

class _SignupPageState
    extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  Timer? _debounceTimer;

  String? _emailAsyncError;

  bool _isEmailChecking = false;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;

  bool _obscurePassword = true;

  String _selectedRole = 'customer';

  @override
  void initState() {
    super.initState();

    _emailController.addListener(
      _onEmailChanged,
    );

    _passwordController.addListener(
      _onPasswordChanged,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    _debounceTimer?.cancel();

    super.dispose();
  }

  // =========================================================
  // Validation
  // =========================================================

  void _onEmailChanged() {
    final email =
        _emailController.text.trim();

    if (_debounceTimer?.isActive ??
        false) {
      _debounceTimer!.cancel();
    }

    if (email.isEmpty) {
      setState(() {
        _emailAsyncError = null;
      });

      return;
    }

    final emailRegex = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    );

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailAsyncError =
            'Enter a valid email address';
      });

      return;
    }

    setState(() {
      _emailAsyncError = null;
      _isEmailChecking = true;
    });

    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        final isTaken = await context
            .read<AuthCubit>()
            .checkEmailExists(email);

        if (!mounted) return;

        setState(() {
          _isEmailChecking = false;

          _emailAsyncError = isTaken
              ? 'This email is already registered'
              : null;
        });
      },
    );
  }

  void _onPasswordChanged() {
    final password =
        _passwordController.text;

    setState(() {
      _hasMinLength =
          password.length >= 8;

      _hasUppercase = password
          .contains(RegExp(r'[A-Za-z]'));

      _hasDigits = password
          .contains(RegExp(r'[0-9]'));
    });
  }

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasDigits;

  bool get _isFormValid =>
      _nameController.text
          .trim()
          .isNotEmpty &&
      _emailController.text
          .trim()
          .isNotEmpty &&
      _emailAsyncError == null &&
      !_isEmailChecking &&
      _isPasswordValid;

  // =========================================================
  // Actions
  // =========================================================

  void _signup() {
    if (!_isFormValid) return;

    context.read<AuthCubit>().signup(
          name:
              _nameController.text.trim(),
          email: _emailController.text
              .trim(),
          password:
              _passwordController.text,
          systemRole: _selectedRole,
        );
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return BlocConsumer<
        AuthCubit,
        AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Account created. Email verification is coming soon.',
              ),
            ),
          );
          context.go(AppRoutes.signupSuccess);
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading;

        return Scaffold(
          backgroundColor:
              theme.scaffoldBackgroundColor,

          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const SizedBox(
                        height: 4),

                    IconButton(
                      onPressed: isLoading
                          ? null
                          : _navigateBack,
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme
                            .onSurface,
                      ),
                    ),

                    const SizedBox(
                        height: 4),

                    Text(
                      'Sign Up',
                      style: theme
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                        fontSize: 34,
                      ),
                    ),

                    const SizedBox(
                        height: 6),

                    Text(
                      'Create your account and start discovering art',
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    _FieldLabel(
                      text: 'Name',
                      theme: theme,
                    ),

                    TextFormField(
                      controller:
                          _nameController,
                      focusNode:
                          _nameFocusNode,
                      textInputAction:
                          TextInputAction
                              .next,
                      enabled: !isLoading,
                      onFieldSubmitted:
                          (_) {
                        FocusScope.of(
                                context)
                            .requestFocus(
                          _emailFocusNode,
                        );
                      },
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Your name',
                        contentPadding:
                            EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 14),

                    _FieldLabel(
                      text: 'Email',
                      theme: theme,
                    ),

                    TextFormField(
                      controller:
                          _emailController,
                      focusNode:
                          _emailFocusNode,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      textInputAction:
                          TextInputAction
                              .next,
                      enabled: !isLoading,
                      onFieldSubmitted:
                          (_) {
                        FocusScope.of(
                                context)
                            .requestFocus(
                          _passwordFocusNode,
                        );
                      },
                      decoration:
                          InputDecoration(
                        hintText:
                            'Your email',
                        errorText:
                            _emailAsyncError,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        suffixIcon:
                            _isEmailChecking
                                ? const Padding(
                                    padding:
                                        EdgeInsets
                                            .all(
                                      12,
                                    ),
                                    child:
                                        SizedBox(
                                      width:
                                          16,
                                      height:
                                          16,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    ),
                                  )
                                : null,
                      ),
                    ),

                    const SizedBox(
                        height: 14),

                    Row(
                      children: [
                        _FieldLabel(
                          text:
                              'Password',
                          theme: theme,
                        ),
                        const SizedBox(
                            width: 8),
                        _PasswordStrengthDot(
                          isValid:
                              _isPasswordValid,
                          hasInput:
                              _passwordController
                                  .text
                                  .isNotEmpty,
                          colorScheme:
                              colorScheme,
                        ),
                      ],
                    ),

                    TextFormField(
                      controller:
                          _passwordController,
                      focusNode:
                          _passwordFocusNode,
                      obscureText:
                          _obscurePassword,
                      enabled: !isLoading,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Your password',
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                            color:
                                colorScheme
                                    .onSurfaceVariant,
                          ),
                          onPressed:
                              isLoading
                                  ? null
                                  : () {
                                      setState(
                                          () {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                        ),
                      ),
                    ),

                    if (_passwordController
                        .text.isNotEmpty) ...[
                      const SizedBox(
                          height: 8),

                      _PasswordRule(
                        text:
                            'Minimum 8 characters',
                        isMet:
                            _hasMinLength,
                        theme: theme,
                      ),

                      const SizedBox(
                          height: 2),

                      _PasswordRule(
                        text:
                            'At least 1 number',
                        isMet:
                            _hasDigits,
                        theme: theme,
                      ),

                      const SizedBox(
                          height: 2),

                      _PasswordRule(
                        text:
                            'Contains letters',
                        isMet:
                            _hasUppercase,
                        theme: theme,
                      ),
                    ],

                    const SizedBox(
                        height: 16),

                    _FieldLabel(
                      text:
                          'Account Type',
                      theme: theme,
                    ),

                    const SizedBox(
                        height: 8),

                    RoleSelector(
                      selectedRole:
                          _selectedRole,
                      isDisabled:
                          isLoading,
                      onChanged:
                          (role) {
                        setState(() {
                          _selectedRole =
                              role;
                        });
                      },
                    ),

                    const SizedBox(
                        height: 20),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 50,
                      child:
                          ElevatedButton(
                        onPressed:
                            (_isFormValid &&
                                    !isLoading)
                                ? _signup
                                : null,
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
                                BorderRadius.circular(
                              26,
                            ),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width:
                                    20,
                                height:
                                    20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color: Colors
                                      .white,
                                ),
                              )
                            : const Text(
                                'Register',
                              ),
                      ),
                    ),

                    const SizedBox(
                        height: 14),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          'Have an account? ',
                          style: theme
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            fontSize: 13,
                            color:
                                colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  context.go(
                                    AppRoutes.login,
                                  );
                                },
                          child: Text(
                            'Sign In',
                            style: theme
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontSize: 13,
                              color: AppColors
                                  .primaryBlue,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 18),

                    Center(
                      child: Text(
                        'By registering, you agree to our terms and policies.',
                        textAlign:
                            TextAlign.center,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          fontSize: 11,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 18),
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

// =========================================================
// Widgets
// =========================================================

class _FieldLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _FieldLabel({
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium
            ?.copyWith(
          fontWeight:
              FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _PasswordStrengthDot
    extends StatelessWidget {
  final bool isValid;
  final bool hasInput;
  final ColorScheme colorScheme;

  const _PasswordStrengthDot({
    required this.isValid,
    required this.hasInput,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final bool isFilled;

    if (!hasInput) {
      dotColor = Colors.grey.shade400;
      isFilled = false;
    } else if (isValid) {
      dotColor = Colors.green;
      isFilled = true;
    } else {
      dotColor = AppColors.deepPurple;
      isFilled = false;
    }

    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isFilled ? dotColor : null,
        border: isFilled
            ? null
            : Border.all(
                color: dotColor,
                width: 1.3,
              ),
      ),
    );
  }
}

class _PasswordRule
    extends StatelessWidget {
  final String text;
  final bool isMet;
  final ThemeData theme;

  const _PasswordRule({
    required this.text,
    required this.isMet,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check
              : Icons.close,
          size: 14,
          color: isMet
              ? Colors.green
              : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall
              ?.copyWith(
            fontSize: 11,
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final bool isDisabled;
  final ValueChanged<String>
      onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.isDisabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleOption(
            title: 'Customer',
            icon: Icons
                .shopping_bag_outlined,
            value: 'customer',
            selectedRole:
                selectedRole,
            isDisabled: isDisabled,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RoleOption(
            title: 'Artist',
            icon:
                Icons.brush_outlined,
            value: 'artist',
            selectedRole:
                selectedRole,
            isDisabled: isDisabled,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _RoleOption
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String selectedRole;
  final bool isDisabled;

  final ValueChanged<String>
      onChanged;

  const _RoleOption({
    required this.title,
    required this.icon,
    required this.value,
    required this.selectedRole,
    required this.isDisabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSelected =
        selectedRole == value;

    return InkWell(
      onTap: isDisabled
          ? null
          : () => onChanged(value),
      borderRadius:
          BorderRadius.circular(14),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
                  .withValues(alpha: 0.18)
              : theme.colorScheme.surface,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors.grey.shade300,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.primaryPurple
                      .withValues(alpha: 0.2),
              child: Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : AppColors.primaryBlue,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                title,
                overflow:
                    TextOverflow.ellipsis,
                style: theme
                    .textTheme.bodyMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}