import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../application/player_settings_providers.dart';
import '../domain/playback_engine.dart';
import 'audio_output_capabilities.dart';
import 'better_player_playback_engine.dart';
import 'fallback_playback_engine.dart';
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
  final engine = FallbackPlaybackEngine([
    // better_player never reports endless MPEG-TS live streams as ready,
    // so it is left out until our own Media3 engine replaces it (PLAY-5).
    if (android && _betterPlayer)
      (name: 'better_player (Media3)', create: BetterPlayerPlaybackEngine.new),
    mediaKit,
  ], platform: kIsWeb ? 'web' : defaultTargetPlatform.name);
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

const _betterPlayer = false;
