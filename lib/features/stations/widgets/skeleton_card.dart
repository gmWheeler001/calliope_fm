import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 72});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: UiConstants.purpleGradient,
        borderRadius: BorderRadius.circular(UiConstants.buttonCornerRadius),
      ),
    );
  }
}
