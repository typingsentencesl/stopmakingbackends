// Enforces the "never" list from docs/DESIGN.md §12 over lib/.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList();

  String rel(File f) => f.path.replaceAll(r'\', '/');

  /// Strips line comments so prose like "no gradients" doesn't trip a rule.
  String code(File f) => f
      .readAsLinesSync()
      .map((l) {
        final i = l.indexOf('//');
        return i < 0 ? l : l.substring(0, i);
      })
      .join('\n');

  void forbid(String what, RegExp re, {Set<String> allowIn = const {}}) {
    test('no $what', () {
      final hits = <String>[];
      for (final f in files) {
        if (allowIn.any((a) => rel(f).endsWith(a))) continue;
        final src = code(f);
        for (final m in re.allMatches(src)) {
          final line = src.substring(0, m.start).split('\n').length;
          hits.add('${rel(f)}:$line  ${m.group(0)}');
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  }

  test('lib/ has dart files', () => expect(files, isNotEmpty));

  forbid('gradients', RegExp(r'\b(Linear|Radial|Sweep)Gradient\b'));
  forbid('blur or glass', RegExp(r'\bBackdropFilter\b|ImageFilter\.blur'));
  forbid(
    'shadows outside the drag proxy',
    RegExp(r'\bBoxShadow\b|\belevation:\s*[1-9]'),
    allowIn: {'design/widgets/drag_proxy.dart'},
  );
  forbid('Material icons', RegExp(r'\bIcons\.[a-z]'));
  forbid('Cupertino icons', RegExp(r'\bCupertinoIcons\b'));
  forbid(
    'bouncy curves',
    RegExp(
      r'Curves\.(elastic\w*|bounce\w*|easeOutBack|easeInBack|easeInOutBack)',
    ),
  );
  forbid(
    'hex colors outside tokens',
    RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)'),
    allowIn: {'design/tokens.dart'},
  );
  forbid(
    'Material ink and buttons',
    RegExp(
      r'\b(InkWell|InkResponse|ElevatedButton|TextButton|OutlinedButton|'
      r'FilledButton|IconButton|FloatingActionButton|Card|ListTile|'
      r'PopupMenuButton|Chip|Slider|Switch|Checkbox|AppBar|NavigationRail|'
      r'BottomNavigationBar|Drawer)\(',
    ),
  );

  test('no motion longer than 200 ms in UI code', () {
    final re = RegExp(r'Duration\(\s*milliseconds:\s*(\d+)\s*\)');
    final hits = <String>[];
    for (final f in files) {
      final p = rel(f);
      // Engine timers and save debounces aren't motion.
      if (p.contains('/audio/') ||
          p.contains('/data/') ||
          p.contains('/sources/')) {
        continue;
      }
      if (p.endsWith('design/tokens.dart') || p.endsWith('design/theme.dart')) {
        continue;
      }
      for (final m in re.allMatches(code(f))) {
        if (int.parse(m.group(1)!) > 200) hits.add('$p  ${m.group(0)}');
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('radius is 0, 4, 8 or a pill only (DESIGN.md §5)', () {
    final re = RegExp(r'Radius\.circular\(\s*([\d.]+)\s*\)');
    final hits = <String>[];
    for (final f in files) {
      for (final m in re.allMatches(code(f))) {
        final v = double.parse(m.group(1)!);
        if (!{0.0, 4.0, 8.0, 999.0}.contains(v)) {
          hits.add('${rel(f)}  ${m.group(0)}');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
