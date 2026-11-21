/// Which playback engines play streams on Android (PLAY-5).
enum PlayerEngineChoice {
  /// Media3 first, media_kit for what Media3 cannot play.
  automatic,

  /// Media3 only, to see whether a problem comes from it.
  media3,

  /// media_kit (libmpv) only; its decoder and passthrough settings apply.
  mediaKit,
}

/// When the display follows the frame rate of the video (PLAY-6). Each
/// switch turns the TV black for a moment.
enum FrameRateMatching {
  off,

  /// Films and episodes only; live TV keeps the display's default rate.
  vodOnly,

  /// Every stream, live TV included.
  always,
}

/// How media_kit decodes video (PLAY-2). Some chips render wrong colours in one
/// mode and fine in another, so the user can switch per device.
enum VideoDecoder {
  /// The hardware decoder renders straight into the video surface: fastest.
  hardware,

  /// The hardware decoder copies its frames back for rendering.
  hardwareCopy,

  /// FFmpeg decodes on the CPU: slowest, but independent of the chip.
  software,
}

/// Compressed audio formats sent unchanged to a receiver or soundbar over
/// HDMI or S/PDIF instead of being decoded to PCM.
enum AudioPassthrough {
  ac3('ac3'),
  eac3('eac3'),
  dts('dts'),
  dtsHd('dts-hd'),
  trueHd('truehd');

  const AudioPassthrough(this.mpvName);

  /// Name in the `audio-spdif` option of mpv.
  final String mpvName;
}

/// Player settings of this device (SET-1).
class PlayerSettings {
  const PlayerSettings({
    this.engine = PlayerEngineChoice.automatic,
    this.frameRateMatching = FrameRateMatching.off,
    this.decoder = VideoDecoder.hardware,
    this.passthrough = const {},
  });

  static const defaults = PlayerSettings();

  final PlayerEngineChoice engine;

  final FrameRateMatching frameRateMatching;

  final VideoDecoder decoder;

  /// Formats passed through; empty decodes all audio to PCM, which every
  /// output understands.
  final Set<AudioPassthrough> passthrough;

  PlayerSettings copyWith({
    PlayerEngineChoice? engine,
    FrameRateMatching? frameRateMatching,
    VideoDecoder? decoder,
    Set<AudioPassthrough>? passthrough,
  }) => PlayerSettings(
    engine: engine ?? this.engine,
    frameRateMatching: frameRateMatching ?? this.frameRateMatching,
    decoder: decoder ?? this.decoder,
    passthrough: passthrough ?? this.passthrough,
  );

  @override
  bool operator ==(Object other) =>
      other is PlayerSettings &&
      other.engine == engine &&
      other.frameRateMatching == frameRateMatching &&
      other.decoder == decoder &&
      other.passthrough.length == passthrough.length &&
      other.passthrough.containsAll(passthrough);

  @override
  int get hashCode => Object.hash(
    engine,
    frameRateMatching,
    decoder,
    Object.hashAllUnordered(passthrough),
  );
}
