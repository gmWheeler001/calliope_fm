import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../favourites/providers/favourites_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../stations/models/radio_station.dart';
import '../../stations/providers/stations_providers.dart';
import '../models/radio_player_state.dart';

part 'player_provider.g.dart';

enum PlaySource { stations, favourites, history }

@Riverpod(keepAlive: true)
class PlayerNotifier extends _$PlayerNotifier {
  late final AudioPlayer _player;
  StreamSubscription<dynamic>? _interruptionSub;
  Timer? _errorSkipTimer;
  String? _lastHistoryUuid;
  PlaySource _source = PlaySource.stations;
  Timer? _sleepTimer;
  double _preFadeVolume = 1.0;

  @override
  RadioPlayerState build() {
    _player = AudioPlayer();
    _setupPlayerListeners();
    _setupAudioSessionInterruptions();

    ref.onDispose(() {
      _errorSkipTimer?.cancel();
      _sleepTimer?.cancel();
      _interruptionSub?.cancel();
      _player.dispose();
    });

    return const RadioPlayerState();
  }

  void _setupPlayerListeners() {
    _player.playerStateStream.listen((ps) {
      if (state.hasError) return;
      final buffering =
          ps.processingState == ProcessingState.buffering ||
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

  /// Called only when the user explicitly selects a station from a tab.
  /// This is the only place _source should change.
  Future<void> play(RadioStation station, {required PlaySource source}) async {
    _source = source;
    await _playStation(station);
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (state.hasError && state.station != null) {
        await _playStation(state.station!);
        return;
      }
      await _player.play();
    }
  }

  void skipNext() {
    if (!state.hasNext || state.station == null) return;
    final list = _sourceList(_source);
    final idx = list.indexWhere(
      (s) => s.stationUuid == state.station!.stationUuid,
    );
    if (idx < 0 || idx >= list.length - 1) return;
    _playStation(list[idx + 1]);
  }

  void skipPrevious() {
    if (!state.hasPrevious || state.station == null) return;
    final list = _sourceList(_source);
    final idx = list.indexWhere(
      (s) => s.stationUuid == state.station!.stationUuid,
    );
    if (idx <= 0) return;
    _playStation(list[idx - 1]);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  Future<void> retry() async {
    _errorSkipTimer?.cancel();
    if (state.station != null) await _playStation(state.station!);
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _preFadeVolume = state.volume;
    state = state.copyWith(sleepTimerRemaining: Duration(minutes: minutes));
    _startSleepCountdown();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    if (state.volume != _preFadeVolume) {
      _player.setVolume(_preFadeVolume);
      state = state.copyWith(volume: _preFadeVolume, clearSleepTimer: true);
    } else {
      state = state.copyWith(clearSleepTimer: true);
    }
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

  Future<void> _playStation(RadioStation station) async {
    _errorSkipTimer?.cancel();

    final list = _sourceList(_source);
    final idx = list.indexWhere((s) => s.stationUuid == station.stationUuid);

    state = state.copyWith(
      station: station,
      status: PlaybackStatus.loading,
      isBuffering: true,
      clearError: true,
      clearCountdown: true,
      hasVoted: false,
      hasNext: _source != PlaySource.history
          ? idx >= 0 && idx < list.length - 1
          : false,
      hasPrevious: _source != PlaySource.history ? idx > 0 : false,
    );

    if (station.streamUrl.isEmpty) {
      _onStreamError();
      return;
    }

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

  List<RadioStation> _sourceList(PlaySource source) => switch (source) {
    PlaySource.stations => ref.read(stationsNotifierProvider).valueOrNull ?? [],
    PlaySource.favourites =>
      ref.read(favouritesNotifierProvider).valueOrNull ?? [],
    PlaySource.history =>
      (ref.read(historyNotifierProvider).valueOrNull ?? [])
          .map((e) => e.station)
          .toList(),
  };

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

  void _startSleepCountdown() {
    final fadeSecs = AppConstants.sleepTimerFadeDurationSeconds;
    var fadeStarted = false;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.sleepTimerRemaining;
      if (remaining == null) {
        timer.cancel();
        return;
      }
      final next = remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        _player.pause();
        _player.setVolume(_preFadeVolume);
        state = state.copyWith(volume: _preFadeVolume, clearSleepTimer: true);
      } else if (next.inSeconds <= fadeSecs) {
        if (!fadeStarted) {
          // Snapshot the actual current volume when the fade window opens,
          // not when the timer was set — the user may have adjusted it since.
          fadeStarted = true;
          _preFadeVolume = state.volume;
        }
        final faded = _preFadeVolume * (next.inSeconds / fadeSecs);
        _player.setVolume(faded);
        state = state.copyWith(sleepTimerRemaining: next, volume: faded);
      } else {
        state = state.copyWith(sleepTimerRemaining: next);
      }
    });
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
