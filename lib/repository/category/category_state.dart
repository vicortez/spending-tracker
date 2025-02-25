import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';

import 'category.dart';

class CategoryState extends ChangeNotifier {
  List<CategoryEntity> _categories = [];

  SharedPreferences? prefs;

  List<CategoryEntity> get categories => List.from(_categories);

  void setCategories(List<CategoryEntity> newCategories, {bool syncStorage = true}) {
    _categories = newCategories;
    notifyListeners();
    if (syncStorage && prefs != null) {
      updateLocalStorage();
    }
  }

  List<CategoryEntity> getCategories({enabledOnly = true}) {
    if (enabledOnly) {
      return _categories.where((element) => element.enabled).toList();
    }
    return _categories;
  }

  void loadCategoriesFromLocalStorage(SharedPreferences prefs) {
    this.prefs = prefs;
    final String? categoriesStr = prefs.getString(CategoryEntity.PERSIST_NAME);
    if (categoriesStr != null) {
      _categories = CategoryEntity.decode(categoriesStr);
      notifyListeners();
    }
  }

  void setDataFromImport(dynamic data) {
    dynamic value = data ?? "[]";
    prefs?.setString(CategoryEntity.PERSIST_NAME, value);
    loadCategoriesFromLocalStorage(prefs!);
  }

  void addCategory(String name) {
    CategoryEntity category = CategoryEntity(id: getNextId(), name: name, enabled: true);
    _categories.add(category);

    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  bool updateCategory(int id, String newName, int? newDomainId, bool? enabled) {
    CategoryEntity? category = _categories.firstWhereOrNull((element) => element.id == id);
    if (category == null) {
      return false;
    }
    category.name = newName;
    category.domainId = newDomainId;
    if (enabled != null) {
      category.enabled = enabled;
    }
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
    return true;
  }

  void removeCategoryByName(String name) {
    _categories.removeWhere((cat) => cat.name == name);
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void removeCategory(int id) {
    _categories.removeWhere((cat) => cat.id == id);
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  int getNextId() {
    if (_categories.isEmpty) {
      return 1;
    } else {
      return _categories.map((e) => e.id).reduce(max) + 1;
    }
  }

  void updateLocalStorage() {
    prefs?.setString(CategoryEntity.PERSIST_NAME, CategoryEntity.encode(_categories));
  }

  bool existsCategoryWithDomain(int domainId) {
    return _categories.any((cat) => cat.domainId == domainId);
  }

  bool existsCategoryWithName(String name) {
    return _categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase());
  }

  List<CategoryEntity> getExampleCategories() {
    return [
      CategoryEntity(id: getNextId(), name: "Example Category 1", enabled: true),
      CategoryEntity(id: getNextId() + 1, name: "Example Category 2", enabled: true),
      // Category(name: "Sushi", enabled: true),
      // Category(name: "Restaurants", enabled: true),
    ];
  }
}
