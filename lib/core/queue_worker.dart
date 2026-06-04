/// Ensures queue processing runs on a single sequential worker.
class QueueWorker {
  bool _isRunning = false;
  bool _shouldRunAgain = false;

  /// Whether the worker is currently processing tasks.
  bool get isRunning => _isRunning;

  /// Starts the worker if it is not already running.
  ///
  /// When start is requested while the worker is already active, one extra pass
  /// is queued so tasks added near the end of the current pass are not stranded.
  Future<void> start(Future<void> Function() callback) async {
    if (_isRunning) {
      _shouldRunAgain = true;
      return;
    }

    _isRunning = true;

    try {
      do {
        _shouldRunAgain = false;
        await callback();
      } while (_shouldRunAgain);
    } finally {
      _isRunning = false;
    }
  }
}
