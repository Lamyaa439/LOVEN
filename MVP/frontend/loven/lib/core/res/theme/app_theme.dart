import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // LIGHT THEME GOES HERE
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Almarai',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.deepPurple,
        surface: AppColors.backgroundGrey,
        brightness: Brightness.light,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primaryBlue,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.black38,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
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
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'PT Serif',
          fontFamilyFallback: ['Almarai'],
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: Colors.black,
        ),
        titleLarge: TextStyle(
          fontFamily: 'PT Serif',
          fontFamilyFallback: ['Almarai'],
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Almarai',
          fontFamilyFallback: ['PT Serif'],
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Almarai',
          fontFamilyFallback: ['PT Serif'],
          fontSize: 14,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Almarai',
          fontFamilyFallback: ['PT Serif'],
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.backgroundGrey,
          disabledForegroundColor: Colors.black38,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepPurple,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
        selectedColor: AppColors.primaryBlue,
        labelStyle: const TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
      ),
    );
  }

  // DARK THEME GOES HERE

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Almarai',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF18181B),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryPurple,
        secondary: AppColors.deepPurple,
        surface: const Color(0xFF18181B),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primaryPurple,
        size: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF18181B),
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: Colors.white38,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
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
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'PT Serif',
          fontFamilyFallback: ['Almarai'],
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'PT Serif',
          fontFamilyFallback: ['Almarai'],
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Almarai',
          fontFamilyFallback: ['PT Serif'],
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Almarai',
          fontFamilyFallback: ['PT Serif'],
          fontSize: 14,
          color: Colors.white70,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Almarai',
          fontFamilyFallback: ['PT Serif'],
          fontSize: 12,
          color: Colors.white60,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: const Color(0xFF18181B),
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side: const BorderSide(
            color: AppColors.primaryPurple,
            width: 1.5,
          ),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryPurple,
            width: 1.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
        selectedColor: AppColors.primaryPurple,
        labelStyle: const TextStyle(
          fontFamily: 'Almarai',
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
      ),
    );
  }
}
