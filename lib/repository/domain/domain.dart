import 'dart:convert';

// TODO extends persistable?
class DomainEntity {
  int id;
  String name;

  static const PERSIST_NAME = "domains";

  DomainEntity({required this.id, required this.name});

  factory DomainEntity.fromJson(Map<String, dynamic> jsonData) {
    return DomainEntity(
      id: jsonData['id'],
      name: jsonData['name'],
    );
  }

  static Map<String, dynamic> toMap(DomainEntity domain) => {
        'id': domain.id,
        'name': domain.name,
      };

  static String encodeMany(List<DomainEntity> domains) => json.encode(
        domains.map<Map<String, dynamic>>((domain) => DomainEntity.toMap(domain)).toList(),
      );

  static List<DomainEntity> decodeMany(String domains) =>
      (json.decode(domains) as List<dynamic>).map<DomainEntity>((item) => DomainEntity.fromJson(item)).toList();
}
