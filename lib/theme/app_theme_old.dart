import 'package:flutter/material.dart';

class AppTheme {
  static const Color tiffanyBlue = Color(0xFF0ABAB5);
  static const Color teal = Colors.teal;

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: teal,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: teal, foregroundColor: Colors.white),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,

      // 1. Set the background color for all Scaffolds directly in ThemeData
      // scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Colors.red,
        secondary: Colors.redAccent,
        // secondaryContainer: Colors.red, // <-- This colors the NavigationRail indicator
        // 2. Use 'surface' for cards, dialogs, bottom sheets, and navigation rails
        // surface: Colors.black87,

        // Optional: If you need text on the surface to be a specific color
        // onSurface: Colors.white,
      ),
    );
  }
}
