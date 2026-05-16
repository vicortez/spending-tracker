import 'package:flutter/foundation.dart';

/// Service that tracks navigation history for implementing custom back button behavior
class NavigationHistoryService extends ChangeNotifier {
  final List<String> _history = [];

  /// Get immutable copy of navigation history
  List<String> get history => List.unmodifiable(_history);

  /// Check if there's navigation history (more than one entry)
  bool get hasHistory => _history.length > 1;

  /// Get current location (last entry in history)
  String? get currentLocation => _history.isEmpty ? null : _history.last;

  /// Add a location to navigation history
  /// Avoids adding duplicate consecutive entries
  void push(String location) {
    // Avoid duplicate consecutive entries
    if (_history.isEmpty || _history.last != location) {
      _history.add(location);
      notifyListeners();

      if (kDebugMode) {
        print('Navigation History: $_history');
      }
    }
  }

  /// Remove and return the previous location from history
  /// Returns null if history has only one entry or is empty
  String? pop() {
    if (_history.length > 1) {
      _history.removeLast();
      notifyListeners();

      if (kDebugMode) {
        print('Navigation History after pop: $_history');
      }

      return _history.last;
    }
    return null;
  }

  /// Clear all navigation history
  void clear() {
    _history.clear();
    notifyListeners();

    if (kDebugMode) {
      print('Navigation History cleared');
    }
  }

  /// Get previous location without popping
  /// Returns null if history has only one entry or is empty
  String? getPrevious() {
    if (_history.length > 1) {
      return _history[_history.length - 2];
    }
    return null;
  }
}
