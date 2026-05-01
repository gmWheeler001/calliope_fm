import 'package:flutter/widgets.dart';

abstract final class UiConstants {
  // Spacing
  static const double paddingFull = 16.0;
  static const double paddingDouble = 32.0;
  static const double paddingHalf = 8.0;
  static const double seperatorFull = 8.0;
  static const double seperatorHalf = 4.0;
  static const double marginFull = 16.0;
  static const double marginHalf = 8.0;

  // Shape
  static const double buttonCornerRadius = 24.0;
  static const double cardCornerRadius = 32.0;

  // Brand colours
  static const Color darkPurple = Color(0xFF4A148C);
  static const Color lightPurple = Color(0xFFCE93D8);

  // Background blob accent colours
  static const Color violetBlob = Color(0xFF7C3AED);
  static const Color pinkBlob = Color(0xFFEC4899);

  // Glass surface — white at 28% opacity
  static const Color glassOutlineColor = Color(0x47FFFFFF);

  // Reusable gradient used on buttons, sliders, artwork backgrounds
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPurple, lightPurple],
  );
}
