import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../playlists/data/playlist_data_providers.dart';
import '../domain/update_source.dart';
import 'android_update_installer.dart';
import 'github_update_source.dart';

part 'update_data_providers.g.dart';

@Riverpod(keepAlive: true)
UpdateSource updateSource(Ref ref) =>
    GitHubUpdateSource(ref.watch(httpClientProvider));

@Riverpod(keepAlive: true)
UpdateInstaller updateInstaller(Ref ref) =>
    AndroidUpdateInstaller(ref.watch(httpClientProvider));
