import '../enums/queue_priority.dart';
import '../enums/queue_state.dart';
import '../utils/priority_mapper.dart';

/// A persisted queue task record.
class QueueTask {
  /// Unique identifier for this task.
  final String processId;

  /// The task id that created this task via retry, if any.
  final String? parentProcessId;

  /// Developer-provided task name.
  final String processName;

  /// Current task state.
  final QueueState state;

  /// Number of retry generations before this task.
  final int retryCount;

  /// Task priority.
  final QueuePriority priority;

  /// Creation timestamp in milliseconds since epoch.
  final int createdAt;

  /// Creates a queue task model.
  const QueueTask({
    required this.processId,
    required this.parentProcessId,
    required this.processName,
    required this.state,
    required this.retryCount,
    required this.priority,
    required this.createdAt,
  });

  /// Creates a [QueueTask] from a SQLite row.
  factory QueueTask.fromMap(Map<String, Object?> map) {
    return QueueTask(
      processId: map['process_id'].toString(),
      parentProcessId: map['parent_process_id']?.toString(),
      processName: map['process_name'].toString(),
      state: _mapState(map['state'].toString()),
      retryCount: map['retry_count'] as int,
      priority: mapPriorityValue(map['priority'] as int),
      createdAt: map['created_at'] as int,
    );
  }

  /// Converts this task to a SQLite row map.
  Map<String, Object?> toMap() {
    return {
      'process_id': processId,
      'parent_process_id': parentProcessId,
      'process_name': processName,
      'state': state.name,
      'retry_count': retryCount,
      'priority': getPriorityValue(priority),
      'created_at': createdAt,
    };
  }

  static QueueState _mapState(String state) {
    switch (state) {
      case 'pending':
        return QueueState.pending;
      case 'inProgress':
        return QueueState.inProgress;
      case 'success':
        return QueueState.success;
      default:
        return QueueState.failed;
    }
  }
}
