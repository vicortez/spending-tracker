/// Interface for entities that can be persisted to storage
abstract class Persistable {
  /// Returns the persistence key used to store this entity type
  String getPersistenceKey();
}
