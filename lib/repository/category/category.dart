import 'dart:convert';

// TODO extends persistable?
class CategoryEntity {
  int id;
  String name;
  bool enabled;
  int? domainId;

  static const PERSIST_NAME = "categories";

  CategoryEntity({required this.id, required this.name, required this.enabled, this.domainId});

  factory CategoryEntity.fromJson(Map<String, dynamic> jsonData) {
    return CategoryEntity(
      id: jsonData['id'],
      name: jsonData['name'],
      enabled: jsonData['enabled'],
      domainId: jsonData['domainId'],
    );
  }

  static Map<String, dynamic> toMap(CategoryEntity category) => {
        'id': category.id,
        'name': category.name,
        'enabled': category.enabled,
        'domainId': category.domainId,
      };

  static String encode(List<CategoryEntity> categories) => json.encode(
        categories.map<Map<String, dynamic>>((category) => CategoryEntity.toMap(category)).toList(),
      );

  static List<CategoryEntity> decode(String categories) =>
      (json.decode(categories) as List<dynamic>).map<CategoryEntity>((item) => CategoryEntity.fromJson(item)).toList();
}
