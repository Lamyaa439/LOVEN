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

import '../../controller/cubit/auth_cubit.dart';
import '../../controller/cubit/auth_state.dart';

class SignupPage extends StatefulWidget {
  final bool fromGuest;

  const SignupPage({
    super.key,
    this.fromGuest = false,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
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

  // =====================================================================
  // Validation
  // =====================================================================

  /// Local regex check followed by a debounced server-side availability check.
  void _onEmailChanged() {
    final email = _emailController.text.trim();
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (email.isEmpty) {
      setState(() => _emailAsyncError = null);
      return;
    }

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailAsyncError = 'Enter a valid email address');
      return;
    }

    setState(() {
      _emailAsyncError = null;
      _isEmailChecking = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final isTaken = await context.read<AuthCubit>().checkEmailExists(email);
      if (mounted) {
        setState(() {
          _isEmailChecking = false;
          _emailAsyncError =
              isTaken ? 'This email is already registered' : null;
        });
      }
    });
  }

  /// Updates the password strength indicators as the user types.
  void _onPasswordChanged() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Za-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasDigits;

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _emailAsyncError == null &&
      !_isEmailChecking &&
      _isPasswordValid;

  // =====================================================================
  // Actions
  // =====================================================================

  void _signup() {
    if (!_isFormValid) return;

    context.read<AuthCubit>().signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          systemRole: 'customer',
        );
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _safeNavigateTo(String route) {
    try {
      context.push(route);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This page will be available soon.')),
      );
    }
  }

  // =====================================================================
  // Build
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully')),
          );
          if (mounted) context.go('/');
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Back button
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: isLoading ? null : _navigateBack,
                        icon: Icon(
                          Icons.arrow_back,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Scrollable form body
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Title
                            Text(
                              'Sign Up',
                              style: theme.textTheme.displayLarge,
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              'Create account and choose favorite menu',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Name
                            _FieldLabel(text: 'Name', theme: theme),
                            TextFormField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              textInputAction: TextInputAction.next,
                              enabled: !isLoading,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_emailFocusNode),
                              decoration: const InputDecoration(
                                hintText: 'Your name',
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email
                            _FieldLabel(text: 'Email', theme: theme),
                            TextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !isLoading,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode),
                              decoration: InputDecoration(
                                hintText: 'Your email',
                                errorText: _emailAsyncError,
                                suffixIcon: _isEmailChecking
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password label with strength indicator
                            Row(
                              children: [
                                _FieldLabel(text: 'Password', theme: theme),
                                const SizedBox(width: 8),
                                _PasswordStrengthDot(
                                  isValid: _isPasswordValid,
                                  hasInput:
                                      _passwordController.text.isNotEmpty,
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.done,
                              obscureText: _obscurePassword,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                hintText: 'Your password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                ),
                              ),
                            ),

                            // Password strength checklist (visible once user starts typing)
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _PasswordRule(
                                text: 'Minimum 8 characters',
                                isMet: _hasMinLength,
                                theme: theme,
                              ),
                              const SizedBox(height: 4),
                              _PasswordRule(
                                text: 'Atleast 1 number (1-9)',
                                isMet: _hasDigits,
                                theme: theme,
                              ),
                              const SizedBox(height: 4),
                              _PasswordRule(
                                text: 'Atleast lowercase or uppercase letters',
                                isMet: _hasUppercase,
                                theme: theme,
                              ),
                            ],

                            const Spacer(),
                            const SizedBox(height: 24),

                            // Register button (pill shape per Figma)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    (_isFormValid && !isLoading)
                                        ? _signup
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onPrimary,
                                        ),
                                      )
                                    : const Text('Register'),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Have an account? ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () => context.go('/login'),
                                  child: Text(
                                    'Sign In',
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Passive terms consent (Figma footer)
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'By clicking Register, you agree to our\n',
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () =>
                                            _safeNavigateTo('/terms'),
                                        child: Text(
                                          'Terms',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => _safeNavigateTo(
                                            '/privacy-policy'),
                                        child: Text(
                                          'Data Policy.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
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

// =========================================================================
// Extracted Widgets (private, co-located for tight coupling with this page)
// =========================================================================

/// Consistent field label matching the Figma spec.
class _FieldLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _FieldLabel({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Small circle beside the Password label indicating overall strength.
///
/// Matches the Figma pink/purple unfilled-to-filled circle behavior:
/// - Grey outline when no input yet.
/// - [AppColors.deepPurple] outline when typing but invalid.
/// - Filled green when all rules pass.
class _PasswordStrengthDot extends StatelessWidget {
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
      dotColor = colorScheme.secondary;
      isFilled = false;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? dotColor : null,
        border: isFilled ? null : Border.all(color: dotColor, width: 1.5),
      ),
    );
  }
}

/// A single password rule row with a check/cross icon and descriptive text.
class _PasswordRule extends StatelessWidget {
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
          isMet ? Icons.check : Icons.close,
          size: 16,
          color: isMet ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
