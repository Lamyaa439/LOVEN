import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/cart/view/widgets/checkout_shared.dart';

import '../../controller/cubit/verification_request_cubit.dart';
import '../../controller/cubit/verification_request_state.dart';

class VerificationRequestScreen extends StatefulWidget {
  const VerificationRequestScreen({super.key});

  @override
  State<VerificationRequestScreen> createState() =>
      _VerificationRequestScreenState();
}

class _VerificationRequestScreenState extends State<VerificationRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedDocumentType = 'National ID';

  final _institutionNameController = TextEditingController();
  final _documentNumberController = TextEditingController();

  final List<String> _documentTypes = const [
    'National ID',
    'Art Certificate',
    'University ID',
    'Professional License',
    'Portfolio Proof',
    'Other',
  ];

  @override
  void dispose() {
    _institutionNameController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<VerificationRequestCubit>().submitRequest(
          documentType: _selectedDocumentType,
          institutionName: _institutionNameController.text.trim(),
          documentNumber: _documentNumberController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<VerificationRequestCubit, VerificationRequestState>(
      listener: (context, state) {
        if (state is VerificationRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.pop(true);
        }

        if (state is VerificationRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: lovenPushedScreenBackLeading(context),
          title: const Text('Request Verification'),
          centerTitle: true,
        ),
        body: BlocBuilder<VerificationRequestCubit, VerificationRequestState>(
          builder: (context, state) {
            final isLoading = state is VerificationRequestLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSizes.shellFloatingNavClearance + AppSpacing.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: AppSizes.avatarXl + AppSpacing.md,
                        height: AppSizes.avatarXl + AppSpacing.md,
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          size: AppSizes.iconLg + AppSpacing.sm,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Verify your artist profile',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Submit proof that confirms your artist identity. Admins will review your request before adding the verified badge.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    CheckoutFieldSection(
                      label: 'Document type',
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedDocumentType,
                        decoration: checkoutInputDecoration(
                          hint: 'Select document type',
                          icon: Icons.badge_outlined,
                        ),
                        items: _documentTypes
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: isLoading
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() => _selectedDocumentType = value);
                              },
                      ),
                    ),
                    CheckoutFieldSection(
                      label: 'Institution / issuing authority',
                      child: LovenTextField(
                        controller: _institutionNameController,
                        hintText: 'Example: Saudi Art Association',
                        readOnly: isLoading,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Institution name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    CheckoutFieldSection(
                      label: 'Document / reference number',
                      child: LovenTextField(
                        controller: _documentNumberController,
                        hintText: 'Enter ID, certificate, or reference number',
                        readOnly: isLoading,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Document number is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Document number is too short';
                          }
                          return null;
                        },
                      ),
                    ),
                    LovenSurfaceCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.brandPrimary,
                            size: AppSizes.iconSm,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Make sure the information matches your artist profile. Submitting false information may result in rejection.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    LovenPrimaryButton(
                      label: isLoading ? 'Submitting…' : 'Submit request',
                      icon: Icons.send_outlined,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
