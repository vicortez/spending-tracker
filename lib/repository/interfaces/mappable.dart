/// Interface for entities that can be converted to/from Map representation
abstract class Mappable {
  /// Converts the entity to a Map
  Map<String, dynamic> toMap();

  /// Factory constructor requirement - must be implemented by subclasses
  /// Example: factory MyEntity.fromMap(Map<String, dynamic> map) => ...
}
