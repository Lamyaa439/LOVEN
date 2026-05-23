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

  final _documentTypeController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _documentNumberController = TextEditingController();

  @override
  void dispose() {
    _documentTypeController.dispose();
    _institutionNameController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<VerificationRequestCubit>().submitRequest(
          documentType: _documentTypeController.text.trim(),
          institutionName: _institutionNameController.text.trim(),
          documentNumber: _documentNumberController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerificationRequestCubit, VerificationRequestState>(
      listener: (context, state) {
        if (state is VerificationRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context, true);
        }

        if (state is VerificationRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Request Verification'),
          centerTitle: true,
        ),
        body: BlocBuilder<VerificationRequestCubit, VerificationRequestState>(
          builder: (context, state) {
            final isLoading = state is VerificationRequestLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Submit your artist verification request.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _documentTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Document type',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Document type is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _institutionNameController,
                      decoration: const InputDecoration(
                        labelText: 'Institution name',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Institution name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _documentNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Document number',
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Document number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submit,
                        icon: const Icon(Icons.send_outlined),
                        label: Text(
                          isLoading ? 'Submitting...' : 'Submit Request',
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