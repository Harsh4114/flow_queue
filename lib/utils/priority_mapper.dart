import '../enums/queue_priority.dart';

/// Converts a [QueuePriority] into its persisted numeric value.
int getPriorityValue(QueuePriority priority) {
  switch (priority) {
    case QueuePriority.high:
      return 3;
    case QueuePriority.moderate:
      return 2;
    case QueuePriority.defaultPriority:
      return 1;
  }
}

/// Converts a persisted priority value into a [QueuePriority].
QueuePriority mapPriorityValue(int value) {
  switch (value) {
    case 3:
      return QueuePriority.high;
    case 2:
      return QueuePriority.moderate;
    default:
      return QueuePriority.defaultPriority;
  }
}
