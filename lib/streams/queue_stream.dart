import 'dart:async';

import '../models/queue_task.dart';

/// Shared broadcast stream for queue state changes.
class QueueStream {
  static final StreamController<QueueTask> controller =
      StreamController<QueueTask>.broadcast();
}
