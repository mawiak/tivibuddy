abstract final class AppRoutes {
  static const startup = '/startup';
  static const home = '/';
  static const profiles = '/profiles';
  static const newProfile = '/profiles/new';

  static String editProfile(String id) => '/profiles/$id/edit';

  static const livePlayer = '/live/play';
  static const movieDetail = '/movies/detail';
  static const seriesDetail = '/series/detail';
  static const vodPlayer = '/vod/play';
  static const about = '/settings/about';
  static const playlists = '/settings/playlists';
  static const newPlaylist = '/settings/playlists/new';

  static String editPlaylist(String id) => '/settings/playlists/$id/edit';
}
