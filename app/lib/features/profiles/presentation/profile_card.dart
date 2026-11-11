import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../domain/profile.dart';
import 'profile_avatar_view.dart';

/// Avatar with name as shown in the profile picker.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.label,
    required this.onSelect,
    this.avatar,
    this.icon,
    this.badge,
    this.size = 112,
    this.autofocus = false,
  }) : assert(avatar != null || icon != null);

  final String label;
  final VoidCallback onSelect;

  /// Shown as picture. When null, [icon] is shown on a neutral tile.
  final ProfileAvatar? avatar;
  final IconData? icon;

  /// Small icon in the corner, for example a lock or an edit marker.
  final IconData? badge;
  final double size;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      onSelect: onSelect,
      builder: (context, focused) => SizedBox(
        width: size + 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: focused ? 1.08 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.12 + 3),
                  border: Border.all(
                    color: focused ? AppColors.focusBorder : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    if (avatar != null)
                      ProfileAvatarView(avatar: avatar!, size: size)
                    else
                      _IconTile(icon: icon!, size: size),
                    if (badge != null)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: _Badge(icon: badge!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            MarqueeText(
              label,
              active: focused,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: focused
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(size * 0.12),
      ),
      child: Icon(icon, size: size * 0.45, color: AppColors.textSecondary),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Color(0xCC000000),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: AppColors.textPrimary),
    );
  }
}
