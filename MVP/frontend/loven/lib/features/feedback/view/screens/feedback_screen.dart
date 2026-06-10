import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/feedback/controller/cubit/feedback_cubit.dart';
import 'package:loven/features/feedback/controller/cubit/feedback_state.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<FeedbackCubit>().submitFeedback(
          subject: subjectController.text.trim().isEmpty
              ? null
              : subjectController.text.trim(),
          message: messageController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FeedbackCubit, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.pop();
        }

        if (state is FeedbackError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is FeedbackLoading;

        return Scaffold(
          appBar: AppBar(
            leading: lovenPushedScreenBackLeading(context),
            centerTitle: true,
            title: const Text('Feedback'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.md,
              AppSpacing.screenPadding,
              AppSizes.shellFloatingNavClearance + AppSpacing.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help us improve LOVEN',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Share your thoughts, suggestions, or issues with us.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Subject',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LovenTextField(
                    controller: subjectController,
                    hintText: 'Optional subject',
                    readOnly: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Message',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LovenTextField(
                    controller: messageController,
                    hintText: 'Write your feedback here',
                    maxLines: 6,
                    readOnly: isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Feedback message is required';
                      }
                      if (value.trim().length < 5) {
                        return 'Please write a little more detail';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  LovenPrimaryButton(
                    label: 'Submit feedback',
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
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
