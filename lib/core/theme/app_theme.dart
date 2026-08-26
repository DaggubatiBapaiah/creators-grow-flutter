import 'package:flutter/material.dart';

class AppTheme {
  // Premium HSL-based brand colors (represented in hex)
  static const Color primaryColor = Color(0xFF6366F1); // Sleek Indigo
  static const Color secondaryColor = Color(0xFFEC4899); // Vibrant Pink
  static const Color backgroundColor = Color(0xFF0F172A); // Modern Slate Dark
  static const Color surfaceColor = Color(0xFF1E293B); // Slate Surface
  static const Color accentColor = Color(0xFF10B981); // Emerald Accent (Insights/Growth)
  static const Color errorColor = Color(0xFFEF4444); // Red error
  static const Color secondaryTextColor = Color(0xFF94A3B8); // Slate 400

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onSurface: Color(0xFFE2E8F0),
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
    );
  }
}
