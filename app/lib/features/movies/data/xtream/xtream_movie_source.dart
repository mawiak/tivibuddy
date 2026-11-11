import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../playlists/data/xtream/xtream_api_client.dart';
import '../../../playlists/data/xtream/xtream_array_loader.dart';
import '../../../playlists/domain/catalog_access.dart';
import '../../domain/movie.dart';
import '../../domain/movie_repository.dart';
import 'xtream_movie_parsing.dart';

class XtreamMovieSource implements MovieCatalogSource {
  XtreamMovieSource(
    this._client, {
    http.Client Function() clientFactory = http.Client.new,
    // Named parameters cannot be private, so no initializing formal.
    // ignore: prefer_initializing_formals
  }) : _clientFactory = clientFactory;

  final XtreamApiClient _client;
  final http.Client Function() _clientFactory;

  Future<Object?> _get(
    PlaylistAccess access,
    Map<String, String> parameters,
  ) async {
    try {
      return await _client.getJson(
        serverUrl: access.serverUrl,
        username: access.username,
        password: access.password,
        parameters: parameters,
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
  }

  @override
  Future<List<MovieCategory>> fetchCategories(PlaylistAccess access) async {
    final body = await _get(access, const {'action': 'get_vod_categories'});
    if (body is Map) {
      // Rejected credentials return the account object instead of a list.
      throw const CatalogLoadException(CatalogLoadFailure.unauthorized);
    }
    if (body is! List) {
      throw const CatalogLoadException(CatalogLoadFailure.invalidResponse);
    }
    return [
      for (final item in body)
        if (item is Map<String, Object?>) ?parseMovieCategory(item),
    ];
  }

  @override
  Stream<List<Movie>> fetchMovies(PlaylistAccess access) {
    final playlistId = access.playlistId;
    return loadXtreamArray(
      access,
      'get_vod_streams',
      parse: (json, position) =>
          parseMovie(json, playlistId: playlistId, position: position),
      clientFactory: _clientFactory,
    );
  }

  @override
  Future<MovieDetails> fetchDetails(PlaylistAccess access, Movie movie) async {
    final body = await _get(access, {
      'action': 'get_vod_info',
      'vod_id': '${movie.streamId}',
    });
    return parseMovieDetails(body);
  }

  @override
  String streamUrl(
    PlaylistAccess access,
    Movie movie, {
    String? containerExtension,
  }) {
    final user = Uri.encodeComponent(access.username);
    final password = Uri.encodeComponent(access.password);
    final extension = containerExtension ?? movie.containerExtension ?? 'mp4';
    return '${access.serverUrl}/movie/$user/$password/'
        '${movie.streamId}.$extension';
  }
}
