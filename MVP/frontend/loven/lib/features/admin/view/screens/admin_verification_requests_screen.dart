import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:loven/features/admin/view/widgets/admin_verification_request_card.dart';
import 'package:loven/features/admin/view/widgets/empty_requests_widget.dart';

import 'package:loven/features/verification_request/controller/cubit/verification_request_cubit.dart';
import 'package:loven/features/verification_request/controller/cubit/verification_request_state.dart';

class AdminVerificationRequestsScreen extends StatelessWidget {
  const AdminVerificationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verification Requests',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<
            VerificationRequestCubit,
            VerificationRequestState>(
          builder: (context, state) {
            if (state is VerificationRequestLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is VerificationRequestError) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is VerificationRequestsLoaded) {
              if (state.requests.isEmpty) {
                return const EmptyRequestsWidget();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide =
                      constraints.maxWidth > 900;

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<
                              VerificationRequestCubit>()
                          .fetchAllRequests();
                    },
                    child: ListView(
                      padding:
                          const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 24),

                        if (isWide)
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: state.requests
                                .map((request) {
                              return SizedBox(
                                width:
                                    (constraints
                                                .maxWidth -
                                            68) /
                                        2,
                                child:
                                    _buildRequestCard(
                                  context,
                                  request,
                                ),
                              );
                            }).toList(),
                          )
                        else
                          ...state.requests.map(
                            (request) => Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 16,
                              ),
                              child:
                                  _buildRequestCard(
                                context,
                                request,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    final requestId =
        request['id'].toString();

    final status =
        request['status']?.toString() ??
            'unknown';

    final artistName =
        request['artist_display_name']
                    ?.toString() ??
                request['artist_email']
                    ?.toString() ??
                request['artist_profile_id']
                    ?.toString() ??
                'Unknown Artist';

    final artistEmail =
        request['artist_email']
                ?.toString() ??
            '';

    final documentType =
        request['document_type']
                ?.toString() ??
            'Unknown document';

    final institutionName =
        request['institution_name']
                ?.toString() ??
            '';

    final documentNumber =
        request['document_number']
                ?.toString() ??
            '';

    return AdminVerificationRequestCard(
      artistName: artistName,
      artistEmail: artistEmail,
      status: status,
      documentType: documentType,
      institutionName: institutionName,
      documentNumber: documentNumber,
      onApprove: status == 'approved'
          ? null
          : () {
              context
                  .read<
                      VerificationRequestCubit>()
                  .approveRequest(
                    requestId,
                  );
            },
      onReject: status == 'rejected'
          ? null
          : () {
              context
                  .read<
                      VerificationRequestCubit>()
                  .rejectRequest(
                    requestId,
                  );
            },
    );
  }
}