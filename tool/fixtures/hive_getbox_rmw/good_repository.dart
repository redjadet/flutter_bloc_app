// Fixture: full RMW inside runWithBox — per-box mutex held.
// Used by tool/check_hive_getbox_rmw.sh self-test. Not compiled.

class GoodHiveNotesRepository {
  Future<void> save(Object note) => runWithBox((box) async {
    final existing = box.get('notes') as List? ?? [];
    existing.add(note);
    await box.put('notes', existing);
  });

  Future<T> runWithBox<T>(Future<T> Function(dynamic box) action) async =>
      throw UnimplementedError();
}
