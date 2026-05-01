import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color _background = Color(0xFF0d0d14);

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _background,
      useMaterial3: true,
    );
  }
}
