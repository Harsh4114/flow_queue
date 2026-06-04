/// SQL query builders used by the queue database layer.
class QueueQueries {
  /// Returns a query that fetches the highest-priority pending task using FIFO
  /// ordering when priorities match.
  static String fetchNextTask(String tableName) {
    return '''
      SELECT * FROM $tableName
      WHERE state = 'pending'
      ORDER BY priority DESC, created_at ASC
      LIMIT 1
    ''';
  }
}
