import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/screen_class.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../data/profile_data_providers.dart';
import '../domain/profile.dart';
import 'avatar_presets.dart';
import 'profile_avatar_view.dart';

/// Lets the user choose a bundled avatar or, outside of TV devices, an image
/// file. Returns the chosen avatar or null when dismissed.
Future<ProfileAvatar?> showAvatarPickerDialog(
  BuildContext context, {
  required ProfileAvatar current,
}) => showDialog<ProfileAvatar>(
  context: context,
  builder: (context) => _AvatarPickerDialog(current: current),
);

class _AvatarPickerDialog extends ConsumerStatefulWidget {
  const _AvatarPickerDialog({required this.current});

  final ProfileAvatar current;

  @override
  ConsumerState<_AvatarPickerDialog> createState() =>
      _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends ConsumerState<_AvatarPickerDialog> {
  bool _loadingImage = false;
  String? _error;

  int? get _currentIndex => switch (widget.current) {
    PresetAvatar(:final index) => index % avatarPresets.length,
    ImageAvatar() => null,
  };

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loadingImage = true;
      _error = null;
    });
    try {
      final bytes = await ref.read(avatarImageSourceProvider).pick();
      if (!mounted) return;
      if (bytes != null) {
        Navigator.of(context).pop(ImageAvatar(bytes));
        return;
      }
    } on Exception {
      _error = l10n.profileAvatarImageFailed;
    }
    if (mounted) setState(() => _loadingImage = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // TV devices have no usable file picker.
    final canPickFile = ScreenClass.of(context) != ScreenClass.tv;
    final initialIndex = _currentIndex ?? 0;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.profileAvatarChoose,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < avatarPresets.length; i++)
                    _AvatarOption(
                      index: i,
                      selected: i == _currentIndex,
                      autofocus: i == initialIndex,
                      onSelect: () =>
                          Navigator.of(context).pop(PresetAvatar(i)),
                    ),
                ],
              ),
              if (canPickFile) ...[
                const SizedBox(height: 20),
                TvButton(
                  label: l10n.profileAvatarFromFile,
                  icon: Icons.image_outlined,
                  onPressed: _loadingImage ? null : _pickImage,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.index,
    required this.selected,
    required this.onSelect,
    this.autofocus = false,
  });

  final int index;
  final bool selected;
  final VoidCallback onSelect;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      onSelect: onSelect,
      builder: (context, focused) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focused
                ? AppColors.focusBorder
                : selected
                ? AppColors.accent
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: ProfileAvatarView(avatar: PresetAvatar(index), size: 64),
      ),
    );
  }
}
