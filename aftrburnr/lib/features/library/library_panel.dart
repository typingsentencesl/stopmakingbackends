import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/open_files.dart';
import '../../audio/player_controller.dart';
import '../../core/format.dart';
import '../../design/tokens.dart';
import '../../design/type.dart';
import '../../design/widgets/af_menu.dart';
import '../../design/widgets/art.dart';
import '../../design/widgets/buttons.dart';
import '../../design/widgets/panel.dart';
import '../../design/widgets/pressable.dart';

/// Left panel, "Your Library" (DESIGN.md §10). Until folders and playlists
/// exist (steps 3–4) it holds the queue and the way to add music.
class LibraryPanel extends ConsumerWidget {
  const LibraryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AfType.desktop;
    final st = ref.watch(playerProvider);
    final q = st.queue;
    return Panel(
      width: Dim.libraryPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dim.panelPad,
              Dim.panelPad,
              S.s3,
              S.s2,
            ),
            child: Text('AFTRBURNR', style: t.displayM),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Dim.panelPad, S.s3, S.s3, S.s3),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.library,
                  size: IconSz.nav,
                  color: C.textMid,
                ),
                const SizedBox(width: S.s3),
                Expanded(child: Text('Your Library', style: t.titleS)),
                Builder(
                  builder: (context) => AfIconButton(
                    icon: LucideIcons.plus,
                    tooltip: 'Add music',
                    size: IconSz.nav,
                    onPressed: () {
                      final box = context.findRenderObject() as RenderBox;
                      showAfMenu(
                        context,
                        position: box.localToGlobal(
                          box.size.bottomLeft(Offset.zero),
                        ),
                        items: [
                          AfMenuItem(
                            'Open files',
                            () => openFiles(context, ref, playNow: true),
                            icon: LucideIcons.folderOpen,
                            keys: 'Ctrl+O',
                          ),
                          AfMenuItem(
                            'Add files to queue',
                            () => openFiles(context, ref, playNow: false),
                            icon: LucideIcons.listPlus,
                            keys: 'Ctrl+Shift+O',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: S.s3),
              children: [
                if (!q.isEmpty)
                  _LibraryItem(
                    art: st.current?.artUri,
                    title: 'Queue',
                    subtitle: 'Queue · ${plural(q.entries.length, 'track')}',
                    selected: true,
                    playing: st.playing,
                  ),
                const SizedBox(height: S.s3),
                const _StartCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  const _LibraryItem({
    required this.art,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.playing,
  });

  final String? art;
  final String title;
  final String subtitle;
  final bool selected;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    return Pressable(
      // The queue is the open page; a press keeps it there.
      onTap: () {},
      semanticLabel: title,
      builder: (context, s) => Container(
        height: Dim.libraryItem,
        padding: const EdgeInsets.symmetric(horizontal: S.s3),
        decoration: BoxDecoration(
          borderRadius: R.small,
          color: s.pressed || selected
              ? C.bg3
              : s.hovered
              ? C.bg2
              : C.transparent,
        ),
        foregroundDecoration: s.focused
            ? BoxDecoration(
                borderRadius: R.small,
                border: Border.all(color: C.textHi, width: Dim.hairline),
              )
            : null,
        child: Row(
          children: [
            Art(uri: art, size: Dim.libraryItemArt),
            const SizedBox(width: S.s4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.rowTitle.copyWith(
                      color: playing ? C.flame : C.textHi,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: t.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartCard extends ConsumerWidget {
  const _StartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AfType.desktop;
    return Container(
      padding: const EdgeInsets.all(Dim.panelPad),
      decoration: const BoxDecoration(color: C.bg2, borderRadius: R.panel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Play your own files', style: t.section),
          const SizedBox(height: S.s2),
          Text(
            'Open audio files from this PC. They stay in your queue '
            'between sessions.',
            style: t.meta,
          ),
          const SizedBox(height: S.s5),
          AfButton(
            label: 'Open files',
            kind: AfButtonKind.secondary,
            onPressed: () => openFiles(context, ref, playNow: true),
          ),
        ],
      ),
    );
  }
}
