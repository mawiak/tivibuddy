import 'package:flutter/material.dart';

/// Bundled avatar set (PROF-3). Drawn from icons and colours instead of image
/// assets, so it costs no APK size and renders sharply at every size.
///
/// The position in [avatarPresets] is stored in the database. Only append new
/// entries, never reorder or remove existing ones.
class AvatarPreset {
  const AvatarPreset(this.icon, this.color);

  final IconData icon;
  final Color color;
}

const avatarPresets = <AvatarPreset>[
  AvatarPreset(Icons.face, Color(0xFF2F81F7)),
  AvatarPreset(Icons.pets, Color(0xFFE5534B)),
  AvatarPreset(Icons.rocket_launch, Color(0xFF8957E5)),
  AvatarPreset(Icons.star, Color(0xFFD29922)),
  AvatarPreset(Icons.sports_esports, Color(0xFF2DA44E)),
  AvatarPreset(Icons.music_note, Color(0xFFDB61A2)),
  AvatarPreset(Icons.palette, Color(0xFFF0883E)),
  AvatarPreset(Icons.local_florist, Color(0xFF1F9E89)),
  AvatarPreset(Icons.sports_soccer, Color(0xFF3B5BDB)),
  AvatarPreset(Icons.movie, Color(0xFFB62324)),
  AvatarPreset(Icons.emoji_nature, Color(0xFF6E7781)),
  AvatarPreset(Icons.cake, Color(0xFFBF8700)),
];

AvatarPreset avatarPresetAt(int index) =>
    avatarPresets[index % avatarPresets.length];
