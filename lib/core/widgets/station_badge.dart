import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.tealAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class GenreTag extends StatelessWidget {
  const GenreTag({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiConstants.paddingHalf,
        vertical: UiConstants.paddingHalf / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      child: Text(
        name,
        style: const TextStyle(fontSize: 12, color: Colors.white54),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}