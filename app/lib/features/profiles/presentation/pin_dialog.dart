import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_focusable.dart';

/// Checks an entered PIN. Returns an error message to show, or null to accept.
typedef PinValidator = Future<String?> Function(String pin);

const _pinLength = 4;

/// Shows a PIN pad operable with the D-pad, number keys and touch. Returns the
/// accepted PIN or null when the dialog is dismissed.
Future<String?> showPinDialog(
  BuildContext context, {
  required String title,
  PinValidator? validate,
}) => showDialog<String>(
  context: context,
  builder: (context) => _PinDialog(title: title, validate: validate),
);

/// Asks for a new PIN twice. Returns the PIN or null when cancelled.
Future<String?> showNewPinDialogs(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final first = await showPinDialog(context, title: l10n.profilePinNew);
  if (first == null || !context.mounted) return null;
  return showPinDialog(
    context,
    title: l10n.profilePinConfirm,
    validate: (pin) async => pin == first ? null : l10n.profilePinMismatch,
  );
}

class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.title, this.validate});

  final String title;
  final PinValidator? validate;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  String _pin = '';
  String? _error;
  bool _checking = false;

  Future<void> _add(String digit) async {
    if (_checking || _pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length < _pinLength) return;

    final validate = widget.validate;
    if (validate == null) {
      Navigator.of(context).pop(_pin);
      return;
    }
    setState(() => _checking = true);
    final error = await validate(_pin);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(_pin);
    } else {
      setState(() {
        _error = error;
        _pin = '';
        _checking = false;
      });
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _clear() => setState(() => _pin = '');

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _backspace();
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character != null && RegExp(r'^\d$').hasMatch(character)) {
      _add(character);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.surface,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _handleKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _PinDots(filled: _pin.length),
              SizedBox(
                height: 24,
                child: _error == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _error!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              for (final row in const [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
              ])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final digit in row)
                      _PadKey(
                        autofocus: digit == '1',
                        onSelect: () => _add(digit),
                        child: Text(digit, style: textTheme.headlineSmall),
                      ),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PadKey(
                    onSelect: _clear,
                    child: Text(
                      l10n.profilePinClear,
                      style: textTheme.bodySmall,
                    ),
                  ),
                  _PadKey(
                    onSelect: () => _add('0'),
                    child: Text('0', style: textTheme.headlineSmall),
                  ),
                  _PadKey(
                    onSelect: _backspace,
                    child: Icon(
                      Icons.backspace_outlined,
                      semanticLabel: l10n.profilePinBackspace,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _pinLength; i++)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? AppColors.textPrimary : null,
              border: Border.all(color: AppColors.textSecondary, width: 2),
            ),
          ),
      ],
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({
    required this.onSelect,
    required this.child,
    this.autofocus = false,
  });

  final VoidCallback onSelect;
  final Widget child;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      onSelect: onSelect,
      builder: (context, focused) => Container(
        width: 64,
        height: 52,
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: focused ? AppColors.focusFill : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: child,
      ),
    );
  }
}
