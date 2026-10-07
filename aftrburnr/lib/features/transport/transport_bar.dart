import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../audio/player_controller.dart';
import '../../audio/queue.dart';
import '../../core/format.dart';
import '../../design/tokens.dart';
import '../../design/type.dart';
import '../../design/widgets/af_slider.dart';
import '../../design/widgets/art.dart';
import '../../design/widgets/buttons.dart';
import '../../design/widgets/pressable.dart';

/// Bottom transport: what's playing on the left, controls and progress in
/// the middle, volume on the right. 72 px, `bg1`, hairline on top.
class TransportBar extends ConsumerWidget {
  const TransportBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(playerProvider);
    final track = st.current;
    final t = AfType.desktop;
    return Container(
      height: Dim.transport,
      decoration: const BoxDecoration(
        color: C.bg1,
        border: Border(
          top: BorderSide(color: C.line, width: Dim.hairline),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: S.s5),
      child: Row(
        children: [
          // Now playing.
          SizedBox(
            width: 288,
            child: track == null
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Art(uri: track.artUri, size: S.s8),
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
                            Text(
                              track.album.isEmpty
                                  ? track.displayArtist
                                  : '${track.displayArtist} · ${track.album}',
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
          const SizedBox(width: S.s6),
          const Expanded(child: _Controls()),
          const SizedBox(width: S.s6),
          const SizedBox(width: 176, child: _Volume()),
        ],
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
            _PlayButton(playing: st.playing, enabled: has, onTap: c.togglePlay),
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

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.enabled,
    required this.onTap,
  });
  final bool playing;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = playing ? 'Pause  (Space)' : 'Play  (Space)';
    return Tooltip(
      message: label,
      child: Pressable(
        onTap: enabled ? onTap : null,
        semanticLabel: playing ? 'Pause' : 'Play',
        builder: (context, s) => Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: M.fast,
              curve: M.fastCurve,
              width: S.s7,
              height: S.s7,
              decoration: BoxDecoration(
                color: !s.enabled
                    ? C.bg2
                    : s.pressed
                    ? C.flamePressed
                    : s.hovered
                    ? C.flame
                    : C.textHi,
                borderRadius: R.control,
              ),
              child: Icon(
                playing ? LucideIcons.pause : LucideIcons.play,
                size: IconSz.nav,
                color: s.enabled ? C.bg0 : C.textOff,
              ),
            ),
            // Focus ring: 1 px textHi, offset 2 px from the button.
            if (s.focused)
              Positioned(
                left: -3,
                top: -3,
                right: -3,
                bottom: -3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: R.control,
                    border: Border.all(color: C.textHi, width: Dim.hairline),
                  ),
                ),
              ),
          ],
        ),
      ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Row(
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
      ),
    );
  }
}

class _Volume extends ConsumerWidget {
  const _Volume();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vol = ref.watch(playerProvider.select((s) => s.volume));
    final c = ref.read(playerProvider.notifier);
    return Row(
      children: [
        AfIconButton(
          icon: vol == 0
              ? LucideIcons.volumeX
              : vol < 0.5
              ? LucideIcons.volume1
              : LucideIcons.volume2,
          tooltip: vol == 0 ? 'Unmute' : 'Mute',
          size: IconSz.nav,
          onPressed: () => c.toggleMute(),
        ),
        const SizedBox(width: S.s2),
        Expanded(
          child: AfSlider(
            value: vol,
            semanticLabel: 'Volume',
            fill: C.textMid,
            onChanged: (v) => c.setVolume(v),
          ),
        ),
        const SizedBox(width: S.s3),
        SizedBox(
          width: S.s6 + S.s2,
          child: Text(
            '${(vol * 100).round()}',
            style: AfType.desktop.numS,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
