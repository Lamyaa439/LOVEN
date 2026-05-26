import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubit/verification_request_cubit.dart';
import '../../controller/cubit/verification_request_state.dart';

class VerificationRequestScreen extends StatefulWidget {
  const VerificationRequestScreen({super.key});

  @override
  State<VerificationRequestScreen> createState() =>
      _VerificationRequestScreenState();
}

class _VerificationRequestScreenState
    extends State<VerificationRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedDocumentType = 'National ID';

  final _institutionNameController =
      TextEditingController();
  final _documentNumberController =
      TextEditingController();

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

    await context
        .read<VerificationRequestCubit>()
        .submitRequest(
          documentType: _selectedDocumentType,
          institutionName:
              _institutionNameController.text.trim(),
          documentNumber:
              _documentNumberController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<
        VerificationRequestCubit,
        VerificationRequestState>(
      listener: (context, state) {
        if (state is VerificationRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );

          Navigator.pop(context, true);
        }

        if (state is VerificationRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Request Verification'),
          centerTitle: true,
        ),
        body: BlocBuilder<
            VerificationRequestCubit,
            VerificationRequestState>(
          builder: (context, state) {
            final isLoading =
                state is VerificationRequestLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          size: 52,
                          color:
                              theme.colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: Text(
                        'Verify your artist profile',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Submit proof that confirms your artist identity. Admins will review your request before adding the verified badge.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Document type',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: _selectedDocumentType,
                      decoration: const InputDecoration(
                        prefixIcon:
                            Icon(Icons.badge_outlined),
                      ),
                      items: _documentTypes
                          .map(
                            (type) =>
                                DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value == null) return;

                              setState(() {
                                _selectedDocumentType =
                                    value;
                              });
                            },
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Institution / issuing authority',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller:
                          _institutionNameController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText:
                            'Example: Saudi Art Association',
                        prefixIcon:
                            Icon(Icons.school_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Institution name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Document / reference number',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller:
                          _documentNumberController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText:
                            'Enter ID, certificate, or reference number',
                        prefixIcon:
                            Icon(Icons.numbers_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Document number is required';
                        }

                        if (value.trim().length < 3) {
                          return 'Document number is too short';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color:
                                theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Make sure the information matches your artist profile. Submitting false information may result in rejection.',
                              style: theme
                                  .textTheme.bodySmall
                                  ?.copyWith(
                                color: theme
                                    .colorScheme.onSurface
                                    .withValues(alpha: 0.62),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            isLoading ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send_outlined,
                              ),
                        label: Text(
                          isLoading
                              ? 'Submitting...'
                              : 'Submit Request',
                        ),
                      ),
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