import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Three vertical bars that step between fixed heights every 400 ms while
/// audio plays and freeze when paused. They step; they never ease or bounce.
class PlayingBars extends StatefulWidget {
  const PlayingBars({super.key, required this.playing, this.size = 12});

  final bool playing;
  final double size;

  @override
  State<PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<PlayingBars> {
  static const _frames = [
    [0.45, 1.0, 0.7],
    [0.85, 0.55, 1.0],
    [0.6, 0.8, 0.4],
    [1.0, 0.4, 0.75],
  ];
  int _frame = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(PlayingBars old) {
    super.didUpdateWidget(old);
    if (old.playing != widget.playing) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _timer = null;
    final reduce = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (widget.playing && !reduce) {
      _timer = Timer.periodic(M.barsStep, (_) {
        if (mounted) setState(() => _frame = (_frame + 1) % _frames.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = _frames[_frame];
    final s = widget.size;
    final w = (s / 5).floorToDouble().clamp(2.0, 4.0);
    return SizedBox.square(
      dimension: s,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final h in f)
            Container(
              width: w,
              height: (s * h).roundToDouble(),
              color: C.flame,
            ),
        ],
      ),
    );
  }
}
