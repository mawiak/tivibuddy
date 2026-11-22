import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../application/full_screen_playback.dart';
import '../application/player_settings_providers.dart';
import '../domain/playback_engine.dart';
import '../domain/player_settings.dart';
import 'audio_output_capabilities.dart';
import 'display_frame_rate.dart';
import 'fallback_playback_engine.dart';
import 'media3_playback_engine.dart';
import 'media_kit_playback_engine.dart';

part 'player_providers.g.dart';

/// Playback engine shared by the full screen player and the guide preview.
/// Auto-disposed when neither shows it anymore, which frees decoders and
/// buffers (RES-1). While it exists the screen stays on; platforms without
/// wake lock support simply do not get that. Changed player settings apply
/// to the next engine.
@riverpod
PlaybackEngine playbackEngine(Ref ref) {
  final settings = ref.read(playerSettingsControllerProvider);
  final capabilities = ref.read(audioOutputCapabilitiesProvider);
  final mediaKit = (
    name: 'media_kit (libmpv)',
    create: () => MediaKitPlaybackEngine(settings, capabilities),
  );
  final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  const media3 = (name: 'Media3 (ExoPlayer)', create: Media3PlaybackEngine.new);
  final engine = FallbackPlaybackEngine(
    // Media3 passes Dolby through and uses the platform decoders; mpv plays
    // what Media3 cannot (PLAY-5). The choice exists for finding problems.
    android
        ? switch (settings.engine) {
            PlayerEngineChoice.automatic => [media3, mediaKit],
            PlayerEngineChoice.media3 => [media3],
            PlayerEngineChoice.mediaKit => [mediaKit],
          }
        : [mediaKit],
    platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
  );
  if (settings.frameRateMatching != FrameRateMatching.off &&
      DisplayModeSwitcher.supported) {
    final follower = FrameRateFollower(
      engine,
      settings.frameRateMatching,
      fullScreen: () => ref.read(fullScreenPlaybackProvider),
    )..start();
    ref
      ..listen(fullScreenPlaybackProvider, (_, _) => follower.update())
      ..onDispose(() => follower.stop().ignore());
  }
  final lifecycle = AppLifecycleListener(
    onHide: () => engine.suspend().ignore(),
    onShow: () => engine.resume().ignore(),
  );
  ref.onDispose(lifecycle.dispose);
  WakelockPlus.enable().ignore();
  ref.onDispose(() {
    WakelockPlus.disable().ignore();
    engine.dispose();
  });
  return engine;
}

@Riverpod(keepAlive: true)
AudioOutputCapabilities audioOutputCapabilities(Ref ref) =>
    const AudioOutputCapabilities();
