import 'dart:convert';

// TODO extends persistable?
class Category {
  int id;
  String name;
  bool enabled;
  int? domainId;

  static const PERSIST_NAME = "categories";

  Category({required this.id, required this.name, required this.enabled, this.domainId});

  factory Category.fromJson(Map<String, dynamic> jsonData) {
    return Category(
      id: jsonData['id'],
      name: jsonData['name'],
      enabled: jsonData['enabled'],
      domainId: jsonData['domainId'],
    );
  }

  static Map<String, dynamic> toMap(Category category) => {
        'id': category.id,
        'name': category.name,
        'enabled': category.enabled,
        'domainId': category.domainId,
      };

  static String encode(List<Category> categories) => json.encode(
        categories.map<Map<String, dynamic>>((category) => Category.toMap(category)).toList(),
      );

  static List<Category> decode(String categories) =>
      (json.decode(categories) as List<dynamic>).map<Category>((item) => Category.fromJson(item)).toList();
}
