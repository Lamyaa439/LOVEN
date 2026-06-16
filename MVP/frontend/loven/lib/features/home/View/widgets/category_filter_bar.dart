import 'package:flutter/material.dart';
import 'package:loven/core/res/design_system.dart';
import 'package:loven/core/widgets/loven_widgets.dart';

/// Horizontal category chips for artwork browse / style filtering.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const double _barHeight = 36;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.chipGap),
        itemBuilder: (context, index) {
          final category = categories[index];

          return Center(
            child: GalleryChip(
              label: category,
              selected: category == selectedCategory,
              compact: true,
              onTap: () => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}
