import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_text_field.dart';
import '../../profiles/application/profile_providers.dart';
import '../application/playlist_actions.dart';
import '../domain/connection_test.dart';
import '../domain/playlist.dart';
import 'account_info_text.dart';

/// Creates a playlist when [playlistId] is null, otherwise edits it (PL-2).
class PlaylistEditScreen extends ConsumerStatefulWidget {
  const PlaylistEditScreen({super.key, this.playlistId});

  final String? playlistId;

  @override
  ConsumerState<PlaylistEditScreen> createState() => _PlaylistEditScreenState();
}

class _PlaylistEditScreenState extends ConsumerState<PlaylistEditScreen> {
  final _name = TextEditingController();
  final _server = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  late final Future<PlaylistFormData> _form;

  Set<PlaylistInputError> _errors = const {};
  AccountInfo? _account;
  ConnectionResult? _lastResult;
  bool _linkDetected = false;
  bool _busy = false;

  bool get _isNew => widget.playlistId == null;

  PlaylistInput get _input => PlaylistInput(
    name: _name.text,
    serverUrl: _server.text,
    username: _username.text,
    password: _password.text,
  );

  @override
  void initState() {
    super.initState();
    _form = ref.read(playlistActionsProvider).loadForm(widget.playlistId)
      ..then((data) {
        if (!mounted) return;
        setState(() {
          _name.text = data.name;
          _server.text = data.serverUrl;
          _username.text = data.username;
          _password.text = data.password;
          _account = data.account;
        });
      }).ignore();
  }

  @override
  void dispose() {
    for (final controller in [_name, _server, _username, _password]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Splits a pasted full playlist link into its parts.
  void _onServerChanged(String value) {
    final link = parseXtreamLink(value);
    if (link == null) return;
    setState(() {
      _server.text = link.serverUrl;
      _username.text = link.username;
      _password.text = link.password;
      _linkDetected = true;
    });
    _suggestName();
  }

  void _suggestName() {
    if (_name.text.trim().isNotEmpty) return;
    final server = normalizeServerUrl(_server.text);
    if (server != null) _name.text = Uri.parse(server).host;
  }

  bool _validate({bool requireName = true}) {
    _suggestName();
    final errors = validatePlaylistInput(_input);
    if (!requireName) errors.remove(PlaylistInputError.nameEmpty);
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<ConnectionResult?> _runTest() async {
    setState(() {
      _busy = true;
      _lastResult = null;
    });
    final result = await ref
        .read(playlistActionsProvider)
        .testConnection(_input);
    if (!mounted) return null;
    setState(() {
      _busy = false;
      _lastResult = result;
      if (result is ConnectionOk) _account = result.account;
    });
    return result;
  }

  Future<void> _test() async {
    if (_validate(requireName: false)) await _runTest();
  }

  Future<void> _save() async {
    if (!_validate()) return;
    final result = await _runTest();
    if (result == null || !mounted) return;

    if (result is! ConnectionOk) {
      final l10n = AppLocalizations.of(context);
      final saveAnyway = await showTvConfirmDialog(
        context,
        title: l10n.playlistSaveAnywayTitle,
        message: l10n.playlistSaveAnywayMessage(
          describeConnectionError(l10n, result),
        ),
        confirmLabel: l10n.playlistSaveAnyway,
      );
      if (!saveAnyway || !mounted) return;
    }

    final profileId = ref.read(activeProfileIdProvider);
    if (profileId == null) return;
    setState(() => _busy = true);
    await ref
        .read(playlistActionsProvider)
        .save(
          id: widget.playlistId,
          profileId: profileId,
          input: _input,
          account: result is ConnectionOk ? result.account : null,
        );
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showTvConfirmDialog(
      context,
      title: l10n.playlistDeleteTitle,
      message: l10n.playlistDeleteMessage(_name.text),
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await ref.read(playlistActionsProvider).delete(widget.playlistId!);
    if (mounted) context.pop();
  }

  String? _error(AppLocalizations l10n, PlaylistInputError error) {
    if (!_errors.contains(error)) return null;
    return switch (error) {
      PlaylistInputError.nameEmpty => l10n.playlistErrorNameEmpty,
      PlaylistInputError.nameTooLong => l10n.playlistErrorNameTooLong(
        Playlist.maxNameLength,
      ),
      PlaylistInputError.serverInvalid => l10n.playlistErrorServer,
      PlaylistInputError.usernameEmpty => l10n.playlistErrorUsername,
      PlaylistInputError.passwordEmpty => l10n.playlistErrorPassword,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<PlaylistFormData>(
          future: _form,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: FocusTraversalGroup(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        _isNew
                            ? l10n.playlistCreateTitle
                            : l10n.playlistEditTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TvTextField(
                        controller: _server,
                        label: l10n.playlistServer,
                        helperText: _linkDetected
                            ? l10n.playlistLinkDetected
                            : l10n.playlistServerHint,
                        errorText: _error(
                          l10n,
                          PlaylistInputError.serverInvalid,
                        ),
                        keyboardType: TextInputType.url,
                        autofocus: _isNew,
                        onChanged: _onServerChanged,
                        onSubmitted: (_) => _suggestName(),
                      ),
                      const SizedBox(height: 12),
                      TvTextField(
                        controller: _username,
                        label: l10n.playlistUsername,
                        errorText: _error(
                          l10n,
                          PlaylistInputError.usernameEmpty,
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 12),
                      TvTextField(
                        controller: _password,
                        label: l10n.playlistPassword,
                        errorText: _error(
                          l10n,
                          PlaylistInputError.passwordEmpty,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      TvTextField(
                        controller: _name,
                        label: l10n.playlistName,
                        maxLength: Playlist.maxNameLength,
                        errorText:
                            _error(l10n, PlaylistInputError.nameEmpty) ??
                            _error(l10n, PlaylistInputError.nameTooLong),
                      ),
                      const SizedBox(height: 16),
                      _ConnectionStatus(
                        busy: _busy,
                        result: _lastResult,
                        account: _account,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          TvButton(
                            label: l10n.commonSave,
                            icon: Icons.check,
                            style: TvButtonStyle.primary,
                            autofocus: !_isNew,
                            onPressed: _busy ? null : _save,
                          ),
                          TvButton(
                            label: l10n.playlistTestConnection,
                            icon: Icons.wifi_tethering,
                            onPressed: _busy ? null : _test,
                          ),
                          TvButton(
                            label: l10n.commonCancel,
                            onPressed: () => context.pop(),
                          ),
                          if (!_isNew)
                            TvButton(
                              label: l10n.commonDelete,
                              icon: Icons.delete_outline,
                              style: TvButtonStyle.danger,
                              onPressed: _busy ? null : _delete,
                            ),
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
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus({
    required this.busy,
    required this.result,
    required this.account,
  });

  final bool busy;
  final ConnectionResult? result;
  final AccountInfo? account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final result = this.result;

    final (IconData icon, Color color, String text) = switch (result) {
      _ when busy => (
        Icons.hourglass_top,
        AppColors.textSecondary,
        l10n.playlistTesting,
      ),
      ConnectionOk() => (
        Icons.check_circle,
        AppColors.success,
        l10n.playlistTestOk,
      ),
      null => (
        Icons.info_outline,
        AppColors.textSecondary,
        describeAccount(context, account),
      ),
      _ => (
        Icons.error_outline,
        AppColors.danger,
        describeConnectionError(l10n, result),
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (busy)
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: textTheme.bodyMedium?.copyWith(color: color)),
                if (result is ConnectionOk)
                  Text(
                    describeAccount(context, result.account),
                    style: textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
