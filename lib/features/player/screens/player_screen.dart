import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/features/player/widgets/gradient_slider.dart';
import 'package:calliope_fm/core/widgets/gradient_blob.dart';
import 'package:calliope_fm/core/widgets/station_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../favourites/providers/favourites_provider.dart';
import '../models/radio_player_state.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.sizeOf(context).height;
    final playerState = ref.watch(playerNotifierProvider);
    final notifier = ref.read(playerNotifierProvider.notifier);
    final station = playerState.station;
    final theme = Theme.of(context);
    final favourites = ref.watch(favouritesNotifierProvider);
    final isFav =
        station != null &&
        ref
            .watch(favouritesNotifierProvider.notifier)
            .isFavourite(station.stationUuid);

    return AnnotatedRegion(
      // Set the status bar to white
      value: SystemUiOverlayStyle.light,
      // Set the keys to close if you tap anywhere on the app that isnt the search
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Layer 1 — background blobs (paint first, sit behind everything)
              Positioned(
                top: -1 * (height / 8),
                left: -1 * (height / 8),
                child: GradientBlob(color: Color(0xFF7c3aed), size: height / 2),
              ),
              Positioned(
                top: height / 8,
                right: -1 * ((height / 3) / 2),
                child: GradientBlob(color: Color(0xFFec4899), size: height / 3),
              ),

              // Layer two, the application content
              Positioned.fill(
                bottom: 0,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: const Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leadingWidth: UiConstants.paddingFull + 44,
                    leading: UnconstrainedBox(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: UiConstants.paddingFull,
                        ),
                        child: _ActionButton(
                          onPressed: () {
                            context.pop();
                          },
                          iconData: Icons.arrow_back_rounded,
                        ),
                      ),
                    ),
                  ),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiConstants.paddingFull,
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          _ArtworkWidget(
                            artUri: station?.faviconUrl,
                            isBuffering: playerState.isBuffering,
                          ),

                          if (station != null) ...[
                            const SizedBox(height: UiConstants.seperatorFull),
                            Text(
                              station.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              [
                                if (station.country.isNotEmpty) station.country,
                                if (station.bitrate > 0)
                                  '${station.bitrate} kbps',
                              ].join(' · '),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white38,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (station.tagList.isNotEmpty) ...[
                              const SizedBox(height: UiConstants.seperatorFull),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: UiConstants.seperatorFull,
                                children: [
                                  for (final tag in station.tagList.take(2))
                                    GenreTag(name: tag),
                                  if (station.isUp) const LiveBadge(),
                                ],
                              ),
                            ],
                          ],

                          _VolumeSlider(
                            volume: playerState.volume,
                            onChanged: notifier.setVolume,
                          ),

                          if (playerState.hasError)
                            _ErrorBanner(
                              playerState: playerState,
                              onRetry: notifier.retry,
                            ),
                          _PlaybackControls(
                            playerState: playerState,
                            notifier: notifier,
                          ),

                          SizedBox(height: UiConstants.paddingFull),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: UiConstants.paddingFull,
                            children: [
                              if (station != null)
                                _ActionButton(
                                  onPressed: favourites.isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              favouritesNotifierProvider
                                                  .notifier,
                                            )
                                            .toggle(station),
                                  iconData: isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),

                              _ActionButton(
                                onPressed: playerState.hasVoted
                                    ? null
                                    : notifier.vote,
                                iconData: playerState.hasVoted
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                              ),

                              _ActionButton(
                                onPressed: () => _showSleepTimerSheet(
                                  context,
                                  notifier,
                                  playerState,
                                ),
                                iconData: playerState.hasSleepTimer
                                    ? Icons.bedtime
                                    : Icons.bedtime_outlined,
                              ),
                            ],
                          ),
                          if (playerState.hasSleepTimer)
                            _SleepTimerBanner(
                              remaining: playerState.sleepTimerRemaining!,
                              onCancel: notifier.cancelSleepTimer,
                            ),
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
          padding: EdgeInsets.all(UiConstants.seperatorFull),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              UiConstants.cardCornerRadius + (UiConstants.seperatorFull + 2),
            ),
            color: Colors.deepPurple.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.09),
              width: 0.5,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(UiConstants.seperatorFull),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                UiConstants.cardCornerRadius + UiConstants.seperatorFull,
              ),
              color: Colors.deepPurple.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  UiConstants.cardCornerRadius,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    UiConstants.darkPurple, // dark purple
                    UiConstants.lightPurple, // light purple
                    Colors.white,
                  ],
                  stops: [0.2, 0.85, 1],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: artUri != null
                  ? CachedNetworkImage(
                      imageUrl: artUri!,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => const _ArtworkPlaceholder(),
                      errorWidget: (context, url, _) =>
                          const _ArtworkPlaceholder(),
                    )
                  : const _ArtworkPlaceholder(),
            ),
          ),
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
      spacing: UiConstants.paddingFull,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: playerState.hasPrevious ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 300),
          child: _ActionButton(
            onPressed: playerState.hasPrevious ? notifier.skipPrevious : null,
            iconData: Icons.skip_previous_rounded,
            size: 60,
          ),
        ),
        _PlayPauseButton(
          isPlaying: playerState.isPlaying,
          isLoading: isLoading,
          onPressed: notifier.togglePlayPause,
        ),
        AnimatedOpacity(
          opacity: playerState.hasNext ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 300),
          child: _ActionButton(
            onPressed: playerState.hasNext ? notifier.skipNext : null,
            iconData: Icons.skip_next_rounded,
            size: 60,
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
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.buttonCornerRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [UiConstants.darkPurple, UiConstants.lightPurple],
        ),
      ),
      child: IconButton(
        icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
        iconSize: 36,
        color: Colors.white,
        onPressed: isLoading ? null : onPressed,
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
    return Padding(
      padding: const EdgeInsets.all(UiConstants.paddingFull),
      child: Row(
        children: [
          const Icon(Icons.volume_down_rounded, color: Colors.white38),
          Expanded(
            child: GradientSlider(
              volume: volume,
              onChanged: onChanged,
              showThumb: true,
            ),
          ),
          const Icon(Icons.volume_up_rounded, color: Colors.white38),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.iconData,
    this.size = 44,
  });

  final Function()? onPressed;
  final IconData iconData;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            UiConstants.buttonCornerRadius / 2,
          ),
          color: Colors.deepPurple.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Icon(
            iconData,
            color: onPressed != null ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }
}


