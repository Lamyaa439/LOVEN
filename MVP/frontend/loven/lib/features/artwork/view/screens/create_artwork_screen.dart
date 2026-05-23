import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubit/artwork_cubit.dart';
import '../../controller/cubit/artwork_state.dart';
import 'package:go_router/go_router.dart';

class CreateArtworkScreen extends StatefulWidget {
  const CreateArtworkScreen({super.key});

  @override
  State<CreateArtworkScreen> createState() =>
      _CreateArtworkScreenState();
}

class _CreateArtworkScreenState
    extends State<CreateArtworkScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final shippingFeeController = TextEditingController();
  final imageUrlController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    shippingFeeController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ArtworkCubit>().createArtwork(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          price: double.parse(priceController.text.trim()),
          quantityAvailable:
              int.parse(quantityController.text.trim()),
          shippingFee:
              double.parse(shippingFeeController.text.trim()),
          artworkImageUrl:
              imageUrlController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ArtworkCubit, ArtworkState>(
      listener: (context, state) {
        if (state is ArtworkLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Artwork uploaded successfully'),
            ),
          );

          context.go('/');
        }

        if (state is ArtworkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ArtworkLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Upload Artwork'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _InputField(
                    controller: titleController,
                    label: 'Title',
                    validatorMessage: 'Title is required',
                  ),

                  const SizedBox(height: 16),

                  _InputField(
                    controller: descriptionController,
                    label: 'Description',
                    validatorMessage:
                        'Description is required',
                    maxLines: 4,
                  ),

                  const SizedBox(height: 16),

                  _InputField(
                    controller: priceController,
                    label: 'Price',
                    validatorMessage: 'Price is required',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  _InputField(
                    controller: quantityController,
                    label: 'Quantity Available',
                    validatorMessage:
                        'Quantity is required',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  _InputField(
                    controller: shippingFeeController,
                    label: 'Shipping Fee',
                    validatorMessage:
                        'Shipping fee is required',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  _InputField(
                    controller: imageUrlController,
                    label: 'Artwork Image URL',
                    validatorMessage:
                        'Artwork image URL is required',
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : _submit,
                      child: isLoading
                          ? CircularProgressIndicator(
                              color: theme
                                  .colorScheme.onPrimary,
                            )
                          : const Text(
                              'Upload Artwork',
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String validatorMessage;
  final TextInputType keyboardType;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.validatorMessage,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return validatorMessage;
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}