import 'package:flutter/material.dart';
import 'app_colors.dart'; // Ensure you created this file with the hex codes

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Almarai', // Default for Arabic support
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.deepPurple,
        surface: AppColors.backgroundGrey,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,

      // light global icon theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryBlue,
        size: 24,
      ),

      // light bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.black38,
        elevation: 0,
        type: BottomNavigationBarType.fixed,

        // Clean icon sizing using correct parameter targets
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),

        selectedLabelStyle: TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.normal,
          fontSize: 11,
        ),
      ),

      // Bilingual Configuration
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'PT Serif',
            fontFamilyFallback: ['Almarai'],
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Colors.black),
        titleLarge: TextStyle(
          fontFamily: 'PT Serif',
          fontFamilyFallback: ['Almarai'],
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
            fontFamily: 'Almarai',
            fontFamilyFallback: ['PT Serif'],
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black),
        bodyMedium: TextStyle(
          fontFamily: 'Almarai',
          fontFamilyFallback: ['PT Serif'],
          fontSize: 16,
          color: Colors.black87,
        ),
      ),

      // elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.backgroundGrey,
          disabledForegroundColor: Colors.black38,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text button style
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepPurple,
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
        selectedColor: AppColors.primaryBlue,
        labelStyle: const TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Pill shape
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

// THE DARK THEME SECTION
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Almarai',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryPurple,
        surface: const Color(0xFF18181B),
      ),
      scaffoldBackgroundColor: const Color(0xFF18181B),

      // Dark theme icon
      iconTheme: const IconThemeData(
        color: AppColors.primaryPurple,
        size: 24,
      ),

      // Dark bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF18181B),
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: Colors.white38,
        elevation: 0,
        type: BottomNavigationBarType.fixed,

        // Clean icon sizing using correct parameter targets
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),

        selectedLabelStyle: TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.normal,
          fontSize: 11,
        ),
      ),

      // Mirroring button implementations for Dark Mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: const Color(0xFF18181B),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
        selectedColor: AppColors.primaryPurple,
        labelStyle: const TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Pill shape
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
