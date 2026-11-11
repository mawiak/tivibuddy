import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'tv_focusable.dart';

/// Text input that works with a remote control.
///
/// A plain [TextField] swallows the D-pad keys and opens the keyboard as soon
/// as it receives focus, which traps the user. This field is focused like any
/// other element and only starts editing (and shows the keyboard) after
/// select is pressed. Up/down, submit or leaving the field end editing.
class TvTextField extends StatefulWidget {
  const TvTextField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.helperText,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final String? helperText;
  final int? maxLength;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<TvTextField> createState() => _TvTextFieldState();
}

class _TvTextFieldState extends State<TvTextField> {
  final _outerFocus = FocusNode(debugLabel: 'TvTextField');
  late final _inputFocus = FocusNode(
    debugLabel: 'TvTextField.input',
    skipTraversal: true,
    canRequestFocus: false,
    onKeyEvent: _handleInputKey,
  );
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(() {
      if (!_inputFocus.hasFocus && _editing) _setEditing(false);
    });
  }

  @override
  void dispose() {
    _outerFocus.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _setEditing(bool editing) {
    setState(() => _editing = editing);
    _inputFocus.canRequestFocus = editing;
  }

  void _startEditing() {
    _setEditing(true);
    _inputFocus.requestFocus();
  }

  void _stopEditing({TraversalDirection? moveFocus}) {
    _setEditing(false);
    _outerFocus.requestFocus();
    if (moveFocus != null) _outerFocus.focusInDirection(moveFocus);
  }

  KeyEventResult _handleInputKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => TraversalDirection.up,
      LogicalKeyboardKey.arrowDown => TraversalDirection.down,
      _ => null,
    };
    if (direction == null) return KeyEventResult.ignored;
    _stopEditing(moveFocus: direction);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      focusNode: _outerFocus,
      autofocus: widget.autofocus,
      onSelect: _startEditing,
      builder: (context, focused) {
        final highlighted = focused || _editing;
        return IgnorePointer(
          ignoring: !_editing,
          child: TextField(
            controller: widget.controller,
            focusNode: _inputFocus,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            autocorrect: !widget.obscureText && widget.keyboardType == null,
            enableSuggestions: !widget.obscureText,
            textInputAction: TextInputAction.done,
            onChanged: widget.onChanged,
            onSubmitted: (value) {
              _stopEditing();
              widget.onSubmitted?.call(value);
            },
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(
              labelText: widget.label,
              errorText: widget.errorText,
              helperText: widget.helperText,
              helperMaxLines: 2,
              counterText: '',
              filled: true,
              fillColor: highlighted ? AppColors.focusFill : AppColors.surface,
              enabledBorder: _border(
                focused ? AppColors.focusBorder : Colors.transparent,
              ),
              focusedBorder: _border(AppColors.accent),
              errorBorder: _border(AppColors.danger),
              focusedErrorBorder: _border(AppColors.danger),
            ),
          ),
        );
      },
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: 2),
  );
}
