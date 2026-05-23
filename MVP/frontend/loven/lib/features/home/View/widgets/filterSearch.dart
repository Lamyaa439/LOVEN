import 'package:flutter/material.dart';
import 'package:loven/core/res/theme/app_colors.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  // Local state for the filters
  RangeValues _currentRangeValues = const RangeValues(0, 5000);
  String _selectedCategory = 'All';
  bool _showWorkshopsOnly = false;

  final List<String> _categories = [
    'All',
    'Calligraphy',
    'Oil Painting',
    'Digital Art',
    'Photography',
    'Sculpture'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(25),
      // We use the theme color to match your ArtDetailsScreen
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Filter Artworks",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 25),

          // 1. Categories (Chips)
          Text("Category", style: _sectionTitleStyle(theme)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                // selectedColor: AppColors.primaryPurple,
                // labelStyle: TextStyle(
                //   color:
                //       isSelected ? Colors.white : theme.colorScheme.onSurface,
                // ),
                onSelected: (bool selected) {
                  setState(() => _selectedCategory = category);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          // 2. Price Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Price Range", style: _sectionTitleStyle(theme)),
              Text(
                "${_currentRangeValues.start.round()} - ${_currentRangeValues.end.round()} SAR",
                style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: _currentRangeValues,
            max: 10000,
            divisions: 20,
            activeColor: AppColors.primaryPurple,
            inactiveColor: AppColors.primaryPurple.withOpacity(0.2),
            labels: RangeLabels(
              _currentRangeValues.start.round().toString(),
              _currentRangeValues.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() => _currentRangeValues = values);
            },
          ),

          const SizedBox(height: 20),

          // 3. Workshop Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title:
                Text("Show Workshops Only", style: _sectionTitleStyle(theme)),
            subtitle: Text("Browse upcoming artist interactive sessions",
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
            value: _showWorkshopsOnly,
            activeThumbColor: AppColors.primaryPurple,
            onChanged: (bool value) {
              setState(() => _showWorkshopsOnly = value);
            },
          ),

          const SizedBox(height: 30),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                // Here you would dispatch an event to your HomeBloc
                Navigator.pop(context);
              },
              child: const Text("Apply Filters",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  TextStyle _sectionTitleStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
  }
}
