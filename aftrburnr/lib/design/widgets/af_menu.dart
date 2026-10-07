import 'package:flutter/material.dart';

import '../tokens.dart';
import '../type.dart';
import 'pressable.dart';
import 'states.dart';

class AfMenuItem {
  const AfMenuItem(
    this.label,
    this.onSelected, {
    this.icon,
    this.keys,
    this.enabled = true,
  });
  final String label;
  final VoidCallback onSelected;
  final IconData? icon;

  /// Shortcut shown as a keycap, e.g. `Del`.
  final String? keys;
  final bool enabled;
}

/// Context menu: `bg3`, r4, 1 px `lineStrong`, 36 px rows, keyboard navigable,
/// Esc or a click outside closes it. Opens with a 160 ms fade, no scale.
Future<void> showAfMenu(
  BuildContext context, {
  required Offset position,
  required List<AfMenuItem?> items,
}) {
  return Navigator.of(context)
      .push(_MenuRoute(position: position, items: items));
}

class _MenuRoute extends PopupRoute<void> {
  _MenuRoute({required this.position, required this.items});

  final Offset position;

  /// `null` entries draw a hairline separator.
  final List<AfMenuItem?> items;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Close menu';

  @override
  Duration get transitionDuration => M.base;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: M.baseCurve),
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final t = AfType.desktop;
    var first = true;
    final menu = Container(
      width: 232,
      padding: const EdgeInsets.symmetric(vertical: S.s2),
      decoration: BoxDecoration(
        color: C.bg3,
        borderRadius: R.small,
        border: Border.all(color: C.lineStrong, width: Dim.hairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final it in items)
            if (it == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: S.s2),
                child: Divider(),
              )
            else
              Builder(
                builder: (context) {
                  final auto = first && it.enabled;
                  if (auto) first = false;
                  return Pressable(
                    autofocus: auto,
                    onTap: it.enabled
                        ? () {
                            Navigator.of(context).pop();
                            it.onSelected();
                          }
                        : null,
                    builder: (context, s) => Container(
                      height: Dim.menuRow,
                      padding: const EdgeInsets.symmetric(horizontal: S.s4),
                      margin: const EdgeInsets.symmetric(horizontal: S.s2),
                      decoration: BoxDecoration(
                        borderRadius: R.small,
                        color: (s.pressed || s.hovered || s.focused)
                            ? C.lineStrong
                            : C.transparent,
                      ),
                      child: Row(
                        children: [
                          if (it.icon != null) ...[
                            Icon(
                              it.icon,
                              size: IconSz.row,
                              color: it.enabled ? C.textMid : C.textOff,
                            ),
                            const SizedBox(width: S.s4),
                          ],
                          Expanded(
                            child: Text(
                              it.label,
                              style: t.body.copyWith(
                                color: it.enabled ? C.textHi : C.textOff,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (it.keys != null) Keycap(it.keys!),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, c) {
        // Keep the menu on screen: flip left/up when it would overflow.
        const w = 232.0;
        final h =
            items.fold<double>(
              0,
              (a, it) => a + (it == null ? S.s3 + 1 : Dim.menuRow),
            ) +
            S.s3;
        var x = position.dx;
        var y = position.dy;
        if (x + w > c.maxWidth) x = (x - w).clamp(0, c.maxWidth - w);
        if (y + h > c.maxHeight) y = (y - h).clamp(0, c.maxHeight - h);
        return Stack(
          children: [
            Positioned(
              left: x,
              top: y,
              child: FocusScope(
                autofocus: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: DefaultTextStyle(style: t.body, child: menu),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
