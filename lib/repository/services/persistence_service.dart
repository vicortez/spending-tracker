import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/interfaces/mappable.dart';

/// Service for persisting and loading entities to/from local storage
class PersistenceService {
  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  /// Saves a list of records to local storage
  ///
  /// [records] - List of entities to save
  /// [persistenceKey] - The key to use for storage
  Future<void> saveRecords<T extends Mappable>(
    List<T> records,
    String persistenceKey,
  ) async {
    final String encodedData = json.encode(
      records.map((e) => e.toMap()).toList(),
    );
    await _prefs.setString(persistenceKey, encodedData);
  }

  /// Loads a list of records from local storage
  ///
  /// [fromMap] - Factory function to create entity from Map
  /// [persistenceKey] - The key used for storage
  /// Returns list of entities, or empty list if none found
  Future<List<T>> loadRecords<T extends Mappable>(
    T Function(Map<String, dynamic>) fromMap,
    String persistenceKey,
  ) async {
    final String? encodedData = _prefs.getString(persistenceKey);
    if (encodedData == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(encodedData) as List<dynamic>;
      return decoded
          .map<T>((item) => fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if decoding fails
      return [];
    }
  }

  /// Saves raw string data to local storage (for import/export)
  ///
  /// [data] - The raw string data to save
  /// [persistenceKey] - The key to use for storage
  Future<void> saveRawData(String data, String persistenceKey) async {
    await _prefs.setString(persistenceKey, data);
  }

  /// Gets raw string data from local storage (for import/export)
  ///
  /// [persistenceKey] - The key used for storage
  /// Returns the raw string data, or null if not found
  String? getRawData(String persistenceKey) {
    return _prefs.getString(persistenceKey);
  }
}
