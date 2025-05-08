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

  // Calendar Colors
  static const Color todayHighlight = primaryColor;
  static const Color shubhColor = success;
  static const Color ashubhColor = error;

  // Text Styles
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static var errorColor;

  static var bodyMedium;

  static var cardColor;

  // Light Theme Text Styles
  static TextStyle get bodyMediumLight =>
      const TextStyle(fontSize: 14, color: lightTextPrimary);
  static TextStyle get bodyLargeLight => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: lightTextPrimary);

  // Dark Theme Text Styles
  static TextStyle get bodyMediumDark =>
      const TextStyle(fontSize: 14, color: darkTextPrimary);
  static TextStyle get bodyLargeDark => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: darkTextPrimary);

  // Common Elevated Button Style
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

  // Common Card Theme Style
  static CardTheme _cardTheme(Color surfaceColor) {
    return CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      // ignore: deprecated_member_use
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  // Common AppBar Theme
  static AppBarTheme _appBarTheme(Color color) {
    return AppBarTheme(
      color: color,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
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

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        error: error,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: _appBarTheme(const Color(0xFF2C2C2C)), // Darker AppBar color
      cardTheme: _cardTheme(darkSurface),
      textTheme: TextTheme(
        bodyLarge: bodyLargeDark,
        bodyMedium: bodyMediumDark,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(),
      useMaterial3: true,
    );
  }
}
