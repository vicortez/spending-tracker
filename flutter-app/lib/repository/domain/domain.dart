import 'dart:convert';
import 'package:spending_tracker/repository/interfaces/mappable.dart';

class DomainEntity implements Mappable {
  int id;
  String name;

  static const PERSIST_NAME = 'domains';

  DomainEntity({required this.id, required this.name});

  factory DomainEntity.fromJson(Map<String, dynamic> jsonData) {
    return DomainEntity(id: jsonData['id'], name: jsonData['name']);
  }

  @override
  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static String encodeMany(List<DomainEntity> domains) =>
      json.encode(domains.map<Map<String, dynamic>>((domain) => domain.toMap()).toList());

  static List<DomainEntity> decodeMany(String domainsStr) =>
      (json.decode(domainsStr) as List<dynamic>)
          .map<DomainEntity>((item) => DomainEntity.fromJson(item))
          .toList();
}
