/// Priority levels used when selecting the next pending task.
enum QueuePriority {
  /// Lowest priority, selected after moderate and high priority tasks.
  defaultPriority,

  /// Medium priority, selected after high priority tasks.
  moderate,

  /// Highest priority, selected before moderate and default tasks.
  high,
}
