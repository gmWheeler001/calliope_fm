import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../favourites/providers/favourites_provider.dart';
import '../models/radio_player_state.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final notifier = ref.read(playerNotifierProvider.notifier);
    final station = playerState.station;
    final theme = Theme.of(context);
    final favourites = ref.watch(favouritesNotifierProvider);
    final isFav = station != null &&
        ref.watch(favouritesNotifierProvider.notifier).isFavourite(station.stationUuid);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => context.pop(),
        ),
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          if (station != null)
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : null,
              ),
              onPressed: favourites.isLoading
                  ? null
                  : () => ref
                      .read(favouritesNotifierProvider.notifier)
                      .toggle(station),
              tooltip: isFav ? 'Remove from favourites' : 'Add to favourites',
            ),
          IconButton(
            icon: Icon(
              Icons.thumb_up_outlined,
              color: playerState.hasVoted ? theme.colorScheme.primary : null,
            ),
            onPressed: playerState.hasVoted ? null : notifier.vote,
            tooltip: 'Vote for this station',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConstants.paddingFull * 2,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _ArtworkWidget(
                artUri: station?.faviconUrl,
                isBuffering: playerState.isBuffering,
              ),
              const Spacer(flex: 2),
              if (station != null) ...[
                Text(
                  station.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: UiConstants.seperatorFull),
                Text(
                  [
                    if (station.country.isNotEmpty) station.country,
                    if (station.bitrate > 0) '${station.bitrate} kbps',
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (station.tagList.isNotEmpty) ...[
                  const SizedBox(height: UiConstants.seperatorFull),
                  Text(
                    station.tagList.take(3).join(', '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
              const Spacer(flex: 1),
              if (playerState.hasError)
                _ErrorBanner(playerState: playerState, onRetry: notifier.retry),
              const SizedBox(height: UiConstants.seperatorFull),
              _PlaybackControls(playerState: playerState, notifier: notifier),
              const SizedBox(height: UiConstants.paddingFull),
              _VolumeSlider(
                volume: playerState.volume,
                onChanged: notifier.setVolume,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtworkWidget extends StatelessWidget {
  const _ArtworkWidget({required this.artUri, required this.isBuffering});

  final String? artUri;
  final bool isBuffering;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.65;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              UiConstants.buttonCornerRadius * 2,
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: artUri != null
              ? CachedNetworkImage(
                  imageUrl: artUri!,
                  fit: BoxFit.cover,
                  placeholder: (context, _) => const _ArtworkPlaceholder(),
                  errorWidget: (context, url, _) => const _ArtworkPlaceholder(),
                )
              : const _ArtworkPlaceholder(),
        ),
        if (isBuffering)
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
      ],
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.radio,
      size: 80,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.playerState, required this.onRetry});

  final RadioPlayerState playerState;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final countdown = playerState.autoSkipCountdown;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiConstants.paddingFull,
        vertical: UiConstants.seperatorFull,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(UiConstants.buttonCornerRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: UiConstants.seperatorFull),
          Expanded(
            child: Text(
              countdown != null && countdown > 0
                  ? '${playerState.errorMessage ?? "Stream unavailable"} — skipping in ${countdown}s'
                  : (playerState.errorMessage ?? 'Stream unavailable'),
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.playerState, required this.notifier});

  final RadioPlayerState playerState;
  final PlayerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isLoading = playerState.status == PlaybackStatus.loading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedOpacity(
          opacity: playerState.hasPrevious ? 1.0 : 0.15,
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            iconSize: 40,
            icon: const Icon(Icons.skip_previous_rounded),
            onPressed: playerState.hasPrevious ? notifier.skipPrevious : null,
          ),
        ),
        _PlayPauseButton(
          isPlaying: playerState.isPlaying,
          isLoading: isLoading,
          onPressed: notifier.togglePlayPause,
        ),
        AnimatedOpacity(
          opacity: playerState.hasNext ? 1.0 : 0.15,
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            iconSize: 40,
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: playerState.hasNext ? notifier.skipNext : null,
          ),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 36,
              ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({required this.volume, required this.onChanged});

  final double volume;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.volume_down_rounded),
        Expanded(
          child: Slider(value: volume, onChanged: onChanged),
        ),
        const Icon(Icons.volume_up_rounded),
      ],
    );
  }
}
