import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color primaryColor = Color(0xFF5E35B1); // Deep Purple
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color accentColor = Color(0xFFFFC107); // Amber

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Text Styles
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static var bodyMedium;

  // Public Getters (used dynamically)
  static Color get textPrimary => lightTextPrimary;
  static Color get errorColor => error;

  static Color get cardColor => lightSurface;

  static TextStyle get bodyMediumLight =>
      const TextStyle(fontSize: 14, color: lightTextPrimary);
  static TextStyle get bodyLargeLight => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: lightTextPrimary);

  // Helper Methods for Theme Customization

  static AppBarTheme _appBarTheme(Color primaryColor) {
    return AppBarTheme(
      color: primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  static CardTheme _cardTheme(Color surfaceColor) {
    return CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        error: error,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: _appBarTheme(primaryColor),
      cardTheme: _cardTheme(lightSurface),
      textTheme: TextTheme(
        bodyLarge: bodyLargeLight,
        bodyMedium: bodyMediumLight,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(),
      useMaterial3: true,
    );
  }
}
