import 'package:flutter/material.dart';

class EmptyRequestsWidget extends StatelessWidget {
  const EmptyRequestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            Text(
              'No Verification Requests',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'New artist submissions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}