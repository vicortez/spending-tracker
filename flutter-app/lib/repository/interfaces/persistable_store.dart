import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for providers that manage persistent data
abstract class PersistableStore<T> extends ChangeNotifier {
  /// Loads data from local storage
  Future<void> loadFromLocalStorage(SharedPreferences prefs);

  /// Updates the in-memory data and optionally triggers persistence
  void set(T data, {bool syncStorage = true});

  /// Persists current in-memory state to storage
  Future<void> persistChanges();

  /// Updates data from an imported JSON representation
  Future<void> setDataFromImport(dynamic data);
}
