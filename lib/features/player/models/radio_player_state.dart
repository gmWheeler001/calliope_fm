import '../../stations/models/radio_station.dart';

enum PlaybackStatus { idle, loading, playing, paused, error }

class RadioPlayerState {
  const RadioPlayerState({
    this.station,
    this.status = PlaybackStatus.idle,
    this.isBuffering = false,
    this.errorMessage,
    this.autoSkipCountdown,
    this.hasVoted = false,
    this.hasNext = false,
    this.hasPrevious = false,
    this.sleepTimerRemaining,
  });

  final RadioStation? station;
  final PlaybackStatus status;
  final bool isBuffering;
  final String? errorMessage;
  final int? autoSkipCountdown;
  final bool hasVoted;
  final bool hasNext;
  final bool hasPrevious;
  final Duration? sleepTimerRemaining;

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get hasStation => station != null;
  bool get hasError => status == PlaybackStatus.error;
  bool get hasSleepTimer => sleepTimerRemaining != null;

  RadioPlayerState copyWith({
    RadioStation? station,
    PlaybackStatus? status,
    bool? isBuffering,
    String? errorMessage,
    int? autoSkipCountdown,
    bool? hasVoted,
    bool? hasNext,
    bool? hasPrevious,
    Duration? sleepTimerRemaining,
    bool clearStation = false,
    bool clearError = false,
    bool clearCountdown = false,
    bool clearSleepTimer = false,
  }) {
    return RadioPlayerState(
      station: clearStation ? null : (station ?? this.station),
      status: status ?? this.status,
      isBuffering: isBuffering ?? this.isBuffering,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      autoSkipCountdown:
          clearCountdown ? null : (autoSkipCountdown ?? this.autoSkipCountdown),
      hasVoted: hasVoted ?? this.hasVoted,
      hasNext: clearStation ? false : (hasNext ?? this.hasNext),
      hasPrevious: clearStation ? false : (hasPrevious ?? this.hasPrevious),
      sleepTimerRemaining:
          clearSleepTimer ? null : (sleepTimerRemaining ?? this.sleepTimerRemaining),
    );
  }
}
