// foundation_stub.dart
// Stub definitions of ChangeNotifier and kDebugMode for CLI usage

/// Minimal ChangeNotifier that won’t pull in dart:ui
class ChangeNotifier {
  bool _disposed = false;

  /// No-op when not disposed
  void notifyListeners() {
    if (!_disposed) {
      // intentionally empty
    }
  }

  /// Mark this instance as disposed
  @override
  void dispose() {
    _disposed = true;
  }
}

/// Always false in a non-Flutter (CLI) environment
const bool kDebugMode = false;