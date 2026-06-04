import 'package:flow_queue/flow_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QueueTask serializes to map', () {
    final task = QueueTask(
      processId: 'task-id',
      parentProcessId: null,
      processName: 'upload_post',
      state: QueueState.pending,
      retryCount: 0,
      priority: QueuePriority.high,
      createdAt: 123,
    );

    expect(task.toMap(), {
      'process_id': 'task-id',
      'parent_process_id': null,
      'process_name': 'upload_post',
      'state': 'pending',
      'retry_count': 0,
      'priority': 3,
      'created_at': 123,
    });
  });

  test('QueueTask deserializes from map', () {
    final task = QueueTask.fromMap({
      'process_id': 'retry-id',
      'parent_process_id': 'task-id',
      'process_name': 'upload_post',
      'state': 'failed',
      'retry_count': 1,
      'priority': 2,
      'created_at': 456,
    });

    expect(task.processId, 'retry-id');
    expect(task.parentProcessId, 'task-id');
    expect(task.processName, 'upload_post');
    expect(task.state, QueueState.failed);
    expect(task.retryCount, 1);
    expect(task.priority, QueuePriority.moderate);
    expect(task.createdAt, 456);
  });
}
