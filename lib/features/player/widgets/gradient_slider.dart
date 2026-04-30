import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class GradientSlider extends StatelessWidget {
  const GradientSlider({
    super.key,
    required this.volume,
    required this.onChanged,
  });

  final double volume;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: SliderComponentShape.noThumb, // removes thumb
        overlayShape: SliderComponentShape.noOverlay, // removes ripple
        trackHeight: 6,
        trackShape: _GradientTrackShape(), // custom gradient track
        inactiveTrackColor: Colors.white.withAlpha(33),
      ),
      child: Slider(
        value: volume,
        onChanged: onChanged,
        thumbColor: Colors.transparent,
        allowedInteraction: null,
      ),
    );
  }
}

class _GradientTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    double additionalActiveTrackHeight = 2,
    required TextDirection textDirection,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Canvas canvas = context.canvas;
    final Radius radius = Radius.circular(trackRect.height / 2);

    final bool isLtr = textDirection == TextDirection.ltr;

    final Paint inactivePaint = Paint()
      ..color =
          sliderTheme.inactiveTrackColor ?? Colors.white.withValues(alpha: 0.3);

    // 👇 draw full rounded track FIRST
    final RRect fullTrack = RRect.fromRectAndRadius(trackRect, radius);
    canvas.drawRRect(fullTrack, inactivePaint);

    // 👇 define active region (no rounding here)
    final Rect activeRect = isLtr
        ? Rect.fromLTRB(
            trackRect.left,
            trackRect.top,
            thumbCenter.dx,
            trackRect.bottom,
          )
        : Rect.fromLTRB(
            thumbCenter.dx,
            trackRect.top,
            trackRect.right,
            trackRect.bottom,
          );

    final Paint activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [UiConstants.darkPurple, UiConstants.lightPurple],
      ).createShader(trackRect);

    // 👇 clip to flat rect → removes rounded seam
    canvas.save();
    canvas.clipRect(activeRect);
    canvas.drawRRect(fullTrack, activePaint);
    canvas.restore();
  }
}
