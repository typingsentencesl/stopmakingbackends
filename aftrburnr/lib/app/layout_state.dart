import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services.dart';

/// Panel visibility, remembered between launches.
class LayoutState {
  const LayoutState({this.nowPlaying = true});
  final bool nowPlaying;
}

final layoutProvider = NotifierProvider<LayoutController, LayoutState>(
  LayoutController.new,
);

class LayoutController extends Notifier<LayoutState> {
  static const _key = 'ui.nowPlayingPanel';

  @override
  LayoutState build() {
    Future.microtask(() async {
      final v = await ref.read(servicesProvider).settings.read(_key);
      if (v is bool && ref.mounted) state = LayoutState(nowPlaying: v);
    });
    return const LayoutState();
  }

  Future<void> toggleNowPlaying() async {
    state = LayoutState(nowPlaying: !state.nowPlaying);
    await ref.read(servicesProvider).settings.write(_key, state.nowPlaying);
  }
}
