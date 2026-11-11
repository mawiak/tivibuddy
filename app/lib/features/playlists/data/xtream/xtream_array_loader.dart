import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../../core/data/isolate_stream.dart';
import '../../../../core/data/json_array_splitter.dart';
import '../../domain/catalog_access.dart';
import 'xtream_api_client.dart';

/// Parses one entry of a list response; null skips the entry. [position] is
/// the index in the provider list.
typedef XtreamEntryParser<T> = T? Function(
  Map<String, Object?> json,
  int position,
);

/// Downloads a list response of the Xtream API (for example
/// `get_live_streams` or `get_vod_streams`, often tens of megabytes) and
/// parses it in a background isolate, one entry at a time, emitting batches
/// (DATA-1). Cancelling the subscription stops the isolate and the download.
///
/// [parse] runs in the isolate, so it must be a top-level function or a
/// closure over sendable values.
Stream<List<T>> loadXtreamArray<T>(
  PlaylistAccess access,
  String action, {
  required XtreamEntryParser<T> parse,
  int batchSize = 500,
  http.Client Function() clientFactory = http.Client.new,
}) =>
    streamFromIsolate(
      () => _load(access, action, parse, batchSize, clientFactory()),
      debugName: 'xtream-$action',
    ).handleError(
      (Object error) => throw CatalogLoadException(
        CatalogLoadFailure.invalidResponse,
        '$error',
      ),
      test: (error) => error is! CatalogLoadException,
    );

Stream<List<T>> _load<T>(
  PlaylistAccess access,
  String action,
  XtreamEntryParser<T> parse,
  int batchSize,
  http.Client client,
) async* {
  try {
    final request = http.Request(
      'GET',
      XtreamApiClient.apiUri(
        access.serverUrl,
        access.username,
        access.password,
        {'action': action},
      ),
    )..headers.addAll(XtreamApiClient.headers);

    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 30));
    XtreamApiClient.checkStatus(response.statusCode);

    var batch = <T>[];
    var position = 0;
    await for (final json in response.stream.transform(
      const JsonArraySplitter(),
    )) {
      final entry = parse(json, position++);
      if (entry == null) continue;
      batch.add(entry);
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
