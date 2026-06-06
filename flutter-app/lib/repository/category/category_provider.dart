import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/interfaces/persistable_store.dart';
import 'package:spending_tracker/repository/services/persistence_service.dart';
import 'package:spending_tracker/services/logger_service.dart';

import 'category.dart';

class CategoryProvider with ChangeNotifier implements PersistableStore<List<CategoryEntity>> {
  List<CategoryEntity> _categories = [];
  PersistenceService? _persistenceService;
  bool _loadSuccessful = false;

  List<CategoryEntity> get categories => List.from(_categories);

  @override
  void set(List<CategoryEntity> newCategories, {bool syncStorage = true}) {
    _categories = newCategories;
    notifyListeners();
    if (syncStorage) {
      persistChanges();
    }
  }

  List<CategoryEntity> getCategories({enabledOnly = true}) {
    if (enabledOnly) {
      return _categories.where((element) => element.enabled).toList();
    }
    return _categories;
  }

  Future<void> loadFromLocalStorage(SharedPreferences prefs) async {
    _persistenceService = PersistenceService(prefs);
    try {
      final String? encodedData = prefs.getString(CategoryEntity.PERSIST_NAME);
      final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

      if (encodedData == null && !isFirstRun) {
        _loadSuccessful = false;
        LoggerService.logError(
          'Critical: Storage returned null for categories, but this is not the first run. Aborting to prevent data loss.',
        );
      } else {
        _categories = await _persistenceService!.loadRecords(
          CategoryEntity.fromMap,
          CategoryEntity.PERSIST_NAME,
        );
        _loadSuccessful = true;
      }
    } catch (e) {
      _loadSuccessful = false;
    }
    notifyListeners();
  }

  Future<void> setDataFromImport(dynamic data) async {
    if (_persistenceService == null) return;

    dynamic value = data ?? '[]';
    await _persistenceService!.saveRawData(value, CategoryEntity.PERSIST_NAME);
    try {
      _categories = await _persistenceService!.loadRecords(
        CategoryEntity.fromMap,
        CategoryEntity.PERSIST_NAME,
      );
      _loadSuccessful = true;
      notifyListeners();
    } catch (e) {
      _loadSuccessful = false;
      LoggerService.logError('Failed to load imported categories: $e');
    }
  }

  Future<void> addCategory(String name) async {
    CategoryEntity category = CategoryEntity(id: getNextId(), name: name, enabled: true);
    _categories.add(category);
    await persistChanges();
    notifyListeners();
  }

  Future<bool> updateCategory(int id, String newName, int? newDomainId, bool? enabled) async {
    CategoryEntity? category = _categories.firstWhereOrNull((element) => element.id == id);
    if (category == null) {
      return false;
    }
    category.name = newName;
    category.domainId = newDomainId;
    if (enabled != null) {
      category.enabled = enabled;
    }
    await persistChanges();
    notifyListeners();
    return true;
  }

  Future<void> removeCategoryByName(String name) async {
    _categories.removeWhere((cat) => cat.name == name);
    await persistChanges();
    notifyListeners();
  }

  Future<void> removeCategory(int id) async {
    _categories.removeWhere((cat) => cat.id == id);
    await persistChanges();
    notifyListeners();
  }

  int getNextId() {
    if (_categories.isEmpty) {
      return 1;
    } else {
      return _categories.map((e) => e.id).reduce(max) + 1;
    }
  }

  @override
  Future<void> persistChanges() async {
    if (_persistenceService != null) {
      if (!_loadSuccessful && _categories.isNotEmpty) {
        LoggerService.logError(
          'Aborting save: Category list was not successfully loaded from storage.',
        );
        return;
      }
      await _persistenceService!.saveRecords(_categories, CategoryEntity.PERSIST_NAME);
    }
  }

  bool existsCategoryWithDomain(int domainId) {
    return _categories.any((cat) => cat.domainId == domainId);
  }

  bool existsCategoryWithName(String name) {
    return _categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase());
  }

  List<CategoryEntity> getExampleCategories() {
    return [
      CategoryEntity(id: getNextId(), name: 'Example Category 1', enabled: true),
      CategoryEntity(id: getNextId() + 1, name: 'Example Category 2', enabled: true),
    ];
  }
}
