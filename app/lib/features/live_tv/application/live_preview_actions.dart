import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../player/data/player_providers.dart';
import '../data/live_tv_data_providers.dart';
import '../domain/live_channel.dart';
import 'live_tv_providers.dart';

part 'live_preview_actions.g.dart';

@Riverpod(keepAlive: true)
LivePreviewActions livePreviewActions(Ref ref) => LivePreviewActions(ref);

/// Playback in the guide preview (LIVE-1, UI-1): like common IPTV players,
/// select on a channel plays it in the preview first; select on the channel
/// the preview shows opens it full screen.
class LivePreviewActions {
  LivePreviewActions(this._ref);

  final Ref _ref;

  Future<LiveChannel?> _channelAt(LivePosition position) async {
    final channels = await _ref
        .read(liveTvRepositoryProvider)
        .getChannels(
          position.playlistId,
          categoryId: position.categoryId,
          offset: position.index,
          limit: 1,
        );
    return channels.firstOrNull;
  }

  /// Whether [position] holds the channel that plays right now. The same
  /// channel counts in any category.
  Future<bool> isPlaying(LivePosition position) async {
    final playing = _ref.read(nowPlayingProvider)?.channel;
    if (playing == null) return false;
    return await _channelAt(position) == playing;
  }

  /// Plays the channel at [position] in the preview. The caller keeps the
  /// auto-disposed playback engine alive while the preview shows.
  Future<void> play(LivePosition position) async {
    final channel = await _channelAt(position);
    if (channel == null) return;
    // Listening keeps the auto-disposed provider running until it answers;
    // a plain read could leave it paused without listeners.
    final subscription = _ref.listen(
      liveStreamUrlProvider(channel).future,
      (_, _) {},
    );
    final String url;
    try {
      url = await subscription.read();
    } finally {
      subscription.close();
    }
    _ref.read(nowPlayingProvider.notifier).set(position, channel);
    await _ref.read(playbackEngineProvider).open(url, live: true);
  }
}
