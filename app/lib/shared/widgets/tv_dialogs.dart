import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'tv_button.dart';
import 'tv_list_tile.dart';

/// Asks for confirmation. Focus starts on cancel, so a destructive action
/// is never triggered by an accidental double press of select.
Future<bool> showTvConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return _TvDialog(
        title: title,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 12,
            children: [
              TvButton(
                label: l10n.commonCancel,
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TvButton(
                label: confirmLabel,
                style: destructive
                    ? TvButtonStyle.danger
                    : TvButtonStyle.primary,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

class TvChoice<T> {
  const TvChoice(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Shows a list of options and returns the selected value, or null.
Future<T?> showTvChoiceDialog<T>(
  BuildContext context, {
  required String title,
  String? message,
  required List<TvChoice<T>> choices,
}) => showDialog<T>(
  context: context,
  builder: (context) => _TvDialog(
    title: title,
    children: [
      if (message != null) ...[
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
      ],
      for (final (index, choice) in choices.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TvListTile(
            title: choice.label,
            leading: choice.icon,
            autofocus: index == 0,
            onSelect: () => Navigator.of(context).pop(choice.value),
          ),
        ),
    ],
  ),
);

/// Shows options that are switched on and off independently. Every change
/// is reported through [onChanged] right away; back closes the dialog.
Future<void> showTvToggleDialog<T>(
  BuildContext context, {
  required String title,
  String? message,
  required List<TvChoice<T>> choices,
  required Set<T> selected,
  required ValueChanged<Set<T>> onChanged,
}) => showDialog<void>(
  context: context,
  builder: (context) {
    var current = {...selected};
    return StatefulBuilder(
      builder: (context, setState) => _TvDialog(
        title: title,
        children: [
          if (message != null) ...[
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
          ],
          for (final (index, choice) in choices.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TvSwitchTile(
                title: choice.label,
                leading: choice.icon,
                autofocus: index == 0,
                value: current.contains(choice.value),
                onChanged: (on) {
                  setState(() {
                    current = on
                        ? {...current, choice.value}
                        : ({...current}..remove(choice.value));
                  });
                  onChanged(current);
                },
              ),
            ),
        ],
      ),
    );
  },
);

class _TvDialog extends StatelessWidget {
  const _TvDialog({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
