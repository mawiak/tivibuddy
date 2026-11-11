import 'package:flutter/material.dart';

import '../domain/profile.dart';
import 'avatar_presets.dart';

class ProfileAvatarView extends StatelessWidget {
  const ProfileAvatarView({
    super.key,
    required this.avatar,
    required this.size,
  });

  final ProfileAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.12);
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: radius,
        child: switch (avatar) {
          PresetAvatar(:final index) => _PresetView(
            preset: avatarPresetAt(index),
            size: size,
          ),
          ImageAvatar(:final pngBytes) => Image.memory(
            pngBytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // Decode at display size to keep memory low (RES-2).
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
          ),
        },
      ),
    );
  }
}

class _PresetView extends StatelessWidget {
  const _PresetView({required this.preset, required this.size});

  final AvatarPreset preset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(preset.color, Colors.white, 0.15)!,
            Color.lerp(preset.color, Colors.black, 0.25)!,
          ],
        ),
      ),
      child: Center(
        child: Icon(preset.icon, size: size * 0.55, color: Colors.white),
      ),
    );
  }
}
