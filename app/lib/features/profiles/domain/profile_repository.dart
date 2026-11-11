import 'profile.dart';

abstract interface class ProfileRepository {
  /// All profiles that are not deleted, in display order.
  Stream<List<Profile>> watchAll();

  Future<List<Profile>> getAll();

  Future<Profile?> findById(String id);

  Future<Profile> create({
    required String name,
    required ProfileAvatar avatar,
    String? pin,
  });

  Future<void> update(
    String id, {
    required String name,
    required ProfileAvatar avatar,
  });

  /// Sets a new PIN, or removes it when [pin] is null.
  Future<void> setPin(String id, String? pin);

  Future<bool> verifyPin(String id, String pin);

  Future<void> delete(String id);
}
