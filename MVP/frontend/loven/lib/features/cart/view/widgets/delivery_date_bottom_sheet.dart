import 'package:flutter/material.dart';

import 'package:loven/core/res/theme/app_colors.dart';

class DeliveryDateBottomSheet extends StatefulWidget {
  const DeliveryDateBottomSheet({super.key});

  @override
  State<DeliveryDateBottomSheet> createState() =>
      _DeliveryDateBottomSheetState();
}

class _DeliveryDateBottomSheetState extends State<DeliveryDateBottomSheet> {
  int selectedDate = 0;
  int selectedTime = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Delivery date',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ChoiceCard(
                title: 'Today',
                subtitle: '12 Jan',
                selected: selectedDate == 0,
                onTap: () => setState(() => selectedDate = 0),
              ),
              const SizedBox(width: 10),
              _ChoiceCard(
                title: 'Tomorrow',
                subtitle: '12 Jan',
                selected: selectedDate == 1,
                onTap: () => setState(() => selectedDate = 1),
              ),
              const SizedBox(width: 10),
              _ChoiceCard(
                title: 'Pick',
                subtitle: 'a date',
                selected: selectedDate == 2,
                onTap: () => setState(() => selectedDate = 2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Delivery time',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ChoiceCard(
                title: 'Between',
                subtitle: '10PM : 11PM',
                selected: selectedTime == 0,
                onTap: () => setState(() => selectedTime = 0),
              ),
              const SizedBox(width: 10),
              _ChoiceCard(
                title: 'Between',
                subtitle: '10PM : 11PM',
                selected: selectedTime == 1,
                onTap: () => setState(() => selectedTime = 1),
              ),
            ],
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: 0.18)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : Colors.grey.shade300,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}