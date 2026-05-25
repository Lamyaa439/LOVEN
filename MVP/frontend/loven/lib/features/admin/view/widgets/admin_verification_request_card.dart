import 'package:flutter/material.dart';

import 'package:loven/features/admin/view/widgets/verification_status_chip.dart';

class AdminVerificationRequestCard extends StatelessWidget {
  const AdminVerificationRequestCard({
    super.key,
    required this.artistName,
    required this.artistEmail,
    required this.status,
    required this.documentType,
    required this.institutionName,
    required this.documentNumber,
    required this.onApprove,
    required this.onReject,
  });

  final String artistName;
  final String artistEmail;
  final String status;
  final String documentType;
  final String institutionName;
  final String documentNumber;

  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Colors.deepPurple.shade50,
                  child: Icon(
                    Icons.verified_user_outlined,
                    color:
                        Colors.deepPurple.shade400,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        artistName,
                        style: theme
                            .textTheme.titleMedium
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        artistEmail,
                        style: theme
                            .textTheme.bodySmall
                            ?.copyWith(
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                VerificationStatusChip(
                  status: status,
                ),
              ],
            ),

            const SizedBox(height: 22),

            _InfoTile(
              icon: Icons.description_outlined,
              label: 'Document Type',
              value: documentType,
            ),

            if (institutionName.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(top: 12),
                child: _InfoTile(
                  icon: Icons.business_outlined,
                  label: 'Institution',
                  value: institutionName,
                ),
              ),

            if (documentNumber.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(top: 12),
                child: _InfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Document Number',
                  value: documentNumber,
                ),
              ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                    label: const Text('Reject'),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.red.shade600,
                      side: BorderSide(
                        color:
                            Colors.red.shade200,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(
                      Icons.check_rounded,
                    ),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          Colors.green.shade600,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade700,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}