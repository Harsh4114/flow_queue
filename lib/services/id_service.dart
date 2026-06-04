import 'package:uuid/uuid.dart';

/// Generates unique ids for queue tasks.
class IdService {
  static final Uuid _uuid = const Uuid();

  /// Generates a v4 UUID string.
  static String generate() {
    return _uuid.v4();
  }
}
