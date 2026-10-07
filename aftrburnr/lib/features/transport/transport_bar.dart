import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/layout_state.dart';
import '../../audio/player_controller.dart';
import '../../audio/queue.dart';
import '../../core/format.dart';
import '../../design/tokens.dart';
import '../../design/type.dart';
import '../../design/widgets/af_slider.dart';
import '../../design/widgets/art.dart';
import '../../design/widgets/buttons.dart';

/// Bottom transport on the canvas (DESIGN.md §10): what's playing on the
/// left, controls over progress in the middle, panels and volume right.
class TransportBar extends ConsumerWidget {
  const TransportBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(playerProvider);
    final track = st.current;
    final t = AfType.desktop;
    return Container(
      height: Dim.transport,
      color: C.bg0,
      padding: const EdgeInsets.symmetric(horizontal: S.s4),
      child: LayoutBuilder(
        builder: (context, c) {
          final side = (c.maxWidth * 0.3).clamp(180.0, 380.0);
          return Row(
            children: [
              SizedBox(
                width: side,
                child: track == null
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          Art(uri: track.artUri, size: Dim.transportArt),
                          const SizedBox(width: S.s4),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: t.titleS,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: S.s1),
                                Text(
                                  track.displayArtist,
                                  style: t.metaS,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: const _Controls(),
                  ),
                ),
              ),
              SizedBox(width: side, child: const _Right()),
            ],
          );
        },
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(playerProvider);
    final c = ref.read(playerProvider.notifier);
    final has = st.queue.currentEntry != null;
    final shuffle = st.queue.shuffle;
    final repeat = st.queue.repeat;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AfIconButton(
              icon: shuffle == ShuffleMode.leastRecent
                  ? LucideIcons.history
                  : LucideIcons.shuffle,
              tooltip: switch (shuffle) {
                ShuffleMode.off => 'Shuffle: off  (S)',
                ShuffleMode.random => 'Shuffle: random  (S)',
                ShuffleMode.leastRecent =>
                  'Shuffle: least recently played  (S)',
              },
              size: IconSz.nav,
              active: shuffle != ShuffleMode.off,
              onPressed: c.cycleShuffle,
            ),
            const SizedBox(width: S.s3),
            AfIconButton(
              icon: LucideIcons.skipBack,
              tooltip: 'Previous  (Ctrl+←)',
              onPressed: has ? c.previous : null,
            ),
            const SizedBox(width: S.s3),
            PlayCircle(
              playing: st.playing,
              onPressed: has ? c.togglePlay : null,
            ),
            const SizedBox(width: S.s3),
            AfIconButton(
              icon: LucideIcons.skipForward,
              tooltip: 'Next  (Ctrl+→)',
              onPressed: has ? c.next : null,
            ),
            const SizedBox(width: S.s3),
            AfIconButton(
              icon: repeat == QueueRepeat.one
                  ? LucideIcons.repeat1
                  : LucideIcons.repeat,
              tooltip: switch (repeat) {
                QueueRepeat.off => 'Repeat: off  (R)',
                QueueRepeat.all => 'Repeat: queue  (R)',
                QueueRepeat.one => 'Repeat: this track  (R)',
              },
              size: IconSz.nav,
              active: repeat != QueueRepeat.off,
              onPressed: c.cycleRepeat,
            ),
          ],
        ),
        const SizedBox(height: S.s1),
        const _Progress(),
      ],
    );
  }
}

class _Progress extends ConsumerStatefulWidget {
  const _Progress();

  @override
  ConsumerState<_Progress> createState() => _ProgressState();
}

class _ProgressState extends ConsumerState<_Progress> {
  /// While dragging, show the drag position instead of playback.
  double? _scrub;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(playerProvider);
    final pos = ref.watch(positionProvider).value ?? Duration.zero;
    final dur = st.duration;
    final has = st.queue.currentEntry != null && dur > Duration.zero;
    final frac = has
        ? (_scrub ?? (pos.inMilliseconds / dur.inMilliseconds)).clamp(0.0, 1.0)
        : 0.0;
    final shown = has
        ? Duration(milliseconds: (frac * dur.inMilliseconds).round())
        : Duration.zero;
    final t = AfType.desktop;
    return Row(
      children: [
        SizedBox(
          width: S.s8,
          child: Text(
            formatDuration(shown),
            style: t.numS,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: S.s3),
        Expanded(
          child: AfSlider(
            value: frac,
            semanticLabel: 'Seek',
            step: dur.inMilliseconds == 0 ? 0.05 : 10000 / dur.inMilliseconds,
            onChanged: has ? (v) => setState(() => _scrub = v) : null,
            onChangeEnd: has
                ? (v) {
                    setState(() => _scrub = null);
                    ref
                        .read(playerProvider.notifier)
                        .seek(
                          Duration(
                            milliseconds: (v * dur.inMilliseconds).round(),
                          ),
                        );
                  }
                : null,
          ),
        ),
        const SizedBox(width: S.s3),
        SizedBox(
          width: S.s8,
          child: Text(has ? formatDuration(dur) : '0:00', style: t.numS),
        ),
      ],
    );
  }
}

class _Right extends ConsumerWidget {
  const _Right();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vol = ref.watch(playerProvider.select((s) => s.volume));
    final panel = ref.watch(layoutProvider.select((l) => l.nowPlaying));
    final c = ref.read(playerProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AfIconButton(
          icon: LucideIcons.squarePlay,
          tooltip: panel ? 'Hide now playing view' : 'Show now playing view',
          size: IconSz.nav,
          active: panel,
          onPressed: () => ref.read(layoutProvider.notifier).toggleNowPlaying(),
        ),
        const SizedBox(width: S.s2),
        AfIconButton(
          icon: vol == 0
              ? LucideIcons.volumeX
              : vol < 0.5
              ? LucideIcons.volume1
              : LucideIcons.volume2,
          tooltip: vol == 0 ? 'Unmute  (M)' : 'Mute  (M)',
          size: IconSz.nav,
          onPressed: c.toggleMute,
        ),
        const SizedBox(width: S.s2),
        SizedBox(
          width: 96,
          child: AfSlider(
            value: vol,
            semanticLabel: 'Volume',
            onChanged: (v) => c.setVolume(v),
          ),
        ),
      ],
    );
  }
}
