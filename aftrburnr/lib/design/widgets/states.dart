import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens.dart';
import '../type.dart';
import 'buttons.dart';

/// Status strip (DESIGN.md §4): no status hues, just `bg2`, a 2 px
/// `textHi` rule, an icon and a plain sentence.
class StatusStrip extends StatelessWidget {
  const StatusStrip({
    super.key,
    required this.message,
    this.icon = LucideIcons.circleAlert,
    this.onDismiss,
    this.action,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    return Container(
      decoration: const BoxDecoration(
        color: C.bg2,
        border: Border(left: BorderSide(color: C.textHi, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(S.s4, S.s3, S.s2, S.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: S.s1),
            child: Icon(icon, size: IconSz.row, color: C.textHi),
          ),
          const SizedBox(width: S.s3),
          Expanded(child: Text(message, style: t.body)),
          if (action != null) ...[const SizedBox(width: S.s3), action!],
          if (onDismiss != null)
            AfIconButton(
              icon: LucideIcons.x,
              tooltip: 'Dismiss',
              size: IconSz.row,
              box: 24,
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}

/// Empty / error page layout: left-aligned at the content start, one
/// display line, one meta line, one action.
class PageMessage extends StatelessWidget {
  const PageMessage({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.isError = false,
  });

  final String title;
  final String body;
  final Widget? action;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: t.displayM),
        const SizedBox(height: S.s3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(body, style: t.meta),
        ),
        if (action != null) ...[const SizedBox(height: S.s5), action!],
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dim.gutter, S.s8, Dim.gutter, S.s6),
      child: isError
          ? Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: C.textHi, width: 2)),
              ),
              padding: const EdgeInsets.only(left: S.s5),
              child: content,
            )
          : content,
    );
  }
}

/// Uppercase source badge: LOCAL, AUDIUS, JAMENDO.
class SourceBadge extends StatelessWidget {
  const SourceBadge(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.s2, vertical: S.s0),
      decoration: BoxDecoration(
        borderRadius: R.control,
        border: Border.all(color: C.line, width: Dim.hairline),
      ),
      child: Text(label.toUpperCase(), style: AfType.desktop.label),
    );
  }
}

/// Keycap shown in tooltips, menus and the palette.
class Keycap extends StatelessWidget {
  const Keycap(this.keys, {super.key});
  final String keys;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.s2, vertical: S.s0),
      decoration: BoxDecoration(
        borderRadius: R.control,
        border: Border.all(color: C.line, width: Dim.hairline),
      ),
      child: Text(keys.toUpperCase(), style: AfType.desktop.label),
    );
  }
}
