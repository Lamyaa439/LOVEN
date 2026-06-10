import 'package:flutter/material.dart';

class ArtistPortfolioFilter extends StatelessWidget {
  const ArtistPortfolioFilter({
    super.key,
  });

  static const filters = ['All', 'Available', 'Sold'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == 'All';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {},
              selectedColor: colorScheme.surface,
              backgroundColor: colorScheme.surfaceContainerHighest,
              side: BorderSide(
  color: isSelected
      ? colorScheme.primary
      : colorScheme.outlineVariant,
),
              labelStyle: TextStyle(
                color: isSelected
    ? colorScheme.primary
    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}