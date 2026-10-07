import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

class SettingsRepo {
  SettingsRepo(this.db);
  final AppDatabase db;

  Future<Object?> read(String key) async {
    final row = await (db.select(
      db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      return jsonDecode(row.value);
    } on FormatException {
      return null;
    }
  }

  Future<void> write(String key, Object? value) async {
    await db
        .into(db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion(key: Value(key), value: Value(jsonEncode(value))),
        );
  }
}
