import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: UiConstants.paddingFull,
        right: UiConstants.paddingFull,
      ),
      child: ClipRRect(
        // Clips blur to rounded corners
        borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),

        child: BackdropFilter(
          // Blurs whatever is below
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            // glass tint + border on top of blur
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
              child: Container(
                height: 114,
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConstants.paddingFull,
                  vertical: UiConstants.paddingFull,
                ),
                child: Row(
                  children: [
                    // Artwork thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        UiConstants.cardCornerRadius / 2,
                      ),
                      child: SizedBox.square(
                        dimension: 60,
                        child: station.faviconUrl != null
                            ? CachedNetworkImage(
                                imageUrl: station.faviconUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, _) =>
                                    const _MiniArtworkPlaceholder(),
                                errorWidget: (context, url, _) =>
                                    const _MiniArtworkPlaceholder(),
                              )
                            : const _MiniArtworkPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: UiConstants.seperatorFull),
                    // Station name + buffering/error indicator
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (playerState.hasError)
                            Text(
                              playerState.autoSkipCountdown != null
                                  ? 'Skipping in ${playerState.autoSkipCountdown}s...'
                                  : 'Stream error',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            )
                          else if (playerState.isBuffering)
                            Text(
                              'Buffering…',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white30),
                            )
                          else if (station.country.isNotEmpty ||
                              station.tagList.isNotEmpty)
                            Text(
                              '${station.country.isNotEmpty ? station.country : ''}${station.country.isNotEmpty && station.tagList.isNotEmpty ? ' - ' : ''}${station.tagList.isNotEmpty ? station.tagList.join(', ') : ''}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white30),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                          SizedBox(height: 4),

                          GradientSlider(
                            volume: playerState.volume,
                            onChanged: notifier.setVolume,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: UiConstants.seperatorFull),

                    if (playerState.status == PlaybackStatus.loading)
                      const SizedBox(width: 30, height: 30)
                    else
                      IconButton.filled(
                        iconSize: 30,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                          foregroundColor: Colors.white70,
                        ),
                        icon: const Icon(Icons.skip_previous_rounded),
                        onPressed: notifier.skipPrevious,
                      ),

                    SizedBox(width: UiConstants.seperatorFull),

                    // Play/pause or loading indicator
                    if (playerState.status == PlaybackStatus.loading)
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    else
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              UiConstants.darkPurple, // dark purple
                              UiConstants.lightPurple, // light purple
                            ],
                          ),
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

                    SizedBox(width: UiConstants.seperatorFull),

                    if (playerState.status == PlaybackStatus.loading)
                      const SizedBox(width: 30, height: 30)
                    else
                      IconButton.filled(
                        iconSize: 30,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade900,
                          foregroundColor: Colors.white70,
                        ),
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: notifier.skipNext,
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

class _MiniArtworkPlaceholder extends StatelessWidget {
  const _MiniArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A148C), // dark purple
            Color(0xFFCE93D8), // light purple
          ],
        ),
        shape: BoxShape.rectangle, // remove if you want square
      ),
      padding: const EdgeInsets.all(
        8,
      ), // keeps spacing similar to IconButton feel
      child: Icon(
        Icons.radio,
        size: 24,
        color: Colors.white, // better contrast on gradient
      ),
    );
  }
}
