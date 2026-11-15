import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../application/player_settings_providers.dart';
import '../domain/playback_engine.dart';
import 'media_kit_playback_engine.dart';

part 'player_providers.g.dart';

/// Playback engine shared by the full screen player and the guide preview.
/// Auto-disposed when neither shows it anymore, which frees decoders and
/// buffers (RES-1). While it exists the screen stays on; platforms without
/// wake lock support simply do not get that. Changed player settings apply
/// to the next engine.
@riverpod
PlaybackEngine playbackEngine(Ref ref) {
  final engine = MediaKitPlaybackEngine(
    ref.read(playerSettingsControllerProvider),
  );
  WakelockPlus.enable().ignore();
  ref.onDispose(() {
    WakelockPlus.disable().ignore();
    engine.dispose();
  });
  return engine;
}
