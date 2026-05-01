// The blob widget — a simple blurred circle
import 'package:flutter/material.dart';

class GradientBlob extends StatelessWidget {
  const GradientBlob({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.33), Colors.transparent],
          stops: [0.0, 1.0],
        ),
      ),
    );
  }
}
