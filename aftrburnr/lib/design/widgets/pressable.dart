import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interaction states every control draws itself from (DESIGN.md §9).
class PressState {
  const PressState({
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
    this.enabled = true,
  });

  final bool hovered;
  final bool pressed;
  final bool focused;
  final bool enabled;
}

/// Hover, press and keyboard focus handling with no Material ink. Enter and
/// Space activate when focused.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.builder,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapUp,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.cursor = SystemMouseCursors.basic,
    this.semanticLabel,
  });

  final Widget Function(BuildContext context, PressState state) builder;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool canRequestFocus;
  final MouseCursor cursor;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _down = false;
  bool _focus = false;
  DateTime? _lastTap;

  /// Single clicks fire immediately; a second click within the platform
  /// double-tap window also fires [Pressable.onDoubleTap]. (Flutter's own
  /// double-tap recognizer would hold every single click back by 300 ms.)
  void _tap() {
    widget.onTap?.call();
    final dbl = widget.onDoubleTap;
    if (dbl == null) return;
    final now = DateTime.now();
    final last = _lastTap;
    if (last != null && now.difference(last) <= kDoubleTapTimeout) {
      _lastTap = null;
      dbl();
    } else {
      _lastTap = now;
    }
  }

  bool get _enabled => widget.onTap != null || widget.onDoubleTap != null;

  @override
  Widget build(BuildContext context) {
    final state = PressState(
      hovered: _hover && _enabled,
      pressed: _down && _enabled,
      focused: _focus,
      enabled: _enabled,
    );
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: _enabled && widget.canRequestFocus,
        mouseCursor: _enabled ? widget.cursor : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _down = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _down = false) : null,
          onTapCancel: _enabled ? () => setState(() => _down = false) : null,
          onTap: _enabled ? _tap : null,
          onSecondaryTapUp: widget.onSecondaryTapUp,
          child: widget.builder(context, state),
        ),
      ),
    );
  }
}
