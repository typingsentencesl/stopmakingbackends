import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/player_controller.dart';
import '../sources/local/tag_reader.dart';
import 'services.dart';

/// Shows the system file picker for audio files, reads their tags and
/// either replaces the queue ([playNow]) or appends to it.
Future<void> openFiles(
  BuildContext context,
  WidgetRef ref, {
  required bool playNow,
}) async {
  final files = await FilePicker.pickFiles(
    dialogTitle: playNow ? 'Open audio files' : 'Add audio files to the queue',
    type: FileType.custom,
    allowedExtensions: [for (final e in audioExtensions) e.substring(1)],
  );
  final paths = [
    for (final f in files)
      if (f.path != null) f.path!,
  ];
  if (paths.isEmpty) return;
  await openPaths(
    ref.read(servicesProvider),
    ref.read(playerProvider.notifier),
    paths,
    playNow: playNow,
  );
}

/// Shared by the picker and by paths passed on the command line
/// ("Open with AFTRBURNR" in Explorer).
Future<void> openPaths(
  Services s,
  PlayerController player,
  List<String> paths, {
  required bool playNow,
}) async {
  final tracks = await s.local.importFiles(paths);
  if (tracks.isEmpty) return;
  if (playNow) {
    await player.playTracks(tracks);
  } else {
    await player.playLast(tracks);
  }
}
