import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/player_controller.dart';
import '../design/tokens.dart';
import '../design/widgets/panel.dart';
import '../design/widgets/states.dart';
import '../features/library/library_panel.dart';
import '../features/now_playing/now_playing_panel.dart';
import '../features/queue/queue_page.dart';
import '../features/transport/transport_bar.dart';
import 'layout_state.dart';

/// Library | page | now playing as rounded panels on the canvas, transport
/// along the bottom (DESIGN.md §10).
class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(playerProvider.select((s) => s.error));
    // Like Spotify, the panel only appears once something is loaded.
    final hasTrack = ref.watch(
      playerProvider.select((s) => s.queue.currentEntry != null),
    );
    final showNowPlaying =
        hasTrack && ref.watch(layoutProvider.select((l) => l.nowPlaying));
    return ColoredBox(
      color: C.bg0,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dim.canvasGap,
                Dim.canvasGap,
                Dim.canvasGap,
                0,
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  // The now-playing panel gives way first on narrow windows.
                  final roomForRight =
                      c.maxWidth >=
                      Dim.libraryPanel + Dim.nowPlayingPanel + 420;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const LibraryPanel(),
                      const SizedBox(width: Dim.canvasGap),
                      Expanded(
                        child: Panel(
                          child: Column(
                            children: [
                              const Expanded(child: QueuePage()),
                              if (error != null)
                                StatusStrip(
                                  message: error,
                                  onDismiss: () => ref
                                      .read(playerProvider.notifier)
                                      .dismissError(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (showNowPlaying && roomForRight) ...[
                        const SizedBox(width: Dim.canvasGap),
                        const NowPlayingPanel(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          const TransportBar(),
        ],
      ),
    );
  }
}
