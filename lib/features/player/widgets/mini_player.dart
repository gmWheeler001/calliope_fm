import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/core/widgets/radio_artwork_placeholder.dart';
import 'package:calliope_fm/features/player/widgets/gradient_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/radio_player_state.dart';
import '../providers/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    if (!playerState.hasStation) return const SizedBox.shrink();

    final station = playerState.station!;
    final notifier = ref.read(playerNotifierProvider.notifier);
    final volume = ref.watch(playerVolumeProvider);
    final theme = Theme.of(context);

    final subText =
        '${station.country.isNotEmpty ? '${station.country} ' : ''}'
        '${station.bitrate}kbps';

    final artSize =
        (MediaQuery.sizeOf(context).width - UiConstants.paddingDouble * 2) / 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiConstants.paddingFull),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 0.5,
              ),
            ),
            child: InkWell(
              onTap: () => context.push('/player'),
              borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConstants.paddingFull,
                  vertical: UiConstants.paddingHalf,
                ),
                child: Row(
                  children: [
                    // Artwork
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        UiConstants.cardCornerRadius / 2,
                      ),
                      child: SizedBox.square(
                        dimension: artSize,
                        child: station.faviconUrl != null
                            ? CachedNetworkImage(
                                imageUrl: station.faviconUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, _) =>
                                    const RadioArtworkPlaceholder(),
                                errorWidget: (context, url, _) =>
                                    const RadioArtworkPlaceholder(),
                              )
                            : const RadioArtworkPlaceholder(),
                      ),
                    ),

                    const SizedBox(width: UiConstants.seperatorFull),

                    // Station info + controls
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),

                          const SizedBox(height: UiConstants.seperatorHalf),

                          // Status text + skip/play buttons
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (playerState.hasError)
                                      Text(
                                        playerState.autoSkipCountdown != null
                                            ? 'Skipping in ${playerState.autoSkipCountdown}s...'
                                            : 'Stream error',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                      )
                                    else if (playerState.isBuffering)
                                      Text(
                                        'Buffering…',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.white30),
                                      )
                                    else if (station.country.isNotEmpty ||
                                        station.tagList.isNotEmpty)
                                      Text(
                                        subText,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.white30),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: UiConstants.seperatorHalf),

                              if (playerState.status == PlaybackStatus.loading)
                                const SizedBox(width: 30, height: 30)
                              else
                                AnimatedOpacity(
                                  opacity: playerState.hasPrevious ? 1.0 : 0.4,
                                  duration: const Duration(milliseconds: 300),
                                  child: IconButton.filled(
                                    iconSize: 30,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.grey.shade900,
                                      foregroundColor: Colors.white70,
                                    ),
                                    icon: const Icon(
                                      Icons.skip_previous_rounded,
                                    ),
                                    onPressed: playerState.hasPrevious
                                        ? notifier.skipPrevious
                                        : null,
                                  ),
                                ),

                              const SizedBox(width: UiConstants.seperatorFull),

                              if (playerState.status == PlaybackStatus.loading)
                                const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              else
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: UiConstants.purpleGradient,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      playerState.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                                    iconSize: 32,
                                    color: Colors.white,
                                    onPressed: notifier.togglePlayPause,
                                  ),
                                ),

                              const SizedBox(width: UiConstants.seperatorFull),

                              if (playerState.status == PlaybackStatus.loading)
                                const SizedBox(width: 30, height: 30)
                              else
                                AnimatedOpacity(
                                  opacity: playerState.hasNext ? 1.0 : 0.4,
                                  duration: const Duration(milliseconds: 300),
                                  child: IconButton.filled(
                                    iconSize: 30,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.grey.shade900,
                                      foregroundColor: Colors.white70,
                                    ),
                                    icon: const Icon(Icons.skip_next_rounded),
                                    onPressed: playerState.hasNext
                                        ? notifier.skipNext
                                        : null,
                                  ),
                                ),
                            ],
                          ),

                          // Volume (display only — interaction blocked)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: UiConstants.seperatorFull,
                              bottom: UiConstants.seperatorHalf,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.volume_down,
                                  size: 15,
                                  applyTextScaling: false,
                                  color: Colors.white30,
                                ),
                                Expanded(
                                  child: GradientSlider(
                                    volume: volume,
                                    onChanged: notifier.setVolume,
                                  ),
                                ),
                                const Icon(
                                  Icons.volume_up,
                                  size: 15,
                                  applyTextScaling: false,
                                  color: Colors.white30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
