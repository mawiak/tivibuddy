import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/live_tv_data_providers.dart';
import '../domain/live_channel.dart';

part 'guide_providers.g.dart';

/// The guide loads programmes per channel in windows of two chunks. A view
/// of up to one chunk always fits into the window of the chunk it starts
/// in, so scrolling within a chunk reuses the loaded programmes.
const guideChunk = Duration(hours: 6);

/// Start of the chunk containing [time].
DateTime guideChunkStart(DateTime time) {
  final chunkMs = guideChunk.inMilliseconds;
  final ms = time.millisecondsSinceEpoch;
  return DateTime.fromMillisecondsSinceEpoch(ms - ms % chunkMs, isUtc: true);
}

@riverpod
Stream<DateTime?> epgLoadedAt(Ref ref, String playlistId) =>
    ref.watch(epgRepositoryProvider).watchLoadedAt(playlistId);

/// Programmes of a channel in the window starting at [chunkStart]. Reloaded
/// when a guide load completes.
@riverpod
Future<List<EpgEntry>> guideProgrammes(
  Ref ref,
  String playlistId,
  String channelKey,
  DateTime chunkStart,
) {
  ref.watch(epgLoadedAtProvider(playlistId));
  return ref
      .watch(epgRepositoryProvider)
      .getProgrammes(
        playlistId,
        channelKey,
        from: chunkStart,
        to: chunkStart.add(guideChunk * 2),
      );
}
