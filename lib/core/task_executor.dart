/// Executes an in-memory queue callback.
class TaskExecutor {
  /// Runs [function] and lets callers handle any thrown errors.
  Future<void> execute(Future<void> Function() function) {
    return function();
  }
}
