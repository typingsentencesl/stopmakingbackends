import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/layout_state.dart';
import '../../audio/player_controller.dart';
import '../../audio/queue.dart';
import '../../core/models/track.dart';
import '../../design/tokens.dart';
import '../../design/type.dart';
import '../../design/widgets/art.dart';
import '../../design/widgets/buttons.dart';
import '../../design/widgets/panel.dart';
import '../../design/widgets/pressable.dart';
import '../art/art_color.dart';

/// Right panel (DESIGN.md §10): large art on a flat band of the art's own
/// color, title and artist, then what plays next.
class NowPlayingPanel extends ConsumerWidget {
  const NowPlayingPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AfType.desktop;
    final st = ref.watch(playerProvider);
    final track = st.current;
    // What the next button would play (repeat-one doesn't hide it).
    final q = st.queue;
    final nextEntry = q.current >= 0 && q.current + 1 < q.entries.length
        ? q.entries[q.current + 1]
        : (q.repeat == QueueRepeat.all && q.entries.length > 1
              ? q.entries.first
              : null);
    final next = nextEntry == null ? null : st.tracks[nextEntry.trackId];
    return Panel(
      width: Dim.nowPlayingPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Dim.panelPad, S.s3, S.s3, S.s3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    track == null || track.album.isEmpty
                        ? 'Now playing'
                        : track.album,
                    style: t.titleS,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AfIconButton(
                  icon: LucideIcons.x,
                  tooltip: 'Close',
                  size: IconSz.nav,
                  onPressed: () =>
                      ref.read(layoutProvider.notifier).toggleNowPlaying(),
                ),
              ],
            ),
          ),
          Expanded(
            child: track == null
                ? Padding(
                    padding: const EdgeInsets.all(Dim.panelPad),
                    child: Text(
                      'Nothing playing. Pick a track and it shows up here.',
                      style: t.meta,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Dim.panelPad,
                      0,
                      Dim.panelPad,
                      Dim.panelPad,
                    ),
                    children: [
                      _ArtBand(track: track),
                      const SizedBox(height: S.s5),
                      Text(
                        track.title,
                        style: t.displayM,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: S.s1),
                      Text(
                        track.displayArtist,
                        style: t.meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: S.s6),
                      _NextCard(
                        next: next,
                        onPlay: nextEntry == null
                            ? null
                            : () => ref
                                  .read(playerProvider.notifier)
                                  .jumpTo(nextEntry.uid),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ArtBand extends ConsumerWidget {
  const _ArtBand({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = track.artUri;
    final band = uri == null
        ? null
        : ref.watch(artBandColorProvider(uri)).value;
    return LayoutBuilder(
      builder: (context, c) => AnimatedContainer(
        duration: M.slow,
        curve: M.baseCurve,
        padding: const EdgeInsets.all(Dim.panelPad),
        decoration: BoxDecoration(color: band ?? C.bg2, borderRadius: R.panel),
        child: Art(uri: uri, size: c.maxWidth - Dim.panelPad * 2),
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.next, required this.onPlay});
  final Track? next;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final t = AfType.desktop;
    final n = next;
    return Container(
      padding: const EdgeInsets.all(Dim.panelPad),
      decoration: const BoxDecoration(color: C.bg2, borderRadius: R.panel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next in queue', style: t.titleS),
          const SizedBox(height: S.s3),
          if (n == null)
            Text('The queue ends after this track.', style: t.meta)
          else
            Pressable(
              onTap: onPlay,
              semanticLabel: 'Play ${n.title}',
              builder: (context, s) => Container(
                padding: const EdgeInsets.all(S.s2),
                decoration: BoxDecoration(
                  borderRadius: R.small,
                  color: s.pressed
                      ? C.lineStrong
                      : s.hovered
                      ? C.bg3
                      : C.transparent,
                ),
                child: Row(
                  children: [
                    Art(uri: n.artUri, size: Dim.libraryItemArt),
                    const SizedBox(width: S.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title,
                            style: t.rowTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            n.displayArtist,
                            style: t.meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (s.hovered)
                      const Icon(
                        LucideIcons.play,
                        size: IconSz.row,
                        color: C.textHi,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
