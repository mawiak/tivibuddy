enum PlaybackStatus { idle, opening, buffering, playing, paused, failed }

class PlaybackState {
  const PlaybackState({
    this.status = PlaybackStatus.idle,
    this.error,
    this.videoWidth,
    this.videoHeight,
    this.duration,
  });

  static const idle = PlaybackState();

  final PlaybackStatus status;
  final String? error;
  final int? videoWidth;
  final int? videoHeight;

  /// Length of the media; null or zero for live streams.
  final Duration? duration;

  bool get isBusy =>
      status == PlaybackStatus.opening || status == PlaybackStatus.buffering;

  PlaybackState copyWith({
    PlaybackStatus? status,
    String? error,
    int? videoWidth,
    int? videoHeight,
    Duration? duration,
  }) => PlaybackState(
    status: status ?? this.status,
    error: error,
    videoWidth: videoWidth ?? this.videoWidth,
    videoHeight: videoHeight ?? this.videoHeight,
    duration: duration ?? this.duration,
  );
}

/// Plays a media URL (PLAY-3). The default implementation uses libmpv
/// through media_kit; other backends (for example Media3 on Android) can be
/// added behind this interface.
abstract interface class PlaybackEngine {
  Stream<PlaybackState> get states;

  PlaybackState get state;

  /// Plays [url], for media with a known length from [start] on.
  Future<void> open(String url, {Duration? start});

  /// Playback position, updated while playing.
  Stream<Duration> get positions;

  Duration get position;

  Future<void> seek(Duration position);

  Future<void> togglePause();

  Future<void> stop();

  /// Releases decoders and buffers. The engine cannot be used afterwards.
  Future<void> dispose();
}
