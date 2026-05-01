import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../history/providers/history_provider.dart';
import '../../stations/models/radio_station.dart';
import '../../stations/providers/stations_providers.dart';
import '../models/radio_player_state.dart';

part 'player_provider.g.dart';

@Riverpod(keepAlive: true)
class PlayerNotifier extends _$PlayerNotifier {
  late final AudioPlayer _player;
  StreamSubscription<dynamic>? _interruptionSub;
  Timer? _errorSkipTimer;
  String? _lastHistoryUuid;

  @override
  RadioPlayerState build() {
    _player = AudioPlayer();
    _setupPlayerListeners();
    _setupAudioSessionInterruptions();

    ref.onDispose(() {
      _errorSkipTimer?.cancel();
      _interruptionSub?.cancel();
      _player.dispose();
    });

    return const RadioPlayerState();
  }

  void _setupPlayerListeners() {
    _player.playerStateStream.listen((ps) {
      if (state.hasError) return; // don't override error state with stale events
      final buffering = ps.processingState == ProcessingState.buffering ||
          ps.processingState == ProcessingState.loading;
      final PlaybackStatus status;
      switch (ps.processingState) {
        case ProcessingState.idle:
          status = PlaybackStatus.idle;
        case ProcessingState.loading:
          status = PlaybackStatus.loading;
        case ProcessingState.buffering:
          status = ps.playing ? PlaybackStatus.playing : PlaybackStatus.paused;
        case ProcessingState.ready:
          status = ps.playing ? PlaybackStatus.playing : PlaybackStatus.paused;
        case ProcessingState.completed:
          status = PlaybackStatus.paused;
      }
      state = state.copyWith(status: status, isBuffering: buffering);

      if (ps.processingState == ProcessingState.ready && ps.playing) {
        final station = state.station;
        if (station != null && station.stationUuid != _lastHistoryUuid) {
          _lastHistoryUuid = station.stationUuid;
          ref.read(historyNotifierProvider.notifier).add(station);
        }
      }
    });

    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) => _onStreamError(),
    );
  }

  void _setupAudioSessionInterruptions() {
    AudioSession.instance.then((session) {
      _interruptionSub = session.interruptionEventStream.listen((event) {
        if (event.begin) _player.pause();
      });
    });
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  Future<void> play(RadioStation station) async {
    _errorSkipTimer?.cancel();
    state = state.copyWith(
      station: station,
      status: PlaybackStatus.loading,
      isBuffering: true,
      clearError: true,
      clearCountdown: true,
      hasVoted: false,
    );

    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(station.streamUrl),
          tag: MediaItem(
            id: station.stationUuid,
            title: station.name,
            artist: station.country.isNotEmpty
                ? station.country
                : 'Internet Radio',
            artUri: station.faviconUrl != null
                ? Uri.parse(station.faviconUrl!)
                : null,
          ),
        ),
      );
      await _player.play();
    } catch (e) {
      _onStreamError();
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (state.hasError && state.station != null) {
        await play(state.station!);
        return;
      }
      await _player.play();
    }
  }

  void skipNext() {
    final stations = ref.read(stationsNotifierProvider).valueOrNull ?? [];
    if (stations.isEmpty) return;
    if (state.station == null) {
      play(stations.first);
      return;
    }
    final idx = stations.indexWhere(
      (s) => s.stationUuid == state.station!.stationUuid,
    );
    play(stations[(idx < 0 ? 0 : idx + 1) % stations.length]);
  }

  void skipPrevious() {
    final stations = ref.read(stationsNotifierProvider).valueOrNull ?? [];
    if (stations.isEmpty || state.station == null) return;
    final idx = stations.indexWhere(
      (s) => s.stationUuid == state.station!.stationUuid,
    );
    play(stations[idx <= 0 ? stations.length - 1 : idx - 1]);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  Future<void> retry() async {
    _errorSkipTimer?.cancel();
    if (state.station != null) await play(state.station!);
  }

  Future<void> vote() async {
    if (state.hasVoted || state.station == null) return;
    state = state.copyWith(hasVoted: true);
    try {
      await ref
          .read(radioBrowserApiProvider)
          .voteForStation(state.station!.stationUuid);
    } catch (_) {
      // vote failures are silent
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  void _onStreamError() {
    _errorSkipTimer?.cancel();
    state = state.copyWith(
      status: PlaybackStatus.error,
      isBuffering: false,
      errorMessage: 'Stream unavailable',
      autoSkipCountdown: 5,
    );
    _startAutoSkipCountdown();
  }

  void _startAutoSkipCountdown() {
    int countdown = 5;
    _errorSkipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if (countdown <= 0) {
        timer.cancel();
        skipNext();
      } else {
        state = state.copyWith(autoSkipCountdown: countdown);
      }
    });
  }
}
