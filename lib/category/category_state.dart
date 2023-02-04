// Global state
import 'dart:math';

import 'package:flutter/foundation.dart' hide Category;
import 'category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryState extends ChangeNotifier {
  var current = "test 2";
  var favorites = <String>[];
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

  // TODO remove
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  // TODO remove
  void genNext() {
    current = "Current number: ${Random().nextInt(100)}";
    notifyListeners();
  }

  List<Category> getEnabledCategories() {
    return categories.where((element) => element.enabled).toList();
  }

  void loadCategoriesFromLocalStorage(SharedPreferences prefs) {
    this.prefs = prefs;
    final String? categoriesStr = prefs?.getString(Category.PERSIST_NAME);
    if (categoriesStr != null) {
      categories = Category.decode(categoriesStr);
      notifyListeners();
    }
  }

  void addCategory(Category category) {
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

  void updateLocalStorage() {
    prefs?.setString(Category.PERSIST_NAME, Category.encode(categories));
  }
}
