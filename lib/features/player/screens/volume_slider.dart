import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/features/player/providers/player_provider.dart';
import 'package:calliope_fm/features/player/widgets/gradient_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VolumeSlider extends ConsumerWidget {
  const VolumeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(playerVolumeProvider);
    final notifier = ref.read(playerNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(UiConstants.paddingFull),
      child: Row(
        children: [
          const Icon(Icons.volume_down_rounded, color: Colors.white38),
          Expanded(
            child: GradientSlider(
              volume: volume,
              onChanged: notifier.setVolume,
            ),
          ),
          const Icon(Icons.volume_up_rounded, color: Colors.white38),
        ],
      ),
    );
  }
}
