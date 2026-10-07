import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../audio/player_controller.dart';
import '../design/tokens.dart';
import '../design/type.dart';
import '../design/widgets/pressable.dart';
import '../design/widgets/states.dart';
import '../features/queue/queue_page.dart';
import '../features/transport/transport_bar.dart';
import 'open_files.dart';

/// sidebar | page, transport bar along the bottom (DESIGN.md §10).
class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(playerProvider.select((s) => s.error));
    return ColoredBox(
      color: C.bg0,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Sidebar(),
                Expanded(
                  child: Column(
                    children: [
                      const Expanded(child: QueuePage()),
                      if (error != null)
                        StatusStrip(
                          message: error,
                          onDismiss: () =>
                              ref.read(playerProvider.notifier).dismissError(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const TransportBar(),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AfType.desktop;
    return Container(
      width: Dim.sidebar,
      decoration: const BoxDecoration(
        color: C.bg1,
        border: Border(
          right: BorderSide(color: C.line, width: Dim.hairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(S.s5, S.s5, S.s5, S.s6),
            child: Text('AFTRBURNR', style: t.displayM),
          ),
          const _NavItem(
            icon: LucideIcons.listMusic,
            label: 'Queue',
            selected: true,
          ),
          const Spacer(),
          const Divider(),
          _NavItem(
            icon: LucideIcons.folderOpen,
            label: 'Open files',
            keys: 'Ctrl+O',
            onTap: () => openFiles(context, ref, playNow: true),
          ),
          _NavItem(
            icon: LucideIcons.filePlus2,
            label: 'Add to queue',
            keys: 'Ctrl+Shift+O',
            onTap: () => openFiles(context, ref, playNow: false),
          ),
          const SizedBox(height: S.s3),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.keys,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final String? keys;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    return Pressable(
      // The current page is still a focusable, pressable target so keyboard
      // users can land on it; pressing it does nothing new.
      onTap: onTap ?? () {},
      semanticLabel: label,
      builder: (context, s) {
        final fg = selected || s.hovered || s.focused ? C.textHi : C.textMid;
        return Container(
          height: Dim.rowNormal,
          margin: const EdgeInsets.symmetric(horizontal: S.s3),
          padding: const EdgeInsets.symmetric(horizontal: S.s3),
          decoration: BoxDecoration(
            color: s.pressed
                ? C.bg3
                : selected || s.hovered
                ? C.bg2
                : C.transparent,
            borderRadius: R.control,
            border: s.focused
                ? Border.all(color: C.textHi, width: Dim.hairline)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: IconSz.nav, color: fg),
              const SizedBox(width: S.s4),
              Expanded(
                child: Text(
                  label,
                  style: (selected ? t.bodyStrong : t.body).copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (keys != null && s.hovered) Keycap(keys!),
            ],
          ),
        );
      },
    );
  }
}
