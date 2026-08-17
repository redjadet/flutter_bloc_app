import 'hive_schema_migration.dart';

/// Simple in-memory schema registry.
///
/// MVP-0: schemas are provided by repositories (opt-in) or direct owners.
/// This registry exists to support future centralized validation and tooling.
class HiveSchemaRegistry {
  HiveSchemaRegistry({required Iterable<HiveBoxSchema> schemas})
    : _schemas = List<HiveBoxSchema>.unmodifiable(schemas);

  final List<HiveBoxSchema> _schemas;

  List<HiveBoxSchema> schemasForBox(String boxName) =>
      _schemas.where((s) => s.boxName == boxName).toList(growable: false);
}
