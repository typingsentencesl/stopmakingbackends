import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens.dart';
import '../type.dart';
import 'pressable.dart';

/// 1 px `textHi` ring drawn 2 px outside a control, for keyboard focus.
Widget focusRing({
  required bool show,
  required BorderRadius radius,
  required Widget child,
}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      child,
      if (show)
        Positioned(
          left: -3,
          top: -3,
          right: -3,
          bottom: -3,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: C.textHi, width: Dim.hairline),
              ),
            ),
          ),
        ),
    ],
  );
}

/// Bare icon button. `active` is the flame "on" state (shuffle, repeat,
/// an open panel), shown with a 4 px flame dot under the icon.
class AfIconButton extends StatelessWidget {
  const AfIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = IconSz.transport,
    this.box = 32,
    this.active = false,
    this.dot = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double box;
  final bool active;

  /// Whether the active state also draws the dot.
  final bool dot;

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
          return focusRing(
            show: s.focused,
            radius: R.small,
            child: SizedBox(
              width: box,
              height: box,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    duration: M.fast,
                    curve: M.fastCurve,
                    scale: s.pressed ? 0.92 : 1,
                    child: Icon(icon, size: size, color: color),
                  ),
                  if (active && dot)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: S.s2,
                        height: S.s2,
                        decoration: const BoxDecoration(
                          color: C.flame,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Round play/pause button. Small (32) in the transport with a `textHi`
/// fill that turns flame on hover; large (56) on page headers with a flame
/// fill, since it is the primary action of the page.
class PlayCircle extends StatelessWidget {
  const PlayCircle({
    super.key,
    required this.playing,
    required this.onPressed,
    this.large = false,
  });

  final bool playing;
  final VoidCallback? onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final d = large ? Dim.playLarge : Dim.playSmall;
    return Tooltip(
      message: playing ? 'Pause  (Space)' : 'Play  (Space)',
      child: Pressable(
        onTap: onPressed,
        semanticLabel: playing ? 'Pause' : 'Play',
        cursor: SystemMouseCursors.click,
        builder: (context, s) {
          final Color fill;
          if (!s.enabled) {
            fill = C.bg3;
          } else if (s.pressed) {
            fill = C.flamePressed;
          } else if (large || s.hovered) {
            fill = C.flame;
          } else {
            fill = C.textHi;
          }
          return focusRing(
            show: s.focused,
            radius: R.pill,
            child: AnimatedContainer(
              duration: M.fast,
              curve: M.fastCurve,
              width: d,
              height: d,
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
              child: Icon(
                playing ? LucideIcons.pause : LucideIcons.play,
                size: large ? IconSz.playGlyphLarge : IconSz.playGlyph,
                color: s.enabled ? C.onFlame : C.textOff,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum AfButtonKind {
  /// Flame pill: the one primary action on a screen.
  primary,

  /// `textHi` pill with a dark label.
  secondary,

  /// Outline pill for quiet toolbar actions and destructive confirmations.
  outline,
}

class AfButton extends StatelessWidget {
  const AfButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = AfButtonKind.outline,
    this.icon,
    this.autofocus = false,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AfButtonKind kind;
  final IconData? icon;
  final bool autofocus;
  final bool large;

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
                ? C.bg3
                : s.pressed
                ? C.flamePressed
                : C.flame;
            fg = s.enabled ? C.onFlame : C.textOff;
          case AfButtonKind.secondary:
            bg = !s.enabled
                ? C.bg3
                : s.pressed
                ? C.textMid
                : C.textHi;
            fg = s.enabled ? C.bg0 : C.textOff;
          case AfButtonKind.outline:
            bg = s.pressed ? C.bg3 : C.transparent;
            fg = s.enabled ? C.textHi : C.textOff;
            border = Border.all(
              color: !s.enabled
                  ? C.textOff
                  : (s.hovered || s.pressed)
                  ? C.textHi
                  : C.textLow,
              width: Dim.hairline,
            );
        }
        return focusRing(
          show: s.focused,
          radius: R.pill,
          child: AnimatedContainer(
            duration: M.fast,
            curve: M.fastCurve,
            height: large ? Dim.buttonLarge : Dim.button,
            padding: EdgeInsets.symmetric(horizontal: large ? S.s7 : S.s5),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: R.pill,
              border: border,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: IconSz.row, color: fg),
                  const SizedBox(width: S.s3),
                ],
                Text(
                  label,
                  style: (large ? t.section : t.bodyStrong).copyWith(color: fg),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
