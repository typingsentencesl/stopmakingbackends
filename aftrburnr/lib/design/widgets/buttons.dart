import 'package:flutter/material.dart';

import '../tokens.dart';
import '../type.dart';
import 'pressable.dart';

/// Square icon button. `active` is the flame "on" state used for shuffle and
/// repeat; nothing else is allowed to be flame here.
class AfIconButton extends StatelessWidget {
  const AfIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = IconSz.transport,
    this.box = 32,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double box;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onPressed,
        semanticLabel: tooltip,
        builder: (context, s) {
          final color = !s.enabled
              ? C.textOff
              : active
              ? C.flame
              : (s.hovered || s.pressed || s.focused)
              ? C.textHi
              : C.textMid;
          return AnimatedContainer(
            duration: M.fast,
            curve: M.fastCurve,
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: s.pressed ? C.bg2 : C.transparent,
              borderRadius: R.control,
              border: s.focused
                  ? Border.all(color: C.textHi, width: Dim.hairline)
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: size, color: color),
          );
        },
      ),
    );
  }
}

enum AfButtonKind { primary, secondary, outline }

/// Text button. Primary is the single flame action on a screen; secondary
/// is a quiet `bg2` block; outline is used for destructive confirmations.
class AfButton extends StatelessWidget {
  const AfButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = AfButtonKind.secondary,
    this.icon,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AfButtonKind kind;
  final IconData? icon;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    return Pressable(
      onTap: onPressed,
      autofocus: autofocus,
      cursor: SystemMouseCursors.click,
      semanticLabel: label,
      builder: (context, s) {
        Color bg;
        Color fg;
        Border? border;
        switch (kind) {
          case AfButtonKind.primary:
            bg = !s.enabled
                ? C.bg2
                : s.pressed
                ? C.flamePressed
                : C.flame;
            fg = s.enabled ? C.onFlame : C.textOff;
            if (s.hovered && !s.pressed) {
              border = Border.all(color: C.textHi, width: Dim.hairline);
            }
          case AfButtonKind.secondary:
            bg = !s.enabled
                ? C.bg1
                : (s.hovered || s.pressed)
                ? C.bg3
                : C.bg2;
            fg = s.enabled ? C.textHi : C.textOff;
          case AfButtonKind.outline:
            bg = s.pressed ? C.bg3 : (s.hovered ? C.bg2 : C.transparent);
            fg = s.enabled ? C.textHi : C.textOff;
            border = Border.all(
              color: s.enabled ? C.textHi : C.textOff,
              width: Dim.hairline,
            );
        }
        if (s.focused) {
          border = Border.all(color: C.textHi, width: Dim.hairline);
        }
        return AnimatedContainer(
          duration: M.fast,
          curve: M.fastCurve,
          height: Dim.rowNormal,
          padding: const EdgeInsets.symmetric(horizontal: S.s4),
          transform: Matrix4.translationValues(0, s.pressed ? 1 : 0, 0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: R.control,
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: IconSz.row, color: fg),
                const SizedBox(width: S.s3),
              ],
              Text(label, style: t.bodyStrong.copyWith(color: fg)),
            ],
          ),
        );
      },
    );
  }
}
