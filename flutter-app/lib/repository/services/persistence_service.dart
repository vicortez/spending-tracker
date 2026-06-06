import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/interfaces/mappable.dart';
import 'package:spending_tracker/services/logger_service.dart';

/// Service for persisting and loading entities to/from local storage
class PersistenceService {
  final SharedPreferences _prefs;
  static Future<void> _lastSave = Future.value();

  PersistenceService(this._prefs);

  /// Resets the save queue (mostly for tests)
  static void resetQueue() {
    _lastSave = Future.value();
  }

  /// Saves a list of records to local storage sequentially
  ///
  /// [records] - List of entities to save
  /// [persistenceKey] - The key to use for storage
  Future<void> saveRecords<T extends Mappable>(List<T> records, String persistenceKey) async {
    final completer = Completer<void>();
    final previousSave = _lastSave;
    _lastSave = completer.future;

    try {
      await previousSave;
    } catch (_) {
      // Ignore errors from previous saves in the queue
    }

    try {
      final String encodedData = json.encode(records.map((e) => e.toMap()).toList());
      await _prefs.setString(persistenceKey, encodedData);
    } catch (e) {
      LoggerService.logError('Failed to save $persistenceKey: $e');
    } finally {
      completer.complete();
    }
  }

  /// Loads a list of records from local storage
  ///
  /// [fromMap] - Factory function to create entity from Map
  /// [persistenceKey] - The key used for storage
  /// Returns list of entities, or empty list if none found
  /// Throws FormatException if data is corrupted
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
      return decoded.map<T>((item) => fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      LoggerService.logError('Corruption detected in $persistenceKey: $e');
      throw FormatException('Failed to decode $persistenceKey: $e');
    }
  }

  /// Saves raw string data to local storage (for import/export)
  ///
  /// [data] - The raw string data to save
  /// [persistenceKey] - The key to use for storage
  Future<void> saveRawData(String data, String persistenceKey) async {
    try {
      await _prefs.setString(persistenceKey, data);
    } catch (e) {
      LoggerService.logError('Failed to save raw $persistenceKey: $e');
    }
  }

  /// Gets raw string data from local storage (for import/export)
  ///
  /// [persistenceKey] - The key used for storage
  /// Returns the raw string data, or null if not found
  String? getRawData(String persistenceKey) {
    try {
      return _prefs.getString(persistenceKey);
    } catch (e) {
      LoggerService.logError('Failed to read raw $persistenceKey: $e');
      return null;
    }
  }
}
