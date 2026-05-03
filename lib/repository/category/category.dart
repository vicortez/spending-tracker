import 'package:spending_tracker/repository/interfaces/mappable.dart';
import 'package:spending_tracker/repository/interfaces/persistable.dart';

class CategoryEntity implements Mappable, Persistable {
  int id;
  String name;
  bool enabled;
  int? domainId;

  static const PERSIST_NAME = 'categories';

  CategoryEntity({required this.id, required this.name, required this.enabled, this.domainId});

  factory CategoryEntity.fromMap(Map<String, dynamic> jsonData) {
    return CategoryEntity(
      id: jsonData['id'],
      name: jsonData['name'],
      enabled: jsonData['enabled'],
      domainId: jsonData['domainId'],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'enabled': enabled,
        'domainId': domainId,
      };

  @override
  String getPersistenceKey() => PERSIST_NAME;
}
