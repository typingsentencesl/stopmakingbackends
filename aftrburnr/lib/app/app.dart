import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/player_controller.dart';
import '../design/theme.dart';
import 'shell_desktop.dart';
import 'shortcuts.dart';

class AftrburnrApp extends StatelessWidget {
  const AftrburnrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFTRBURNR',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      darkTheme: buildTheme(),
      themeMode: ThemeMode.dark,
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerStatefulWidget {
  const _Root();

  @override
  ConsumerState<_Root> createState() => _RootState();
}

class _RootState extends ConsumerState<_Root> {
  late final AppLifecycleListener _life;

  @override
  void initState() {
    super.initState();
    // Make sure the controller exists (and restores the queue) at startup.
    ref.read(playerProvider);
    _life = AppLifecycleListener(
      onExitRequested: () async {
        await ref.read(playerProvider.notifier).save();
        return AppExitResponse.exit;
      },
      onPause: () => unawaited(ref.read(playerProvider.notifier).save()),
    );
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: globalShortcuts(),
      child: Actions(
        actions: globalActions(context, ref),
        child: const FocusScope(
          autofocus: true,
          child: Material(
            type: MaterialType.transparency,
            child: DesktopShell(),
          ),
        ),
      ),
    );
  }
}
