import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/report/controller/cubit/report_cubit.dart';
import 'package:loven/features/report/controller/cubit/report_state.dart';
/// A screen for the admin reports section.
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() =>
      _AdminReportsScreenState();
}

class _AdminReportsScreenState
    extends State<AdminReportsScreen> {

  @override
  void initState() {
    super.initState();

    context.read<ReportCubit>().loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReportFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return const Center(
                child: Text('No reports found'),
              );
            }

            return ListView.builder(
              itemCount: state.reports.length,
              itemBuilder: (context, index) {
                final report = state.reports[index];

                return Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report['reason'] ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text('Artwork ID: ${report['target_artwork_id'] ?? ''}'),
        if ((report['details'] ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Details: ${report['details']}'),
        ],
        const SizedBox(height: 6),
        Text('Report status: ${report['status'] ?? ''}'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<ReportCubit>().updateArtworkStatus(
                      artworkId: report['target_artwork_id'],
                      status: 'hidden',
                    );
              },
              child: const Text('Hide Artwork'),
            ),
            OutlinedButton(
              onPressed: () {
                context.read<ReportCubit>().updateArtworkStatus(
                      artworkId: report['target_artwork_id'],
                      status: 'available',
                    );
              },
              child: const Text('Unhide'),
            ),
            OutlinedButton(
              onPressed: () {
                context.read<ReportCubit>().updateReportStatus(
                      reportId: report['id'],
                      status: 'resolved',
                    );
              },
              child: const Text('Resolve'),
            ),
            TextButton(
              onPressed: () {
                context.read<ReportCubit>().updateReportStatus(
                      reportId: report['id'],
                      status: 'dismissed',
                    );
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ],
    ),
  ),
);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
