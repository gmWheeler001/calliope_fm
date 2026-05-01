import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';

abstract final class AppTheme {
  static const Color background = Color(0xFF0d0d14);

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: background,
      useMaterial3: true,
      textTheme: const TextTheme(
        // Large station name — featured card, player screen
        headlineSmall: TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        // Station card title
        titleMedium: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        // Section labels e.g. "FEATURED STATION"
        titleSmall: TextStyle(
          fontSize: 14,
          color: Colors.white38,
          fontWeight: FontWeight.w600,
        ),
        // General body copy
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
        // Meta text — bitrate, country, tags
        bodySmall: TextStyle(fontSize: 12, color: Colors.white54),
        // Small badge labels e.g. "LIVE"
        labelSmall: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConstants.buttonCornerRadius),
        ),
      ),
    );
  }
}
