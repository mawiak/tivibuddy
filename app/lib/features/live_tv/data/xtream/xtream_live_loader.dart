import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
}) {
  final request = _LoadRequest(access, batchSize);
  // The web has no isolates; parsing there runs on the UI thread.
  if (kIsWeb) return _load(request, clientFactory());
  return _loadInIsolate(request, clientFactory);
}

Stream<List<LiveChannel>> _loadInIsolate(
  _LoadRequest request,
  http.Client Function() clientFactory,
) async* {
  final port = ReceivePort();
  // Crashes and exits of the isolate arrive on the same port, so a loader
  // that dies unexpectedly ends the stream with an error instead of leaving
  // the caller waiting forever.
  final isolate = await Isolate.spawn(
    _isolateMain,
    (port.sendPort, request, clientFactory),
    debugName: 'live-catalog-loader',
    onError: port.sendPort,
    onExit: port.sendPort,
  );
  try {
    await for (final message in port) {
      switch (message) {
        case final List<LiveChannel> batch:
          yield batch;
        case final CatalogLoadException error:
          throw error;
        case _Done():
          return;
        case [final Object? error, _]:
          throw CatalogLoadException(
            CatalogLoadFailure.invalidResponse,
            '$error',
          );
        case null:
          throw const CatalogLoadException(
            CatalogLoadFailure.invalidResponse,
            'Loader stopped unexpectedly',
          );
      }
    }
  } finally {
    port.close();
    isolate.kill(priority: Isolate.immediate);
  }
}

Future<void> _isolateMain(
  (SendPort, _LoadRequest, http.Client Function()) args,
) async {
  final (port, request, clientFactory) = args;
  try {
    await for (final batch in _load(request, clientFactory())) {
      port.send(batch);
    }
    port.send(const _Done());
  } on CatalogLoadException catch (error) {
    port.send(error);
  }
}

Stream<List<LiveChannel>> _load(
  _LoadRequest request,
  http.Client client,
) async* {
  final access = request.access;
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
      if (batch.length >= request.batchSize) {
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

final class _LoadRequest {
  const _LoadRequest(this.access, this.batchSize);

  final PlaylistAccess access;
  final int batchSize;
}

final class _Done {
  const _Done();
}
