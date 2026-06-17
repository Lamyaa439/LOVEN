import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/router/router_helpers.dart';
import 'package:loven/core/widgets/loven_widgets.dart';
import 'package:loven/features/admin/controller/cubit/admin_feedback_cubit.dart';
import 'package:loven/features/admin/controller/cubit/admin_feedback_state.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFeedbackCubit>().loadFeedback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: lovenPushedScreenBackLeading(context),
        title: const Text('User Feedback'),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminFeedbackCubit, AdminFeedbackState>(
        builder: (context, state) {
          if (state is AdminFeedbackLoading) {
            return const GalleryLoadingState(
              message: 'Loading feedback...',
            );
          }

          if (state is AdminFeedbackError) {
            return GalleryEmptyState(
              backgroundColor:
                  Theme.of(context).colorScheme.surface,
              icon: Icons.error_outline,
              title: 'Could not load feedback',
              subtitle: state.message,
              actionLabel: 'Retry',
              onAction: () {
                context.read<AdminFeedbackCubit>().loadFeedback();
              },
            );
          }

          if (state is AdminFeedbackLoaded) {
            if (state.feedback.isEmpty) {
              return GalleryEmptyState(
                backgroundColor:
                    Theme.of(context).colorScheme.surface,
                icon: Icons.feedback_outlined,
                title: 'No feedback yet',
                subtitle:
                    'User feedback will appear here when submitted.',
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<AdminFeedbackCubit>().loadFeedback(),
              child: ListView.separated(
                padding: const EdgeInsets.all(
                  AppSpacing.screenPadding,
                ),
                itemCount: state.feedback.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final feedback = state.feedback[index];

                  return LovenSurfaceCard(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback['subject']?.toString() ??
                              'No subject',
                          style:
                              Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        Text(
                          feedback['message']?.toString() ?? '',
                        ),
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        Text(
                          feedback['created_at']
                                  ?.toString() ??
                              '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}