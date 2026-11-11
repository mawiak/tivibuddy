import 'dart:typed_data';

/// A household member using the app (PROF-1).
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.hasPin,
    required this.sortOrder,
  });

  static const maxNameLength = 24;

  final String id;
  final String name;
  final ProfileAvatar avatar;
  final bool hasPin;
  final int sortOrder;
}

sealed class ProfileAvatar {
  const ProfileAvatar();
}

/// One of the bundled avatars, identified by its index in the avatar set.
final class PresetAvatar extends ProfileAvatar {
  const PresetAvatar(this.index);

  final int index;

  @override
  bool operator ==(Object other) =>
      other is PresetAvatar && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// A user-provided image, already scaled down and encoded as PNG.
final class ImageAvatar extends ProfileAvatar {
  const ImageAvatar(this.pngBytes);

  final Uint8List pngBytes;
}

enum ProfileNameError { empty, tooLong }

/// Returns null when [name] is valid.
ProfileNameError? validateProfileName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return ProfileNameError.empty;
  if (trimmed.length > Profile.maxNameLength) return ProfileNameError.tooLong;
  return null;
}

/// A profile PIN consists of exactly four digits (PROF-4).
bool isValidPin(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);
