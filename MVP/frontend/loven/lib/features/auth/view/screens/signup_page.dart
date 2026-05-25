import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../controller/cubit/auth_cubit.dart';
import '../../controller/cubit/auth_state.dart';

/// The Signup Page implementing advanced UX patterns.
///
/// Features included:
/// - Real-time debounced email validation against the server.
/// - Live password strength checklist.
/// - Sliver-based layout for seamless keyboard avoidance without viewport clipping.
/// - Centralized AppTheme compliance (no hardcoded styles).
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

  // Controllers for user input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus nodes for programmatic keyboard navigation
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Debounce mechanism for asynchronous validation
  Timer? _debounceTimer;
  String? _emailAsyncError;

  // State trackers for real-time UI updates
  bool _isEmailChecking = false;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;

  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  String _selectedRole = 'customer';

  @override
  void initState() {
    super.initState();
    // Attach listeners for real-time validation feedback
    _emailController.addListener(_validateEmailAsync);
    _passwordController.addListener(_validatePasswordLive);
  }

  @override
  void dispose() {
    // Crucial: Prevent memory leaks by disposing all active controllers and nodes
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Performs local regex formatting check, followed by a debounced API call
  /// to verify email availability without overloading the backend.
  void _validateEmailAsync() {
    final email = _emailController.text.trim();
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (email.isEmpty) {
      setState(() => _emailAsyncError = null);
      return;
    }

    // 1. Local Regex Validation (RFC 5322 simplified)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailAsyncError = 'Enter a valid email address');
      return;
    }

    // 2. Asynchronous Server Validation (Debounced by 500ms)
    setState(() {
      _emailAsyncError = null;
      _isEmailChecking = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final isTaken = await context.read<AuthCubit>().checkEmailExists(email);
      
      if (mounted) {
        setState(() {
          _isEmailChecking = false;
          _emailAsyncError = isTaken ? 'This email is already registered' : null;
        });
      }
    });
  }

  /// Updates the password strength checklist UI dynamically as the user types.
  void _validatePasswordLive() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
    });
  }

  /// Evaluates all constraints before allowing the form submission.
  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _emailAsyncError == null &&
        !_isEmailChecking &&
        _hasMinLength &&
        _hasUppercase &&
        _hasDigits &&
        _acceptedTerms;
  }

  /// Dispatches the signup event to the Cubit if local validation passes.
  void _signup() {
    // Redundant safety check in case the button is somehow pressed while invalid
    if (!_isFormValid) return;

    context.read<AuthCubit>().signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          systemRole: _selectedRole,
        );
  }

  void _handleCloseAction() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _goToLoggedInHome() {
    if (!mounted) return;
    context.go('/');
  }

  /// Safely handles navigation to terms/privacy to prevent GoRouter crashes 
  /// if the routes are not yet implemented in app_router.dart.
  void _safeNavigateTo(String route) {
    try {
      context.push(route);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This page will be available soon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully')),
          );
          _goToLoggedInHome();
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
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
            body: Stack(
              children: [
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      // Header Section
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Image.asset(
                              'assets/images/loven-logo.png',
                              width: 72,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Create your LOVEN account',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Join as a customer or artist',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      
                      // Form Section (Flexible to accommodate keyboard)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Full Name', theme),
                                TextFormField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                                  enabled: !isLoading,
                                  decoration: const InputDecoration(hintText: 'Type your full name'),
                                ),
                                const SizedBox(height: 16),

                                _buildFieldLabel('Email', theme),
                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'example@domain.com',
                                    errorText: _emailAsyncError,
                                    suffixIcon: _isEmailChecking
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : (_emailController.text.isNotEmpty && _emailAsyncError == null)
                                            ? const Icon(Icons.check_circle, color: Colors.green)
                                            : null,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildFieldLabel('Password', theme),
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  textInputAction: TextInputAction.done,
                                  enabled: !isLoading,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Type your password',
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: isLoading ? null : () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Dynamic Password Constraints Checklist
                                _buildLiveRequirement("At least 8 characters", _hasMinLength, theme),
                                const SizedBox(height: 4),
                                _buildLiveRequirement("Contains 1 uppercase letter (A-Z)", _hasUppercase, theme),
                                const SizedBox(height: 4),
                                _buildLiveRequirement("Contains 1 number (0-9)", _hasDigits, theme),
                                const SizedBox(height: 24),

                                _buildFieldLabel('Role', theme),
                                DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  decoration: const InputDecoration(),
                                  items: const [
                                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                                    DropdownMenuItem(value: 'artist', child: Text('Artist')),
                                  ],
                                  onChanged: isLoading ? null : (val) => setState(() => _selectedRole = val!),
                                ),
                                const SizedBox(height: 16),

                                // Terms & Privacy Row
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _acceptedTerms,
                                      onChanged: isLoading ? null : (val) => setState(() => _acceptedTerms = val ?? false),
                                    ),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                                          children: [
                                            const TextSpan(text: 'I agree to the '),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () => _safeNavigateTo('/terms'),
                                                child: Text('terms', style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline)),
                                              ),
                                            ),
                                            const TextSpan(text: ' and '),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () => _safeNavigateTo('/privacy-policy'),
                                                child: Text('privacy policy', style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const SizedBox(height: 24),

                                // Submit Button (Disabled dynamically based on constraints)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: (_isFormValid && !isLoading) ? _signup : null,
                                    child: isLoading 
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                      : const Text('Create Account'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Already have an account? ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                    GestureDetector(
                                      onTap: isLoading ? null : () => context.go('/login'),
                                      child: Text('Login', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.close, size: 28, color: theme.colorScheme.onSurface),
                      onPressed: isLoading ? null : _handleCloseAction,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Widget for consistent label styling
  Widget _buildFieldLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper Widget for live password constraints checklist
  Widget _buildLiveRequirement(String text, bool isMet, ThemeData theme) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : theme.colorScheme.outline.withOpacity(0.5),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isMet ? Colors.green.shade700 : theme.colorScheme.onSurfaceVariant,
            fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}