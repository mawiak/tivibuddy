abstract final class AppRoutes {
  static const startup = '/startup';
  static const home = '/';
  static const profiles = '/profiles';
  static const newProfile = '/profiles/new';

  static String editProfile(String id) => '/profiles/$id/edit';
}
