enum PlaybackStatus { idle, opening, buffering, playing, paused, ended, failed }

class PlaybackState {
  const PlaybackState({
    this.status = PlaybackStatus.idle,
    this.error,
    this.videoWidth,
    this.videoHeight,
    this.duration,
    this.frameRate,
  });

  static const idle = PlaybackState();

  final PlaybackStatus status;
  final String? error;
  final int? videoWidth;
  final int? videoHeight;

  /// Length of the media; null or zero for live streams.
  final Duration? duration;

  /// Frames per second of the video, once known (see [standardFrameRate]).
  final double? frameRate;

  /// Playback stopped by itself: an error, or the end of the media.
  bool get stopped =>
      status == PlaybackStatus.failed || status == PlaybackStatus.ended;

  bool get isBusy =>
      status == PlaybackStatus.opening || status == PlaybackStatus.buffering;

  PlaybackState copyWith({
    PlaybackStatus? status,
    String? error,
    int? videoWidth,
    int? videoHeight,
    Duration? duration,
    double? frameRate,
  }) => PlaybackState(
    status: status ?? this.status,
    error: error,
    videoWidth: videoWidth ?? this.videoWidth,
    videoHeight: videoHeight ?? this.videoHeight,
    duration: duration ?? this.duration,
    frameRate: frameRate ?? this.frameRate,
  );
}

/// The broadcast or film frame rate closest to [measured], or [measured]
/// itself when none is close: measurements and containers give values like
/// 23.97602 or 49.99 for 23.976 and 50 fps.
double standardFrameRate(double measured) {
  const rates = [23.976, 24, 25, 29.97, 30, 47.952, 48, 50, 59.94, 60];
  double deviation(num rate) => (measured - rate).abs() / rate;
  final closest = rates.reduce((a, b) => deviation(a) <= deviation(b) ? a : b);
  return deviation(closest) < 0.003 ? closest.toDouble() : measured;
}

enum MediaTrackType { audio, subtitle, video }

/// An audio, subtitle or video track of the playing media (PLAY-4).
class MediaTrack {
  const MediaTrack({
    required this.id,
    required this.type,
    this.language,
    this.title,
    this.codec,
    this.channels,
    this.width,
    this.height,
  });

  final String id;
  final MediaTrackType type;

  /// Language code as in the stream, for example `deu`, `ger` or `en`.
  final String? language;
  final String? title;
  final String? codec;

  /// Audio channels, for example 6 for 5.1.
  final int? channels;
  final int? width;
  final int? height;
}

/// Tracks of the playing media and the selected one of each type; a null
/// selection means off.
class MediaTracks {
  const MediaTracks({
    this.audio = const [],
    this.subtitle = const [],
    this.video = const [],
    this.selectedAudio,
    this.selectedSubtitle,
    this.selectedVideo,
  });

  static const none = MediaTracks();

  final List<MediaTrack> audio;
  final List<MediaTrack> subtitle;
  final List<MediaTrack> video;
  final String? selectedAudio;
  final String? selectedSubtitle;
  final String? selectedVideo;

  List<MediaTrack> of(MediaTrackType type) => switch (type) {
    MediaTrackType.audio => audio,
    MediaTrackType.subtitle => subtitle,
    MediaTrackType.video => video,
  };

  String? selected(MediaTrackType type) => switch (type) {
    MediaTrackType.audio => selectedAudio,
    MediaTrackType.subtitle => selectedSubtitle,
    MediaTrackType.video => selectedVideo,
  };

  MediaTrack? selectedTrack(MediaTrackType type) {
    final id = selected(type);
    return of(type).where((t) => t.id == id).firstOrNull;
  }
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

  /// Tracks of the playing media, updated when they change.
  Stream<MediaTracks> get tracks;

  MediaTracks get currentTracks;

  /// Selects the track [id] of [type]; null switches the type off.
  Future<void> selectTrack(MediaTrackType type, String? id);

  Future<void> togglePause();

  Future<void> stop();

  /// Releases decoders and buffers. The engine cannot be used afterwards.
  Future<void> dispose();
}
