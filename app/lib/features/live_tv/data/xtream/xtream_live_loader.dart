import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../../core/data/isolate_stream.dart';
import '../../../../core/data/json_array_splitter.dart';
import '../../../playlists/data/xtream/xtream_api_client.dart';
import '../../domain/live_channel.dart';
import '../../domain/live_tv_repository.dart';
import 'xtream_live_parsing.dart';

/// Downloads and parses `get_live_streams` in a background isolate and emits
/// the channels in batches (DATA-1). Cancelling the subscription stops the
/// isolate and the download.
Stream<List<LiveChannel>> loadXtreamLiveStreams(
  PlaylistAccess access, {
  int batchSize = 500,
  http.Client Function() clientFactory = http.Client.new,
}) =>
    streamFromIsolate(
      () => _load(access, batchSize, clientFactory()),
      debugName: 'live-catalog-loader',
    ).handleError(
      (Object error) => throw CatalogLoadException(
        CatalogLoadFailure.invalidResponse,
        '$error',
      ),
      test: (error) => error is! CatalogLoadException,
    );

Stream<List<LiveChannel>> _load(
  PlaylistAccess access,
  int batchSize,
  http.Client client,
) async* {
  try {
    final httpRequest = http.Request(
      'GET',
      XtreamApiClient.apiUri(
        access.serverUrl,
        access.username,
        access.password,
        const {'action': 'get_live_streams'},
      ),
    )..headers.addAll(XtreamApiClient.headers);

    final response = await client
        .send(httpRequest)
        .timeout(const Duration(seconds: 30));
    XtreamApiClient.checkStatus(response.statusCode);

    var batch = <LiveChannel>[];
    var position = 0;
    await for (final json in response.stream.transform(
      const JsonArraySplitter(),
    )) {
      final channel = parseLiveStream(
        json,
        playlistId: access.playlistId,
        position: position++,
      );
      if (channel == null) continue;
      batch.add(channel);
      if (batch.length >= batchSize) {
        yield batch;
        batch = [];
      }
    }
    if (batch.isNotEmpty) yield batch;
  } on XtreamUnauthorizedException {
    throw const CatalogLoadException(CatalogLoadFailure.unauthorized);
  } on FormatException catch (error) {
    // An object instead of an array usually means rejected credentials.
    throw CatalogLoadException(
      CatalogLoadFailure.invalidResponse,
      error.message,
    );
  } on XtreamFormatException catch (error) {
    throw CatalogLoadException(
      CatalogLoadFailure.invalidResponse,
      error.message,
    );
  } on TimeoutException {
    throw const CatalogLoadException(CatalogLoadFailure.unreachable, 'timeout');
  } on http.ClientException catch (error) {
    throw CatalogLoadException(CatalogLoadFailure.unreachable, error.message);
  } finally {
    client.close();
  }
}
