import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../domain/connection_test.dart';
import '../domain/credential_store.dart';
import '../domain/playlist.dart';
import '../domain/playlist_repository.dart';
import 'drift_playlist_repository.dart';
import 'secure_credential_store.dart';
import 'xtream/xtream_api_client.dart';
import 'xtream/xtream_connection_tester.dart';

part 'playlist_data_providers.g.dart';

@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
PlaylistRepository playlistRepository(Ref ref) =>
    DriftPlaylistRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
CredentialStore credentialStore(Ref ref) => SecureCredentialStore();

@Riverpod(keepAlive: true)
XtreamApiClient xtreamApiClient(Ref ref) =>
    XtreamApiClient(ref.watch(httpClientProvider));

/// Connection tester for each source type (PL-3).
@Riverpod(keepAlive: true)
ConnectionTester connectionTester(Ref ref, PlaylistType type) => switch (type) {
  PlaylistType.xtream => XtreamConnectionTester(
    ref.watch(xtreamApiClientProvider),
  ),
};
