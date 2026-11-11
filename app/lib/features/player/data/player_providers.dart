import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/playback_engine.dart';
import 'media_kit_playback_engine.dart';

part 'player_providers.g.dart';

/// Playback engine of the open player screen. Auto-disposed when the screen
/// closes, which frees decoders and buffers (RES-1).
@riverpod
PlaybackEngine playbackEngine(Ref ref) {
  final engine = MediaKitPlaybackEngine();
  ref.onDispose(engine.dispose);
  return engine;
}
