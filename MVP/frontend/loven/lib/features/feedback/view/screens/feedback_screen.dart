import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/feedback/controller/cubit/feedback_cubit.dart';
import 'package:loven/features/feedback/controller/cubit/feedback_state.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
            title: Text(l10n.feedback),
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
                    l10n.helpUsImprove,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.shareThoughts,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.subject,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LovenTextField(
                    controller: subjectController,
                    hintText: l10n.optionalSubject,
                    readOnly: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.message,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LovenTextField(
                    controller: messageController,
                    hintText: l10n.writeFeedback,
                    maxLines: 6,
                    readOnly: isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.feedbackRequired;
                      }
                      if (value.trim().length < 5) {
                        return l10n.feedbackTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  LovenPrimaryButton(
                    label: l10n.submitFeedback,
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
