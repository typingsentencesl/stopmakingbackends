import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/models/track.dart';
import '../../design/tokens.dart';
import '../../design/type.dart';
import '../../design/widgets/art.dart';
import '../../design/widgets/playing_bars.dart';
import '../../design/widgets/pressable.dart';
import '../../design/widgets/states.dart';

/// One tight (28 px) track row. Draws every state from DESIGN.md §9.
class TrackRowView extends StatelessWidget {
  const TrackRowView({
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
    this.onSecondaryTapUp,
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
  final GestureTapUpCallback? onSecondaryTapUp;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    final tr = track;
    return Pressable(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapUp: onSecondaryTapUp,
      canRequestFocus: false,
      builder: (context, s) {
        final bg = isCurrent
            ? C.flameWashOver(C.bg0)
            : s.pressed
            ? C.bg3
            : (selected || s.hovered)
            ? C.bg2
            : C.transparent;
        final unavailable = tr == null || !tr.available;
        final titleColor = isCurrent
            ? C.flame
            : (dim || unavailable)
            ? C.textLow
            : C.textHi;
        final otherColor = dim || unavailable ? C.textLow : C.textMid;
        return Container(
          height: Dim.rowTight,
          color: bg,
          // Drawn on top so the selection rule and focus outline never
          // shift the row's content.
          foregroundDecoration: focused
              ? BoxDecoration(
                  border: Border.all(color: C.textHi, width: Dim.hairline),
                )
              : selected
              ? const BoxDecoration(
                  border: Border(left: BorderSide(color: C.textMid, width: 2)),
                )
              : null,
          padding: const EdgeInsets.only(right: S.s3),
          child: Row(
            children: [
              SizedBox(
                width: S.s7 + S.s3,
                child: Center(
                  child: isCurrent
                      ? PlayingBars(playing: playing, size: 12)
                      : Text(
                          number == null ? '' : '$number',
                          style: t.numS.copyWith(color: C.textLow),
                        ),
                ),
              ),
              Art(uri: tr?.artUri, size: Dim.rowArt),
              const SizedBox(width: S.s3),
              Expanded(
                flex: 4,
                child: Text(
                  tr?.title ?? 'Missing track',
                  style: t.bodyStrong.copyWith(color: titleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: S.s3),
                SourceBadge(badge!),
              ],
              const SizedBox(width: S.s3),
              Expanded(
                flex: 3,
                child: Text(
                  tr?.displayArtist ?? '',
                  style: t.body.copyWith(color: otherColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showAlbum) ...[
                const SizedBox(width: S.s3),
                Expanded(
                  flex: 3,
                  child: Text(
                    tr?.album ?? '',
                    style: t.body.copyWith(color: otherColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(width: S.s3),
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
            ],
          ),
        );
      },
    );
  }
}
