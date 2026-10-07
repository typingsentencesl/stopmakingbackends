import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// A rounded `bg1` panel floating on the canvas (DESIGN.md §6).
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.width});
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: C.bg1, borderRadius: R.panel),
      child: child,
    );
  }
}
