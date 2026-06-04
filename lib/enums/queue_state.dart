/// The lifecycle state of a queued task.
enum QueueState {
  /// The task is waiting to be executed.
  pending,

  /// The task is currently being executed by the queue worker.
  inProgress,

  /// The task completed successfully.
  success,

  /// The task failed while executing.
  failed,
}
