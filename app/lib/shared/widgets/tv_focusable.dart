import 'package:flutter/widgets.dart';

typedef FocusWidgetBuilder = Widget Function(
  BuildContext context,
  bool focused,
);

/// Base building block for everything the user can select with a remote,
/// a mouse or a touch screen. Activation through select/enter/game pad keys
/// and taps all end up in [onSelect].
class TvFocusable extends StatefulWidget {
  const TvFocusable({
    super.key,
    required this.builder,
    this.onSelect,
    this.onFocusChange,
    this.focusNode,
    this.autofocus = false,
  });

  final FocusWidgetBuilder builder;
  final VoidCallback? onSelect;
  final ValueChanged<bool>? onFocusChange;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onSelect?.call();
        return null;
      },
    ),
  };

  void _handleFocusChange(bool focused) {
    setState(() => _focused = focused);
    widget.onFocusChange?.call(focused);
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      actions: _actions,
      onFocusChange: _handleFocusChange,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelect,
        child: widget.builder(context, _focused),
      ),
    );
  }
}
