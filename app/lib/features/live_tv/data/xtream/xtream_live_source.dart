import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../playlists/data/xtream/xtream_api_client.dart';
import '../../domain/live_channel.dart';
import '../../domain/live_tv_repository.dart';
import 'xtream_live_loader.dart';
import 'xtream_live_parsing.dart';

class XtreamLiveSource implements LiveCatalogSource {
  XtreamLiveSource(
    this._client, {
    http.Client Function() clientFactory = http.Client.new,
    DateTime Function()? clock,
    // Named parameters cannot be private, so no initializing formal.
    // ignore: prefer_initializing_formals
  }) : _clientFactory = clientFactory,
       _clock = clock ?? DateTime.now;

  final XtreamApiClient _client;
  final http.Client Function() _clientFactory;
  final DateTime Function() _clock;

  @override
  Future<List<LiveCategory>> fetchCategories(PlaylistAccess access) async {
    final Object? body;
    try {
      body = await _client.getJson(
        serverUrl: access.serverUrl,
        username: access.username,
        password: access.password,
        parameters: const {'action': 'get_live_categories'},
      );
    } on XtreamUnauthorizedException {
      throw const CatalogLoadException(CatalogLoadFailure.unauthorized);
    } on XtreamFormatException catch (error) {
      throw CatalogLoadException(
        CatalogLoadFailure.invalidResponse,
        error.message,
      );
    } on TimeoutException {
      throw const CatalogLoadException(CatalogLoadFailure.unreachable);
    } on http.ClientException catch (error) {
      throw CatalogLoadException(CatalogLoadFailure.unreachable, error.message);
    }

    if (body is Map) {
      // Rejected credentials return the account object instead of a list.
      throw const CatalogLoadException(CatalogLoadFailure.unauthorized);
    }
    if (body is! List) {
      throw const CatalogLoadException(CatalogLoadFailure.invalidResponse);
    }
    return [
      for (final item in body)
        if (item is Map<String, Object?>) ?parseLiveCategory(item),
    ];
  }

  @override
  Stream<List<LiveChannel>> fetchChannels(PlaylistAccess access) =>
      loadXtreamLiveStreams(access, clientFactory: _clientFactory);

  @override
  Future<NowNext> fetchNowNext(
    PlaylistAccess access,
    LiveChannel channel,
  ) async {
    try {
      final body = await _client.getJson(
        serverUrl: access.serverUrl,
        username: access.username,
        password: access.password,
        parameters: {
          'action': 'get_short_epg',
          'stream_id': '${channel.streamId}',
          'limit': '4',
        },
      );
      return parseShortEpg(body, now: _clock().toUtc());
    } on Exception {
      // Programme information is optional; the channel still plays.
      return NowNext.empty;
    }
  }

  @override
  String streamUrl(PlaylistAccess access, LiveChannel channel) {
    final user = Uri.encodeComponent(access.username);
    final password = Uri.encodeComponent(access.password);
    return '${access.serverUrl}/live/$user/$password/${channel.streamId}.ts';
  }
}
