import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';

/// Persist drafts and submitted records per signed-in user.
abstract class CaseStudyLocalRepository {
  Future<CaseStudyDraft?> loadDraft(final String userId);

  Future<void> saveDraft(final String userId, final CaseStudyDraft draft);

  Future<void> clearDraft(final String userId);

  Future<List<CaseStudyRecord>> loadRecords(final String userId);

  Future<CaseStudyRecord?> getRecord(
    final String userId,
    final String recordId,
  );

  Future<void> saveRecords(
    final String userId,
    final List<CaseStudyRecord> records,
  );

  /// Ensures storage schema; v1 clears box on mismatch.
  Future<void> ensureReady();
}
