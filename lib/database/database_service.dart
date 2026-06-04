import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens and prepares the SQLite database used by flow queues.
class DatabaseService {
  static Database? _database;

  /// Opens the database and ensures [tableName] exists.
  static Future<Database> init(String tableName) async {
    final normalizedTableName = normalizeTableName(tableName);

    _database ??= await openDatabase(
      join(await getDatabasesPath(), 'flow_queue.db'),
      version: 1,
    );

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS $normalizedTableName (
        process_id TEXT PRIMARY KEY,
        parent_process_id TEXT,
        process_name TEXT NOT NULL,
        state TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        priority INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    return _database!;
  }

  /// Returns a validated SQLite table identifier for [tableName].
  static String normalizeTableName(String tableName) {
    final trimmed = tableName.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError.value(tableName, 'tableName', 'Must not be empty.');
    }

    final validIdentifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

    if (!validIdentifier.hasMatch(trimmed)) {
      throw ArgumentError.value(
        tableName,
        'tableName',
        'Must be a valid SQLite identifier containing only letters, numbers, and underscores, and must not start with a number.',
      );
    }

    return trimmed;
  }
}
