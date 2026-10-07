import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/player_controller.dart';
import 'open_files.dart';

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class PreviousIntent extends Intent {
  const PreviousIntent();
}

class SeekByIntent extends Intent {
  const SeekByIntent(this.seconds);
  final int seconds;
}

class VolumeByIntent extends Intent {
  const VolumeByIntent(this.delta);
  final double delta;
}

class ShuffleIntent extends Intent {
  const ShuffleIntent();
}

class RepeatIntent extends Intent {
  const RepeatIntent();
}

class OpenFilesIntent extends Intent {
  const OpenFilesIntent({required this.playNow});
  final bool playNow;
}

class MuteIntent extends Intent {
  const MuteIntent();
}

/// App-wide keys (ARCHITECTURE.md §8). Ctrl and Cmd are both bound so the
/// same map works on macOS later. Text fields swallow Space and letters
/// before these see them.
Map<ShortcutActivator, Intent> globalShortcuts() {
  final m = <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.space): const TogglePlayIntent(),
    const SingleActivator(LogicalKeyboardKey.mediaPlayPause):
        const TogglePlayIntent(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackNext):
        const NextIntent(),
    const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious):
        const PreviousIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowRight, shift: true):
        const SeekByIntent(10),
    const SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true):
        const SeekByIntent(-10),
    const SingleActivator(LogicalKeyboardKey.keyS): const ShuffleIntent(),
    const SingleActivator(LogicalKeyboardKey.keyR): const RepeatIntent(),
    const SingleActivator(LogicalKeyboardKey.keyM): const MuteIntent(),
  };
  for (final mod in [true, false]) {
    SingleActivator a(LogicalKeyboardKey k, {bool shift = false}) =>
        SingleActivator(k, control: mod, meta: !mod, shift: shift);
    m[a(LogicalKeyboardKey.arrowRight)] = const NextIntent();
    m[a(LogicalKeyboardKey.arrowLeft)] = const PreviousIntent();
    m[a(LogicalKeyboardKey.arrowUp)] = const VolumeByIntent(0.05);
    m[a(LogicalKeyboardKey.arrowDown)] = const VolumeByIntent(-0.05);
    m[a(LogicalKeyboardKey.keyO)] = const OpenFilesIntent(playNow: true);
    m[a(LogicalKeyboardKey.keyO, shift: true)] = const OpenFilesIntent(
      playNow: false,
    );
  }
  return m;
}

Map<Type, Action<Intent>> globalActions(BuildContext context, WidgetRef ref) {
  PlayerController c() => ref.read(playerProvider.notifier);
  return {
    TogglePlayIntent: CallbackAction<TogglePlayIntent>(
      onInvoke: (_) => c().togglePlay(),
    ),
    NextIntent: CallbackAction<NextIntent>(onInvoke: (_) => c().next()),
    PreviousIntent: CallbackAction<PreviousIntent>(
      onInvoke: (_) => c().previous(),
    ),
    SeekByIntent: CallbackAction<SeekByIntent>(
      onInvoke: (i) => c().seekBy(Duration(seconds: i.seconds)),
    ),
    VolumeByIntent: CallbackAction<VolumeByIntent>(
      onInvoke: (i) => c().setVolume(ref.read(playerProvider).volume + i.delta),
    ),
    ShuffleIntent: CallbackAction<ShuffleIntent>(
      onInvoke: (_) => c().cycleShuffle(),
    ),
    RepeatIntent: CallbackAction<RepeatIntent>(
      onInvoke: (_) => c().cycleRepeat(),
    ),
    MuteIntent: CallbackAction<MuteIntent>(onInvoke: (_) => c().toggleMute()),
    OpenFilesIntent: CallbackAction<OpenFilesIntent>(
      onInvoke: (i) => openFiles(context, ref, playNow: i.playNow),
    ),
  };
}
