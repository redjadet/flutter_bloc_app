import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed drafts and records for the case-study demo (dedicated box).
class CaseStudyHiveLocalRepository implements CaseStudyLocalRepository {
  CaseStudyHiveLocalRepository({required final HiveService hiveService})
    : _hiveService = hiveService;

  static const String boxName = 'case_study_demo';
  static const String schemaKey = 'schemaVersion';
  static const int currentSchema = 1;

  final HiveService _hiveService;
  Box<dynamic>? _cachedBox;

  Future<Box<dynamic>> _openBox() async {
    if (_cachedBox case final Box<dynamic> box? when box.isOpen) {
      return box;
    }
    final Box<dynamic> box = await _hiveService.openBox(boxName);
    _cachedBox = box;
    return box;
  }

  @override
  Future<void> ensureReady() async {
    final Box<dynamic> box = await _openBox();
    final dynamic ver = box.get(schemaKey);
    if (ver != currentSchema) {
      await box.clear();
      await box.put(schemaKey, currentSchema);
    }
  }

  String _draftKey(final String userId) => 'draft_v1_$userId';

  String _recordsKey(final String userId) => 'records_v1_$userId';

  void _assertUserId(final String userId) {
    if (userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'must be non-empty');
    }
  }

  @override
  Future<CaseStudyDraft?> loadDraft(final String userId) async {
    _assertUserId(userId);
    await ensureReady();
    final Box<dynamic> box = await _openBox();
    final Object? raw = box.get(_draftKey(userId));
    if (raw is! String) return null;
    return CaseStudyDraft.decode(raw);
  }

  @override
  Future<void> saveDraft(
    final String userId,
    final CaseStudyDraft draft,
  ) async {
    _assertUserId(userId);
    await ensureReady();
    final Box<dynamic> box = await _openBox();
    await box.put(_draftKey(userId), CaseStudyDraft.encode(draft));
  }

  @override
  Future<void> clearDraft(final String userId) async {
    _assertUserId(userId);
    await ensureReady();
    final Box<dynamic> box = await _openBox();
    await box.delete(_draftKey(userId));
  }

  @override
  Future<List<CaseStudyRecord>> loadRecords(final String userId) async {
    _assertUserId(userId);
    await ensureReady();
    final Box<dynamic> box = await _openBox();
    final Object? raw = box.get(_recordsKey(userId));
    if (raw is! String) return <CaseStudyRecord>[];
    return CaseStudyRecord.decodeList(raw);
  }

  @override
  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  ) async {
    final List<CaseStudyRecord> list = await loadRecords(userId);
    for (final CaseStudyRecord r in list) {
      if (r.id == recordId) return r;
    }
    return null;
  }

  @override
  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> records,
  ) async {
    _assertUserId(userId);
    await ensureReady();
    final Box<dynamic> box = await _openBox();
    await box.put(_recordsKey(userId), CaseStudyRecord.encodeList(records));
  }
}
