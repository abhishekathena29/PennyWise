import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF7FAFA);
  static const Color foreground = Color(0xFF1F3D3A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF25B8A3);
  static const Color secondary = Color(0xFFE7F5F2);
  static const Color muted = Color(0xFFEEF2F2);
  static const Color mutedForeground = Color(0xFF6B7F7D);
  static const Color border = Color(0xFFE2EAEA);
  static const Color income = Color(0xFF24B37E);
  static const Color expense = Color(0xFFDF4C4C);
  static const Color warning = Color(0xFFF2A23A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF25B8A3), Color(0xFF1E9A90)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C3D39), Color(0xFF234B44)],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      cardTheme: const CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
