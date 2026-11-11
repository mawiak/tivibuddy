enum PlaybackStatus { idle, opening, buffering, playing, paused, failed }

class PlaybackState {
  const PlaybackState({
    this.status = PlaybackStatus.idle,
    this.error,
    this.videoWidth,
    this.videoHeight,
  });

  static const idle = PlaybackState();

  final PlaybackStatus status;
  final String? error;
  final int? videoWidth;
  final int? videoHeight;

  bool get isBusy =>
      status == PlaybackStatus.opening || status == PlaybackStatus.buffering;

  PlaybackState copyWith({
    PlaybackStatus? status,
    String? error,
    int? videoWidth,
    int? videoHeight,
  }) => PlaybackState(
    status: status ?? this.status,
    error: error,
    videoWidth: videoWidth ?? this.videoWidth,
    videoHeight: videoHeight ?? this.videoHeight,
  );
}

/// Plays a media URL (PLAY-3). The default implementation uses libmpv
/// through media_kit; other backends (for example Media3 on Android) can be
/// added behind this interface.
abstract interface class PlaybackEngine {
  Stream<PlaybackState> get states;

  PlaybackState get state;

  Future<void> open(String url);

  Future<void> togglePause();

  Future<void> stop();

  /// Releases decoders and buffers. The engine cannot be used afterwards.
  Future<void> dispose();
}
