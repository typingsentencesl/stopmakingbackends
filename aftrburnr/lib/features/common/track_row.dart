import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../core/models/track.dart';
import '../../design/tokens.dart';
import '../../design/type.dart';
import '../../design/widgets/art.dart';
import '../../design/widgets/playing_bars.dart';
import '../../design/widgets/pressable.dart';
import '../../design/widgets/states.dart';

/// One track in a list (DESIGN.md §9): 56 px, art, title over artist, album
/// column, duration. On hover the number turns into a play glyph and a `⋯`
/// button appears.
class TrackRow extends StatelessWidget {
  const TrackRow({
    super.key,
    required this.track,
    required this.number,
    required this.isCurrent,
    required this.playing,
    required this.selected,
    required this.focused,
    this.dim = false,
    this.badge,
    this.showAlbum = true,
    this.onTap,
    this.onDoubleTap,
    this.onPlay,
    this.onMenu,
  });

  final Track? track;

  /// Shown in the first column; null leaves it blank.
  final int? number;
  final bool isCurrent;
  final bool playing;
  final bool selected;

  /// Keyboard cursor of the list (not Flutter focus).
  final bool focused;

  /// Already played entries are drawn in `textLow`.
  final bool dim;
  final String? badge;
  final bool showAlbum;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  /// The play glyph in the number column.
  final VoidCallback? onPlay;

  /// Right click or the `⋯` button; receives the global position to open
  /// the menu at.
  final ValueChanged<Offset>? onMenu;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    final tr = track;
    return Pressable(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapUp: onMenu == null
          ? null
          : (d) => onMenu!(d.globalPosition),
      canRequestFocus: false,
      builder: (context, s) {
        final bg = s.pressed || selected
            ? C.bg3
            : s.hovered
            ? C.bg2
            : C.transparent;
        final unavailable = tr == null || !tr.available;
        final titleColor = isCurrent
            ? C.flame
            : (dim || unavailable)
            ? C.textLow
            : C.textHi;
        final otherColor = dim || unavailable ? C.textLow : C.textMid;
        final showControls = s.hovered || selected;
        return Container(
          height: Dim.row,
          padding: const EdgeInsets.symmetric(horizontal: S.s3),
          decoration: BoxDecoration(color: bg, borderRadius: R.small),
          foregroundDecoration: focused
              ? BoxDecoration(
                  borderRadius: R.small,
                  border: Border.all(color: C.textHi, width: Dim.hairline),
                )
              : null,
          child: Row(
            children: [
              SizedBox(
                width: S.s7,
                child: Center(
                  child: s.hovered && onPlay != null
                      ? _RowPlay(
                          icon: isCurrent && playing
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          onTap: onPlay!,
                        )
                      : isCurrent
                      ? PlayingBars(playing: playing, size: 14)
                      : Text(
                          number == null ? '' : '$number',
                          style: t.num.copyWith(color: otherColor),
                        ),
                ),
              ),
              const SizedBox(width: S.s4),
              Art(uri: tr?.artUri, size: Dim.rowArt),
              const SizedBox(width: S.s4),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr?.title ?? 'Missing track',
                      style: t.rowTitle.copyWith(color: titleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        if (badge != null) ...[
                          SourceBadge(badge!),
                          const SizedBox(width: S.s2),
                        ],
                        Flexible(
                          child: Text(
                            tr?.displayArtist ?? '',
                            style: t.meta.copyWith(
                              color: s.hovered && !dim ? C.textHi : otherColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showAlbum) ...[
                const SizedBox(width: S.s5),
                Expanded(
                  flex: 4,
                  child: Text(
                    tr?.album ?? '',
                    style: t.meta.copyWith(color: otherColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(width: S.s5),
              SizedBox(
                width: S.s8,
                child: Text(
                  tr == null || tr.duration == Duration.zero
                      ? ''
                      : formatDuration(tr.duration),
                  style: t.num.copyWith(color: otherColor),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: S.s7 + S.s2,
                child: showControls && onMenu != null
                    ? Builder(
                        builder: (context) => _RowMore(
                          onTap: () {
                            final box = context.findRenderObject() as RenderBox;
                            onMenu!(
                              box.localToGlobal(
                                box.size.bottomRight(Offset.zero),
                              ),
                            );
                          },
                        ),
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RowPlay extends StatelessWidget {
  const _RowPlay({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      canRequestFocus: false,
      semanticLabel: 'Play',
      builder: (context, s) => Icon(icon, size: IconSz.row, color: C.textHi),
    );
  }
}

class _RowMore extends StatelessWidget {
  const _RowMore({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'More options',
      child: Pressable(
        onTap: onTap,
        canRequestFocus: false,
        semanticLabel: 'More options',
        builder: (context, s) => Center(
          child: Icon(
            LucideIcons.ellipsis,
            size: IconSz.nav,
            color: s.hovered ? C.textHi : C.textMid,
          ),
        ),
      ),
    );
  }
}
