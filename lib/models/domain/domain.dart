import 'dart:convert';

// TODO extends persistable?
class Domain {
  int id;
  String name;

  static const PERSIST_NAME = "domains";

  Domain({required this.id, required this.name});

  factory Domain.fromJson(Map<String, dynamic> jsonData) {
    return Domain(
      id: jsonData['id'],
      name: jsonData['name'],
    );
  }

  static Map<String, dynamic> toMap(Domain domain) => {
        'id': domain.id,
        'name': domain.name,
      };

  static String encodeMany(List<Domain> domains) => json.encode(
        domains.map<Map<String, dynamic>>((domain) => Domain.toMap(domain)).toList(),
      );

  static List<Domain> decodeMany(String domains) =>
      (json.decode(domains) as List<dynamic>).map<Domain>((item) => Domain.fromJson(item)).toList();
}
