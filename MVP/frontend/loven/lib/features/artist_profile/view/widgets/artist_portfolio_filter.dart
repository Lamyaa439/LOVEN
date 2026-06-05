import 'package:flutter/material.dart';

import '../../../../core/res/theme/app_colors.dart';

class ArtistPortfolioFilter extends StatelessWidget {
  const ArtistPortfolioFilter({
    super.key,
  });

  static const filters = ['All', 'Available', 'Sold'];

  @override
  Widget build(BuildContext context) {
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
              selectedColor: Colors.white,
              backgroundColor: AppColors.backgroundGrey,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryBlue
                    : Colors.black.withValues(alpha: 0.06),
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryBlue : Colors.black45,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}