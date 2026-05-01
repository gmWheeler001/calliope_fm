import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class RadioArtworkPlaceholder extends StatelessWidget {
  const RadioArtworkPlaceholder({super.key, this.iconSize = 24});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [UiConstants.darkPurple, UiConstants.lightPurple],
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(Icons.radio, size: iconSize, color: Colors.white),
    );
  }
}