void _showSleepTimerSheet(
  BuildContext context,
  PlayerNotifier notifier,
  RadioPlayerState playerState,
) {
  const presets = [5, 10, 30, 60];
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      padding: const EdgeInsets.all(UiConstants.paddingFull),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(UiConstants.cardCornerRadius),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: UiConstants.paddingHalf,
              bottom: UiConstants.paddingFull,
            ),
            child: Text(
              'Sleep Timer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final mins in presets)
                _SleepPresetButton(
                  label: '${mins}m',
                  isActive: playerState.sleepTimerRemaining?.inMinutes == mins,
                  onTap: () {
                    notifier.setSleepTimer(mins);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
          if (playerState.hasSleepTimer) ...[
            const SizedBox(height: UiConstants.paddingFull),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  notifier.cancelSleepTimer();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel timer',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
          const SizedBox(height: UiConstants.paddingHalf),
        ],
      ),
    ),
  );
}

class _SleepPresetButton extends StatelessWidget {
  const _SleepPresetButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            UiConstants.buttonCornerRadius / 2,
          ),
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [UiConstants.darkPurple, UiConstants.lightPurple],
                )
              : null,
          color: isActive ? null : Colors.deepPurple.withValues(alpha: 0.15),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepTimerBanner extends StatelessWidget {
  const _SleepTimerBanner({required this.remaining, required this.onCancel});

  final Duration remaining;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final mins = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(top: UiConstants.paddingFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConstants.paddingFull,
          vertical: UiConstants.paddingHalf,
        ),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(UiConstants.buttonCornerRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bedtime, size: 16, color: Colors.white54),
            const SizedBox(width: UiConstants.paddingHalf),
            Text(
              'Stops in $mins:$secs',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(width: UiConstants.paddingFull),
            GestureDetector(
              onTap: onCancel,
              child: const Icon(Icons.close, size: 16, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
