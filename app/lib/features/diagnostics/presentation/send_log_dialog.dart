import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_text_field.dart';
import '../application/log_report_actions.dart';

Future<void> showSendLogDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const _SendLogDialog(),
);

enum _Stage { editing, sending, sent, failed }

/// Asks the tester what happened and sends the diagnostic report.
class _SendLogDialog extends ConsumerStatefulWidget {
  const _SendLogDialog();

  @override
  ConsumerState<_SendLogDialog> createState() => _SendLogDialogState();
}

class _SendLogDialogState extends ConsumerState<_SendLogDialog> {
  final _description = TextEditingController();
  var _stage = _Stage.editing;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _stage = _Stage.sending);
    try {
      await ref.read(logReportActionsProvider).send(_description.text);
      if (mounted) setState(() => _stage = _Stage.sent);
    } on Exception catch (error) {
      debugPrint('log report failed: $error');
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final close = TvButton(
      label: l10n.commonDone,
      autofocus: true,
      onPressed: () => Navigator.of(context).pop(),
    );
    return Dialog(
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.settingsSendLog, style: textTheme.headlineSmall),
              const SizedBox(height: 16),
              ...switch (_stage) {
                _Stage.editing => [
                  Text(l10n.sendLogPrivacy, style: textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  TvTextField(
                    controller: _description,
                    label: l10n.sendLogDescription,
                    helperText: l10n.sendLogHint,
                    maxLength: 500,
                    autofocus: true,
                    onSubmitted: (_) => _send(),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      TvButton(
                        label: l10n.commonCancel,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TvButton(
                        label: l10n.sendLogSend,
                        icon: Icons.send,
                        style: TvButtonStyle.primary,
                        onPressed: _send,
                      ),
                    ],
                  ),
                ],
                _Stage.sending => [
                  Row(
                    children: [
                      const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(width: 16),
                      Text(l10n.sendLogSending, style: textTheme.bodyMedium),
                    ],
                  ),
                ],
                _Stage.sent => [
                  Text(l10n.sendLogSent, style: textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerRight, child: close),
                ],
                _Stage.failed => [
                  Text(l10n.sendLogFailed, style: textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerRight, child: close),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }
}
