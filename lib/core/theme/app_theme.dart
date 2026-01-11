import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { light, dark, amoled }

class AppThemes {
  static final TextTheme _textTheme = GoogleFonts.interTextTheme();

  // LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardColor: Colors.white,
    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFF1A1A1A),
      displayColor: const Color(0xFF1A1A1A),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withValues(alpha: 0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    useMaterial3: true,
  );

  // DARK THEME (Modern Dark Grey)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFFEDEDED),
      displayColor: const Color(0xFFEDEDED),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
    ),
    useMaterial3: true,
  );

  // AMOLED THEME (Pure Black)
  static final ThemeData amoledTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(
      0xFF000000,
    ), // Often borders are needed to distinguish
    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFFE0E0E0),
      displayColor: const Color(0xFFE0E0E0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.dark,
      surface: Colors.black,
    ),
    dividerColor: const Color(0xFF333333),
    useMaterial3: true,
  );

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.amoled:
        return amoledTheme;
    }
  }
}
