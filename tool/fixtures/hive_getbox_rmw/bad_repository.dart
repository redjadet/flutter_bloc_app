// Fixture: RMW after getBox() via renamed write helper — mutex released.
// Used by tool/check_hive_getbox_rmw.sh self-test. Not compiled.

class BadHiveNotesRepository {
  Future<void> save(Object note) async {
    final box = await getBox();
    final existing = box.get('notes') as List? ?? [];
    existing.add(note);
    await _saveNotes(box, existing);
  }

  Future<void> _saveNotes(dynamic box, List<dynamic> notes) async {
    await box.put('notes', notes);
  }

  Future<dynamic> getBox() async => throw UnimplementedError();
}
