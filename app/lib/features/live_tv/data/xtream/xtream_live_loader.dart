import 'package:http/http.dart' as http;

import '../../../playlists/data/xtream/xtream_array_loader.dart';
import '../../domain/live_channel.dart';
import '../../domain/live_tv_repository.dart';
import 'xtream_live_parsing.dart';

/// Downloads and parses `get_live_streams` in a background isolate and emits
/// the channels in batches (DATA-1).
Stream<List<LiveChannel>> loadXtreamLiveStreams(
  PlaylistAccess access, {
  int batchSize = 500,
  http.Client Function() clientFactory = http.Client.new,
}) {
  final playlistId = access.playlistId;
  return loadXtreamArray(
    access,
    'get_live_streams',
    parse: (json, position) =>
        parseLiveStream(json, playlistId: playlistId, position: position),
    batchSize: batchSize,
    clientFactory: clientFactory,
  );
}
