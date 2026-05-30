import 'package:flutter/material.dart';

class VerificationStatusChip extends StatelessWidget {
  const VerificationStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized =
        status.toLowerCase();

    late Color bgColor;
    late Color textColor;
    late IconData icon;

    switch (normalized) {
      case 'approved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        break;

      case 'rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        break;

      default:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),

          const SizedBox(width: 6),

          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}