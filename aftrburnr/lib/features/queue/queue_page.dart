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
import '../common/track_row.dart';

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

  /// Upcoming rows plus the two section headers, in display order. The
  /// headers live inside the reorderable list so rows can be dragged
  /// between "Next in queue" and "Next up".
  List<_Item> _upcomingItems(PlayQueue q) {
    final up = q.upcoming;
    final next = up.takeWhile((e) => e.origin == QueueOrigin.next).toList();
    final rest = up.skip(next.length).toList();
    var n = 0;
    return [
      if (next.isNotEmpty) const _Item.header('Next in queue'),
      for (final e in next) _Item.entry(e, ++n),
      if (rest.isNotEmpty) const _Item.header('Next up'),
      for (final e in rest) _Item.entry(e, ++n),
    ];
  }

  /// [newIndex] is where the dragged row lands once it has been taken out
  /// of [items]. The section header above the landing spot decides whether
  /// the rows join "Next in queue".
  void _onReorder(PlayQueue q, List<_Item> items, int oldIndex, int newIndex) {
    final dragged = items[oldIndex].entry;
    if (dragged == null) return;
    final without = [...items]..removeAt(oldIndex);
    final landing = newIndex.clamp(0, without.length);
    // Section: the nearest header above the landing slot.
    String? section;
    for (var i = landing - 1; i >= 0; i--) {
      if (without[i].header != null) {
        section = without[i].header;
        break;
      }
    }
    section ??= without.isNotEmpty && without.first.header != null
        ? without.first.header
        : null;
    // Entry the dragged row is dropped in front of (null = end of queue).
    QueueEntry? before;
    for (var i = landing; i < without.length; i++) {
      if (without[i].entry != null) {
        before = without[i].entry;
        break;
      }
    }
    final moving = _sel.contains(dragged.uid) && _sel.length > 1
        ? {..._sel}
        : {dragged.uid};
    final to = before == null
        ? q.entries.length
        : q.entries.indexWhere((e) => e.uid == before!.uid);
    _c.move(moving, to, intoNext: section == 'Next in queue');
  }

  void _menuAt(int uid, Offset at, PlayQueue q) => _menu(uid, at, q);

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
          title: 'Nothing queued',
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
    final items = _upcomingItems(q);
    final remaining = up.fold<Duration>(
      Duration.zero,
      (a, e) => a + (st.tracks[e.trackId]?.duration ?? Duration.zero),
    );

    return LayoutBuilder(
      builder: (context, c) {
        final showAlbum = c.maxWidth > 560;
        Widget row(
          QueueEntry e, {
          int? number,
          bool dim = false,
          bool current = false,
        }) {
          return TrackRow(
            track: st.tracks[e.trackId],
            number: number,
            isCurrent: current,
            playing: st.playing,
            selected: _sel.contains(e.uid),
            focused: _cursor == e.uid && _focus.hasFocus,
            dim: dim,
            showAlbum: showAlbum,
            onTap: () => _click(e.uid, q),
            onDoubleTap: () => _c.jumpTo(e.uid),
            onPlay: current ? _c.togglePlay : () => _c.jumpTo(e.uid),
            onMenu: (at) => _menuAt(e.uid, at, q),
          );
        }

        const listPad = EdgeInsets.symmetric(horizontal: S.s5);
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
                    S.s6,
                    Dim.gutter,
                    S.s3,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Queue', style: t.displayL),
                      const SizedBox(height: S.s2),
                      Text(
                        up.isEmpty
                            ? 'Nothing after this track'
                            : '${plural(up.length, 'track')} after this one · ${formatTotal(remaining)}',
                        style: t.meta.copyWith(
                          fontFeatures: t.num.fontFeatures,
                        ),
                      ),
                      const SizedBox(height: S.s5),
                      Row(
                        children: [
                          AfButton(
                            label: 'Add files',
                            icon: LucideIcons.plus,
                            onPressed: () =>
                                openFiles(context, ref, playNow: false),
                          ),
                          const SizedBox(width: S.s3),
                          AfButton(
                            label: 'Clear queue',
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
                  SliverPadding(
                    padding: listPad,
                    sliver: SliverList.builder(
                      itemCount: played.length,
                      itemBuilder: (context, i) => row(played[i], dim: true),
                    ),
                  ),
              ],
              const SliverToBoxAdapter(child: _Heading('Now playing')),
              SliverPadding(
                padding: listPad,
                sliver: SliverToBoxAdapter(
                  child: row(q.currentEntry!, current: true),
                ),
              ),
              if (up.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dim.gutter,
                      S.s6,
                      Dim.gutter,
                      S.s2,
                    ),
                    child: Text(
                      'The queue ends after this track. Add files, or turn on repeat.',
                      style: t.meta,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: listPad,
                  sliver: SliverReorderableList(
                    itemCount: items.length,
                    proxyDecorator: dragProxy,
                    onReorderItem: (a, b) => _onReorder(q, items, a, b),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      final e = it.entry;
                      if (e == null) {
                        return _Heading(
                          it.header!,
                          key: ValueKey('h:${it.header}'),
                          inset: false,
                        );
                      }
                      return ReorderableDragStartListener(
                        key: ValueKey(e.uid),
                        index: i,
                        child: row(e, number: it.number),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: S.s8)),
            ],
          ),
        );
      },
    );
  }
}

class _Item {
  const _Item.header(String this.header) : entry = null, number = null;
  const _Item.entry(QueueEntry this.entry, int this.number) : header = null;
  final String? header;
  final QueueEntry? entry;
  final int? number;
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {super.key, this.inset = true});
  final String text;

  /// Headings outside the padded list carry the page gutter themselves.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        inset ? Dim.gutter : S.s3,
        S.s6,
        inset ? Dim.gutter : S.s3,
        S.s3,
      ),
      child: Text(text, style: AfType.desktop.section),
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
      builder: (context, s) {
        final c = s.hovered || s.focused ? C.textHi : C.textMid;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            Dim.gutter,
            S.s6,
            Dim.gutter,
            S.s3,
          ),
          child: Row(
            children: [
              Text(label, style: t.section.copyWith(color: c)),
              const SizedBox(width: S.s3),
              Text(formatCount(count), style: t.num.copyWith(color: c)),
              const SizedBox(width: S.s2),
              Icon(
                open ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                size: IconSz.nav,
                color: c,
              ),
            ],
          ),
        );
      },
    );
  }
}
