import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';

/// Persist drafts and submitted records per signed-in user.
abstract class CaseStudyLocalRepository {
  Future<CaseStudyDraft?> loadDraft(String userId);

  Future<void> saveDraft(String userId, CaseStudyDraft draft);

  Future<void> clearDraft(String userId);

  Future<List<CaseStudyRecord>> loadRecords(String userId);

  Future<CaseStudyRecord?> getRecord(
    String userId,
    String recordId,
  );

  Future<void> saveRecords(
    String userId,
    List<CaseStudyRecord> records,
  );

  /// Ensures storage schema; v1 clears box on mismatch.
  Future<void> ensureReady();
}
