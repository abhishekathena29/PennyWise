import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // True on iOS device/simulator; false on web, Android, desktop
  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  /// Returns the correct fontFamily string for non-white-labeled text.
  /// On iOS, returns null so the system SF Pro is used.
  /// On all other platforms, returns the Inter font family from google_fonts.
  static String? get fontFamily =>
      _isIOS ? null : GoogleFonts.inter().fontFamily;

  static TextTheme get _textTheme {
    const base = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: foreground,
        letterSpacing: -1.0,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: foreground,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: foreground,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: foreground,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: foreground,
        letterSpacing: -0.2,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedForeground,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: foreground,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedForeground,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: mutedForeground,
        letterSpacing: 0.3,
      ),
    );

    // On iOS, SF Pro is the system default — no fontFamily needed
    if (_isIOS) return base;

    // On all other platforms, apply Inter via google_fonts
    return GoogleFonts.interTextTheme(base);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Setting fontFamily here ensures ALL Text widgets in the app
      // inherit the correct font even when TextStyle doesn't specify one.
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        surface: background,
        onSurface: foreground,
        onSurfaceVariant: mutedForeground,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
