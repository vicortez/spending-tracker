import 'dart:convert';

// TODO extends persistable?
class Category {
  String name;
  bool enabled;

  static const PERSIST_NAME = "categories";

  Category({required this.name, required this.enabled});

  Category.name(String name) : this(name: name, enabled: true);

  factory Category.fromJson(Map<String, dynamic> jsonData) {
    return Category(
      name: jsonData['name'],
      enabled: jsonData['enabled'],
    );
  }

  static Map<String, dynamic> toMap(Category category) => {
        'name': category.name,
        'enabled': category.enabled,
      };

  static String encode(List<Category> categories) => json.encode(
        categories
            .map<Map<String, dynamic>>((category) => Category.toMap(category))
            .toList(),
      );

  static List<Category> decode(String categories) =>
      (json.decode(categories) as List<dynamic>)
          .map<Category>((item) => Category.fromJson(item))
          .toList();
}

List<Category> getDefaultCategories(){
  return [
    Category(name: "Sushi", enabled: true),
    Category(name: "Restaurants", enabled: true),
  ];
}