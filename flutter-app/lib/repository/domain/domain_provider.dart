// Global state
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/interfaces/persistable_store.dart';
import 'package:spending_tracker/repository/services/persistence_service.dart';
import 'package:spending_tracker/services/logger_service.dart';

class DomainProvider with ChangeNotifier implements PersistableStore<List<DomainEntity>> {
  List<DomainEntity> domains = [];
  PersistenceService? _persistenceService;
  bool _loadSuccessful = false;
  String persistName = DomainEntity.PERSIST_NAME;

  @override
  Future<void> set(List<DomainEntity> domains, {bool syncStorage = true}) async {
    this.domains = domains;
    notifyListeners();
    if (syncStorage) {
      await persistChanges();
    }
  }

  Future<void> setDataFromImport(dynamic data) async {
    if (_persistenceService == null) return;
    dynamic value = data ?? '[]';
    await _persistenceService!.saveRawData(value, persistName);
    try {
      domains = await _persistenceService!.loadRecords(DomainEntity.fromJson, persistName);
      _loadSuccessful = true;
      notifyListeners();
    } catch (e) {
      _loadSuccessful = false;
      LoggerService.logError('Failed to load imported domains: $e');
    }
  }

  Future<bool> updateDomain(int id, String newName) async {
    DomainEntity? domain = domains.firstWhereOrNull((dom) => dom.id == id);
    if (domain == null) {
      return false;
    }

    domain.name = newName;

    await persistChanges();
    notifyListeners();
    return true;
  }

  Future<void> loadFromLocalStorage(SharedPreferences prefs) async {
    _persistenceService = PersistenceService(prefs);
    try {
      final String? encodedData = prefs.getString(persistName);
      final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

      if (encodedData == null && !isFirstRun) {
        _loadSuccessful = false;
        LoggerService.logError(
          'Critical: Storage returned null for domains, but this is not the first run. Aborting to prevent data loss.',
        );
      } else {
        domains = await _persistenceService!.loadRecords(DomainEntity.fromJson, persistName);
        _loadSuccessful = true;
      }
    } catch (e) {
      _loadSuccessful = false;
    }
    notifyListeners();
  }

  Future<void> addDomain(String name) async {
    DomainEntity domain = DomainEntity(id: getNextId(), name: name);
    domains.add(domain);
    await persistChanges();
    notifyListeners();
  }

  Future<void> removeDomain(int id) async {
    domains.removeWhere((dom) => dom.id == id);
    await persistChanges();
    notifyListeners();
  }

  Future<void> removeALl() async {
    domains.clear();
    await persistChanges();
    notifyListeners();
  }

  @override
  Future<void> persistChanges() async {
    if (_persistenceService != null) {
      if (!_loadSuccessful && domains.isNotEmpty) {
        LoggerService.logError(
          'Aborting save: Domain list was not successfully loaded from storage.',
        );
        return;
      }
      await _persistenceService!.saveRecords(domains, persistName);
    }
  }

  int getNextId() {
    if (domains.isEmpty) {
      return 1;
    } else {
      return domains.map((el) => el.id).reduce(max) + 1;
    }
  }

  bool existsDomainWithName(String name) {
    return domains.any((dom) => dom.name.toLowerCase() == name.toLowerCase());
  }
}
