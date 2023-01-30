// Global state
import 'dart:convert';
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
  // var cat = Category(name: "Sushi", enabled: true);
  // CategoryState.addCategory(cat);

  void setCategories(List<Category> newCategories) {
    categories = newCategories;
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void genNext() {
    current = "Current number: ${Random().nextInt(100)}";
    notifyListeners();
  }

  List<Category> getEnabledCategories() {
    return categories.where((element) => element.enabled).toList();
  }

  void loadCategories(SharedPreferences prefs) {
    final String? categoriesStr = prefs.getString(Category.PERSIST_NAME);
    if (categoriesStr != null) {
      categories = Category.decode(categoriesStr);
      notifyListeners();
    }
  }

  void addCategory(Category category) {
    categories.add(category);
    notifyListeners();
  }
}
