import 'package:flutter/material.dart';

class AppTheme {
  // static const Color tiffanyBlue = Color(0xFF0ABAB5);
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: teal,
        secondary: Colors.cyanAccent,
        brightness: Brightness.dark,
        surface: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black87, foregroundColor: teal),
    );
  }
}
