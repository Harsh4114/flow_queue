import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../database/database_service.dart';
import '../database/queue_queries.dart';
import '../enums/queue_priority.dart';
import '../enums/queue_state.dart';
import '../models/queue_task.dart';
import '../services/id_service.dart';
import '../streams/queue_stream.dart';
import '../utils/priority_mapper.dart';
import 'queue_worker.dart';
import 'task_executor.dart';

/// Lightweight persistent SQLite-backed queue engine.
class FlowQueue {
  /// SQLite table used by this queue instance.
  late final String tableName = DatabaseService.normalizeTableName(_tableName);

  final String _tableName;

  Database? _database;

  final QueueWorker _worker = QueueWorker();
  final TaskExecutor _executor = TaskExecutor();
  final Map<String, Future<void> Function()> _memoryFunctions = {};

  /// Creates a queue that persists tasks in [tableName].
  FlowQueue(String tableName) : _tableName = tableName;

  /// Opens the SQLite database and prepares this queue table.
  Future<void> init() async {
    _database = await DatabaseService.init(tableName);
  }

  /// Adds a task to the queue and starts processing pending work.
  Future<String> add({
    required String processName,
    required QueuePriority priority,
    required Future<void> Function() function,
  }) async {
    final database = await _ensureInitialized();
    final id = IdService.generate();

    _memoryFunctions[id] = function;

    await database.insert(
      tableName,
      {
        'process_id': id,
        'parent_process_id': null,
        'process_name': processName,
        'state': QueueState.pending.name,
        'retry_count': 0,
        'priority': getPriorityValue(priority),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );

    unawaited(_startProcessing());

    return id;
  }

  /// Returns the persisted task for [processId].
  Future<QueueTask> getTask(String processId) async {
    final database = await _ensureInitialized();
    final result = await database.query(
      tableName,
      where: 'process_id = ?',
      whereArgs: [processId],
      limit: 1,
    );

    if (result.isEmpty) {
      throw StateError('Queue task not found: $processId');
    }

    return QueueTask.fromMap(result.first);
  }

  /// Returns the current state for [processId].
  Future<QueueState> getState(String processId) async {
    final task = await getTask(processId);

    return task.state;
  }

  /// Streams state updates for [processId].
  Stream<QueueTask> listen(String processId) {
    return QueueStream.controller.stream.where(
      (task) => task.processId == processId,
    );
  }

  /// Creates a new pending task from an existing task.
  Future<String> retry(String processId) async {
    final database = await _ensureInitialized();
    final oldTask = await getTask(processId);
    final newId = IdService.generate();
    final function = _memoryFunctions[processId];

    if (function != null) {
      _memoryFunctions[newId] = function;
    }

    await database.insert(
      tableName,
      {
        'process_id': newId,
        'parent_process_id': processId,
        'process_name': oldTask.processName,
        'state': QueueState.pending.name,
        'retry_count': oldTask.retryCount + 1,
        'priority': getPriorityValue(oldTask.priority),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );

    unawaited(_startProcessing());

    return newId;
  }

  Future<void> _startProcessing() async {
    final database = await _ensureInitialized();

    await _worker.start(() async {
      while (true) {
        final result = await database.rawQuery(
          QueueQueries.fetchNextTask(tableName),
        );

        if (result.isEmpty) {
          break;
        }

        final task = result.first;
        final processId = task['process_id'].toString();

        await _setState(processId, QueueState.inProgress);

        try {
          final function = _memoryFunctions[processId];

          if (function != null) {
            await _executor.execute(function);
          }

          await _setState(processId, QueueState.success);
        } catch (_) {
          await _setState(processId, QueueState.failed);
        }
      }
    });
  }

  Future<void> _setState(String processId, QueueState state) async {
    final database = await _ensureInitialized();

    await database.update(
      tableName,
      {'state': state.name},
      where: 'process_id = ?',
      whereArgs: [processId],
    );

    QueueStream.controller.add(await getTask(processId));
  }

  Future<Database> _ensureInitialized() async {
    if (_database != null) {
      return _database!;
    }

    await init();

    return _database!;
  }
}
