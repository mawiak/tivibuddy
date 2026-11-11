import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../../shared/widgets/tv_list_tile.dart';
import '../../../shared/widgets/tv_text_field.dart';
import '../application/profile_actions.dart';
import '../domain/profile.dart';
import 'avatar_picker_dialog.dart';
import 'pin_dialog.dart';
import 'profile_avatar_view.dart';

/// Creates a profile when [profileId] is null, otherwise edits it (PROF-6).
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, this.profileId});

  final String? profileId;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  late final Future<ProfileFormData> _form;

  ProfileAvatar _avatar = const PresetAvatar(0);
  bool _hadPin = false;
  PinChange _pinChange = const PinUnchanged();
  bool _startAutomatically = false;
  bool _isFirstProfile = false;
  String? _otherDefaultName;
  ProfileNameError? _nameError;
  bool _saving = false;

  bool get _isNew => widget.profileId == null;

  bool get _hasPin => switch (_pinChange) {
    PinUnchanged() => _hadPin,
    PinRemoved() => false,
    PinSet() => true,
  };

  @override
  void initState() {
    super.initState();
    _form = ref.read(profileActionsProvider).loadForm(widget.profileId)
      ..then((data) {
        if (!mounted) return;
        setState(() {
          _nameController.text = data.name;
          _avatar = data.avatar;
          _hadPin = data.hasPin;
          _startAutomatically = data.startAutomatically;
          _isFirstProfile = data.isFirstProfile;
          _otherDefaultName = data.otherDefaultProfileName;
        });
      }).ignore();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _chooseAvatar() async {
    final avatar = await showAvatarPickerDialog(context, current: _avatar);
    if (avatar != null) setState(() => _avatar = avatar);
  }

  Future<void> _editPin() async {
    final l10n = AppLocalizations.of(context);
    var setNew = !_hasPin;
    if (_hasPin) {
      final choice = await showTvChoiceDialog<bool>(
        context,
        title: l10n.profilePin,
        choices: [
          TvChoice(true, l10n.profilePinChange, icon: Icons.password),
          TvChoice(false, l10n.profilePinRemove, icon: Icons.lock_open),
        ],
      );
      if (choice == null) return;
      if (!choice) {
        setState(() => _pinChange = const PinRemoved());
        return;
      }
      setNew = true;
    }
    if (!setNew || !mounted) return;
    final pin = await showNewPinDialogs(context);
    if (pin != null) setState(() => _pinChange = PinSet(pin));
  }

  Future<void> _setStartAutomatically(bool value) async {
    final other = _otherDefaultName;
    if (value && other != null) {
      final l10n = AppLocalizations.of(context);
      final confirmed = await showTvConfirmDialog(
        context,
        title: l10n.profileReplaceDefaultTitle,
        message: l10n.profileReplaceDefaultMessage(other),
        confirmLabel: l10n.profileReplaceDefaultConfirm,
      );
      if (!confirmed) return;
    }
    if (mounted) setState(() => _startAutomatically = value);
  }

  Future<void> _save() async {
    final error = validateProfileName(_nameController.text);
    setState(() => _nameError = error);
    if (error != null) return;

    setState(() => _saving = true);
    final actions = ref.read(profileActionsProvider);
    final saved = await actions.save(
      id: widget.profileId,
      name: _nameController.text,
      avatar: _avatar,
      pinChange: _pinChange,
      startAutomatically: _startAutomatically,
    );
    if (!mounted) return;

    if (_isFirstProfile) {
      actions.activate(saved.id);
      context.go(AppRoutes.home);
    } else {
      context.pop();
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showTvConfirmDialog(
      context,
      title: l10n.profileDeleteTitle,
      message: l10n.profileDeleteMessage(_nameController.text),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(profileActionsProvider).delete(widget.profileId!);
    if (mounted) context.pop();
  }

  String? _nameErrorText(AppLocalizations l10n) => switch (_nameError) {
    null => null,
    ProfileNameError.empty => l10n.profileNameEmpty,
    ProfileNameError.tooLong => l10n.profileNameTooLong(Profile.maxNameLength),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ProfileFormData>(
          future: _form,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final title = _isFirstProfile
                ? l10n.profileFirstTitle
                : _isNew
                ? l10n.profileCreateTitle
                : l10n.profileEditTitle;
            final avatar = _AvatarButton(
              avatar: _avatar,
              label: l10n.profileAvatarChoose,
              onSelect: _chooseAvatar,
            );
            final fields = _buildFields(l10n);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.headlineSmall),
                      if (_isFirstProfile) ...[
                        const SizedBox(height: 4),
                        Text(l10n.profileFirstHint, style: textTheme.bodySmall),
                      ],
                      const SizedBox(height: 24),
                      if (ScreenClass.of(context).isPhone) ...[
                        Center(child: avatar),
                        const SizedBox(height: 24),
                        fields,
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            avatar,
                            const SizedBox(width: 32),
                            Expanded(child: fields),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFields(AppLocalizations l10n) {
    return FocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TvTextField(
            controller: _nameController,
            label: l10n.profileName,
            maxLength: Profile.maxNameLength,
            errorText: _nameErrorText(l10n),
            autofocus: _isNew,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 12),
          TvListTile(
            title: l10n.profilePin,
            subtitle: _hasPin ? l10n.profilePinOn : l10n.profilePinOff,
            leading: _hasPin ? Icons.lock : Icons.lock_open,
            onSelect: _editPin,
          ),
          const SizedBox(height: 12),
          TvSwitchTile(
            title: l10n.profileStartAutomatically,
            subtitle: l10n.profileStartAutomaticallyHint,
            leading: Icons.play_circle_outline,
            value: _startAutomatically,
            onChanged: _setStartAutomatically,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TvButton(
                label: l10n.commonSave,
                icon: Icons.check,
                style: TvButtonStyle.primary,
                autofocus: !_isNew,
                onPressed: _saving ? null : _save,
              ),
              if (!_isFirstProfile)
                TvButton(
                  label: l10n.commonCancel,
                  onPressed: _saving ? null : () => context.pop(),
                ),
              if (!_isNew)
                TvButton(
                  label: l10n.commonDelete,
                  icon: Icons.delete_outline,
                  style: TvButtonStyle.danger,
                  onPressed: _saving ? null : _delete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({
    required this.avatar,
    required this.label,
    required this.onSelect,
  });

  final ProfileAvatar avatar;
  final String label;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      onSelect: onSelect,
      builder: (context, focused) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: focused ? AppColors.focusBorder : Colors.transparent,
                width: 3,
              ),
            ),
            child: ProfileAvatarView(avatar: avatar, size: 140),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
