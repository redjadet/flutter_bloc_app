import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:ilkersevim_retry/ilkersevim_retry.dart';

const RetryPolicy _caseStudyLocalPersistRetryPolicy = RetryPolicy(
  baseDelay: Duration(milliseconds: 50),
  maxDelay: Duration(milliseconds: 200),
  jitter: false,
);

/// Persists a submitted case to local history and seeds a fresh draft.
class PersistCaseStudySubmissionUseCase {
  const PersistCaseStudySubmissionUseCase({
    required final CaseStudyLocalRepository localRepository,
    required this._newCaseId,
  }) : _local = localRepository;

  final CaseStudyLocalRepository _local;
  final String Function() _newCaseId;

  Future<CaseStudyDraft> call({
    required final String userId,
    required final CaseStudyDraft draft,
    required final DateTime submittedAtUtc,
    required final CaseStudyCaseType caseType,
    required final RetryDelay retryDelay,
  }) {
    return _caseStudyLocalPersistRetryPolicy.executeWithRetry<CaseStudyDraft>(
      delay: retryDelay,
      action: () async {
        final List<CaseStudyRecord> records = await _local.loadRecords(userId);
        final CaseStudyRecord record = CaseStudyRecord(
          id: draft.caseId,
          submittedAt: submittedAtUtc,
          doctorName: draft.doctorName,
          caseType: caseType,
          notes: draft.notes,
          answers: Map<String, String>.from(draft.answers),
        );
        // A failed fresh-draft write retries this whole action. Replace the
        // same case ID so a partial prior attempt cannot duplicate history.
        final List<CaseStudyRecord> nextRecords = <CaseStudyRecord>[
          record,
          ...records.where((final item) => item.id != record.id),
        ];
        await _local.saveRecords(userId, nextRecords);
        await _local.clearDraft(userId);
        final CaseStudyDraft fresh = CaseStudyDraft.fresh(caseId: _newCaseId());
        await _local.saveDraft(userId, fresh);
        return fresh;
      },
    );
  }
}
