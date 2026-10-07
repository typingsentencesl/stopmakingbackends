import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/open_files.dart';
import '../../audio/player_controller.dart';
import '../../audio/queue.dart';
import '../../core/format.dart';
import '../../design/tokens.dart';
import '../../design/type.dart';
import '../../design/widgets/af_menu.dart';
import '../../design/widgets/buttons.dart';
import '../../design/widgets/drag_proxy.dart';
import '../../design/widgets/pressable.dart';
import '../../design/widgets/states.dart';
import 'queue_row.dart';

/// The queue: "Played" (collapsed), "Now playing", then everything
/// upcoming, which can be reordered by drag. Rows support click,
/// Ctrl-click and Shift-click selection and full keyboard control.
class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  final Set<int> _sel = {};
  int? _anchor;
  int? _cursor;
  bool _showPlayed = false;
  final _focus = FocusNode(debugLabel: 'queue');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  PlayerController get _c => ref.read(playerProvider.notifier);

  /// Rows in display order, as uids.
  List<int> _visible(PlayQueue q) => [
    if (_showPlayed) ...q.played.map((e) => e.uid),
    if (q.currentEntry != null) q.currentEntry!.uid,
    ...q.upcoming.map((e) => e.uid),
  ];

  void _click(int uid, PlayQueue q) {
    final keys = HardwareKeyboard.instance;
    final vis = _visible(q);
    setState(() {
      if (keys.isShiftPressed && _anchor != null && vis.contains(_anchor)) {
        final a = vis.indexOf(_anchor!);
        final b = vis.indexOf(uid);
        _sel
          ..clear()
          ..addAll(vis.sublist(a < b ? a : b, (a < b ? b : a) + 1));
      } else if (keys.isControlPressed || keys.isMetaPressed) {
        if (!_sel.remove(uid)) _sel.add(uid);
        _anchor = uid;
      } else {
        _sel
          ..clear()
          ..add(uid);
        _anchor = uid;
      }
      _cursor = uid;
    });
    _focus.requestFocus();
  }

  void _menu(int uid, Offset at, PlayQueue q) {
    if (!_sel.contains(uid)) {
      setState(() {
        _sel
          ..clear()
          ..add(uid);
        _anchor = uid;
        _cursor = uid;
      });
    }
    final sel = {..._sel};
    final isCur = sel.length == 1 && sel.first == q.currentEntry?.uid;
    showAfMenu(
      context,
      position: at,
      items: [
        AfMenuItem(
          'Play',
          () => _c.jumpTo(_firstSelected(q)!),
          icon: LucideIcons.play,
          keys: 'Enter',
        ),
        AfMenuItem(
          'Play next',
          () => _c.makeNext(sel),
          icon: LucideIcons.listStart,
          keys: 'Ctrl+Enter',
          enabled: !isCur,
        ),
        AfMenuItem(
          'Move to end',
          () => _c.move(sel, q.entries.length),
          icon: LucideIcons.listEnd,
          enabled: !isCur,
        ),
        null,
        AfMenuItem(
          sel.length == 1
              ? 'Remove from queue'
              : 'Remove ${sel.length} from queue',
          () => _remove(q),
          icon: LucideIcons.x,
          keys: 'Del',
        ),
      ],
    );
  }

  int? _firstSelected(PlayQueue q) {
    for (final e in q.entries) {
      if (_sel.contains(e.uid)) return e.uid;
    }
    return null;
  }

  void _remove(PlayQueue q) {
    if (_sel.isEmpty) return;
    final vis = _visible(q);
    // Keep the cursor near where the removed rows were.
    final idx = _cursor == null ? -1 : vis.indexOf(_cursor!);
    final remaining = vis.where((u) => !_sel.contains(u)).toList();
    final removed = {..._sel};
    setState(() {
      _sel.clear();
      _cursor = remaining.isEmpty
          ? null
          : remaining[(idx < 0 ? 0 : idx).clamp(0, remaining.length - 1)];
      if (_cursor != null) _sel.add(_cursor!);
      _anchor = _cursor;
    });
    _c.remove(removed);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e, PlayQueue q) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final keys = HardwareKeyboard.instance;
    final ctrl = keys.isControlPressed || keys.isMetaPressed;
    final vis = _visible(q);
    if (vis.isEmpty) return KeyEventResult.ignored;
    final cur = _cursor == null ? -1 : vis.indexOf(_cursor!);
    void moveCursor(int to) {
      to = to.clamp(0, vis.length - 1);
      final uid = vis[to];
      setState(() {
        if (keys.isShiftPressed && _anchor != null && vis.contains(_anchor)) {
          final a = vis.indexOf(_anchor!);
          _sel
            ..clear()
            ..addAll(vis.sublist(a < to ? a : to, (a < to ? to : a) + 1));
        } else {
          _sel
            ..clear()
            ..add(uid);
          _anchor = uid;
        }
        _cursor = uid;
      });
    }

    final k = e.logicalKey;
    if (keys.isAltPressed &&
        (k == LogicalKeyboardKey.arrowUp ||
            k == LogicalKeyboardKey.arrowDown)) {
      if (_sel.isEmpty) return KeyEventResult.handled;
      final idx = [
        for (var i = 0; i < q.entries.length; i++)
          if (_sel.contains(q.entries[i].uid)) i,
      ];
      if (k == LogicalKeyboardKey.arrowUp && idx.first > 0) {
        _c.move(_sel, idx.first - 1);
      } else if (k == LogicalKeyboardKey.arrowDown &&
          idx.last < q.entries.length - 1) {
        _c.move(_sel, idx.last + 2);
      }
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown) {
      moveCursor(cur + 1);
    } else if (k == LogicalKeyboardKey.arrowUp) {
      moveCursor(cur < 0 ? 0 : cur - 1);
    } else if (k == LogicalKeyboardKey.home) {
      moveCursor(0);
    } else if (k == LogicalKeyboardKey.end) {
      moveCursor(vis.length - 1);
    } else if (k == LogicalKeyboardKey.keyA && ctrl) {
      setState(
        () => _sel
          ..clear()
          ..addAll(vis),
      );
    } else if (k == LogicalKeyboardKey.enter && ctrl) {
      if (_sel.isNotEmpty) _c.makeNext({..._sel});
    } else if (k == LogicalKeyboardKey.enter) {
      final f = _firstSelected(q);
      if (f != null) _c.jumpTo(f);
    } else if (k == LogicalKeyboardKey.delete ||
        k == LogicalKeyboardKey.backspace) {
      _remove(q);
    } else if (k == LogicalKeyboardKey.escape && _sel.isNotEmpty) {
      setState(_sel.clear);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// [newIndex] is where the dragged row lands once it has been taken out
  /// of the list; [PlayQueue.move] wants an index into the list before the
  /// move, hence the +1 when dragging downwards.
  void _onReorder(PlayQueue q, int oldIndex, int newIndex) {
    final up = q.upcoming;
    if (oldIndex >= up.length) return;
    final uid = up[oldIndex].uid;
    final start = q.current + 1;
    final before = newIndex < oldIndex ? newIndex : newIndex + 1;
    final moving = _sel.contains(uid) && _sel.length > 1 ? {..._sel} : {uid};
    _c.move(moving, start + before);
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(playerProvider);
    final q = st.queue;
    final t = AfType.desktop;
    if (!st.restored) return const SizedBox.shrink();
    if (q.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: PageMessage(
          title: 'Nothing queued.',
          body:
              'Open audio files and they start playing here. '
              'MP3, FLAC, M4A, OGG, Opus, WAV and more.',
          action: AfButton(
            label: 'Open files',
            icon: LucideIcons.folderOpen,
            kind: AfButtonKind.primary,
            onPressed: () => openFiles(context, ref, playNow: true),
          ),
        ),
      );
    }
    // Drop selection entries that no longer exist.
    final all = {for (final e in q.entries) e.uid};
    _sel.removeWhere((u) => !all.contains(u));
    final up = q.upcoming;
    final played = q.played;
    final remaining = up.fold<Duration>(
      Duration.zero,
      (a, e) => a + (st.tracks[e.trackId]?.duration ?? Duration.zero),
    );

    return LayoutBuilder(
      builder: (context, c) {
        final showAlbum = c.maxWidth > 640;
        Widget row(
          QueueEntry e, {
          int? number,
          bool dim = false,
          bool current = false,
        }) {
          return TrackRowView(
            track: st.tracks[e.trackId],
            number: number,
            isCurrent: current,
            playing: st.playing,
            selected: _sel.contains(e.uid),
            focused: _cursor == e.uid && _focus.hasFocus,
            dim: dim,
            badge: e.origin == QueueOrigin.next ? 'Next up' : null,
            showAlbum: showAlbum,
            onTap: () => _click(e.uid, q),
            onDoubleTap: () => _c.jumpTo(e.uid),
            onSecondaryTapUp: (d) => _menu(e.uid, d.globalPosition, q),
          );
        }

        return Focus(
          focusNode: _focus,
          onFocusChange: (_) => setState(() {}),
          onKeyEvent: (n, e) => _onKey(n, e, q),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dim.gutter,
                    S.s7,
                    Dim.gutter,
                    S.s5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Queue', style: t.displayL),
                      const SizedBox(height: S.s2),
                      Text(
                        up.isEmpty
                            ? 'Nothing after this track'
                            : '${plural(up.length, 'track')} up next · ${formatTotal(remaining)}',
                        style: t.meta.copyWith(
                          fontFeatures: t.num.fontFeatures,
                        ),
                      ),
                      const SizedBox(height: S.s5),
                      Row(
                        children: [
                          AfButton(
                            label: 'Add files',
                            icon: LucideIcons.filePlus2,
                            onPressed: () =>
                                openFiles(context, ref, playNow: false),
                          ),
                          const SizedBox(width: S.s3),
                          AfButton(
                            label: 'Clear up next',
                            onPressed: up.isEmpty ? null : _c.clearUpcoming,
                          ),
                          const SizedBox(width: S.s3),
                          AfButton(
                            label: 'Clear played',
                            onPressed: played.isEmpty ? null : _c.clearPlayed,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (played.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionToggle(
                    label: 'Played',
                    count: played.length,
                    open: _showPlayed,
                    onTap: () => setState(() => _showPlayed = !_showPlayed),
                  ),
                ),
                if (_showPlayed)
                  SliverList.builder(
                    itemCount: played.length,
                    itemBuilder: (context, i) => row(played[i], dim: true),
                  ),
              ],
              const SliverToBoxAdapter(child: _Eyebrow('Now playing')),
              SliverToBoxAdapter(child: row(q.currentEntry!, current: true)),
              const SliverToBoxAdapter(child: _Eyebrow('Up next')),
              if (up.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dim.gutter,
                      S.s2,
                      Dim.gutter,
                      S.s2,
                    ),
                    child: Text(
                      'Queue ends after this track. Add files, or turn on repeat.',
                      style: t.meta,
                    ),
                  ),
                )
              else
                SliverReorderableList(
                  itemCount: up.length,
                  proxyDecorator: dragProxy,
                  onReorderItem: (a, b) => _onReorder(q, a, b),
                  itemBuilder: (context, i) {
                    final e = up[i];
                    return ReorderableDragStartListener(
                      key: ValueKey(e.uid),
                      index: i,
                      child: row(e, number: i + 1),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: S.s8)),
            ],
          ),
        );
      },
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dim.gutter, S.s5, Dim.gutter, S.s2),
      child: Text(text.toUpperCase(), style: AfType.desktop.label),
    );
  }
}

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({
    required this.label,
    required this.count,
    required this.open,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    return Pressable(
      onTap: onTap,
      semanticLabel: open ? 'Hide played' : 'Show played',
      builder: (context, s) => Container(
        padding: const EdgeInsets.fromLTRB(Dim.gutter, S.s5, Dim.gutter, S.s2),
        child: Row(
          children: [
            Text(
              label.toUpperCase(),
              style: t.label.copyWith(
                color: s.hovered || s.focused ? C.textHi : C.textLow,
              ),
            ),
            const SizedBox(width: S.s3),
            Text(formatCount(count), style: t.numS.copyWith(color: C.textLow)),
            const SizedBox(width: S.s2),
            Icon(
              open ? LucideIcons.chevronDown : LucideIcons.chevronRight,
              size: IconSz.row,
              color: s.hovered || s.focused ? C.textHi : C.textLow,
            ),
          ],
        ),
      ),
    );
  }
}
