import 'dart:math';

import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';

import 'category.dart';

class CategoryState extends ChangeNotifier {
  List<Category> categories = [
    // Category(name: "Sushi", enabled: true),
    // Category(name: "Restaurants", enabled: true),
  ];
  SharedPreferences? prefs;

  void setCategories(List<Category> newCategories, {bool syncStorage = true}) {
    categories = newCategories;
    notifyListeners();
    if (syncStorage && prefs != null) {
      updateLocalStorage();
    }
  }

  List<Category> getEnabledCategories() {
    return categories.where((element) => element.enabled).toList();
  }

  void loadCategoriesFromLocalStorage(SharedPreferences prefs) {
    this.prefs = prefs;
    final String? categoriesStr = prefs.getString(Category.PERSIST_NAME);
    if (categoriesStr != null) {
      categories = Category.decode(categoriesStr);
      notifyListeners();
    }
  }

  void setDataFromImport(dynamic data) {
    prefs?.setString(Category.PERSIST_NAME, data);
    loadCategoriesFromLocalStorage(prefs!);
  }

  void addCategory(String name) {
    Category category = Category(id: getNextId(), name: name, enabled: true);
    categories.add(category);

    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void removeCategory(String name) {
    categories.removeWhere((cat) => cat.name == name);
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  int getNextId() {
    if (categories.isEmpty) {
      return 1;
    } else {
      return categories.map((e) => e.id).reduce(max) + 1;
    }
  }

  void updateLocalStorage() {
    prefs?.setString(Category.PERSIST_NAME, Category.encode(categories));
  }
}
