import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' show XmlException;
import 'package:xml/xml_events.dart';

import '../../../../core/data/isolate_stream.dart';
import '../../../playlists/data/xtream/xtream_api_client.dart';
import '../../domain/live_channel.dart';
import '../../domain/live_tv_repository.dart';
import 'xmltv_reader.dart';

/// Downloads an XMLTV guide and parses it in a background isolate, emitting
/// programmes in batches (DATA-1). Guides can be hundreds of megabytes, so
/// the document is never held in memory as a whole.
Stream<List<EpgProgramme>> loadXmltv(
  Uri uri, {
  required Set<String> channelKeys,
  required DateTime from,
  required DateTime to,
  int batchSize = 1000,
  http.Client Function() clientFactory = http.Client.new,
}) =>
    streamFromIsolate(
      () => _load(
        uri,
        XmltvReader(channelKeys: channelKeys, from: from, to: to),
        batchSize,
        clientFactory(),
      ),
      debugName: 'xmltv-loader',
    ).handleError(
      (Object error) => throw CatalogLoadException(
        CatalogLoadFailure.invalidResponse,
        '$error',
      ),
      test: (error) => error is! CatalogLoadException,
    );

Stream<List<EpgProgramme>> _load(
  Uri uri,
  XmltvReader reader,
  int batchSize,
  http.Client client,
) async* {
  try {
    final request = http.Request('GET', uri)
      ..headers.addAll(XtreamApiClient.headers);
    final response = await client
        .send(request)
        .timeout(const Duration(seconds: 30));
    XtreamApiClient.checkStatus(response.statusCode);

    var batch = <EpgProgramme>[];
    await for (final events
        in response.stream
            .transform(const Utf8Decoder(allowMalformed: true))
            .toXmlEvents()) {
      batch.addAll(reader.read(events));
      if (batch.length >= batchSize) {
        yield batch;
        batch = [];
      }
    }
    if (batch.isNotEmpty) yield batch;
  } on XtreamUnauthorizedException {
    throw const CatalogLoadException(CatalogLoadFailure.unauthorized);
  } on XtreamFormatException catch (error) {
    throw CatalogLoadException(
      CatalogLoadFailure.invalidResponse,
      error.message,
    );
  } on XmlException catch (error) {
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
