import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/persist_case_study_submission_use_case.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/submit_case_study_outcome.dart';
import 'package:ilkersevim_retry/ilkersevim_retry.dart';

/// Multi-port submit: mock upload → optional remote clips/finalize → local history.
class SubmitCaseStudyUseCase {
  const SubmitCaseStudyUseCase({
    required final CaseStudyUploadRepository uploadRepository,
    required final CaseStudyRemoteRepository remoteRepository,
    required final CaseStudyRemoteDeleteRepository remoteDeleteRepository,
    required this._persistSubmission,
  }) : _upload = uploadRepository,
       _remote = remoteRepository,
       _remoteDelete = remoteDeleteRepository;

  final CaseStudyUploadRepository _upload;
  final CaseStudyRemoteRepository _remote;
  final CaseStudyRemoteDeleteRepository _remoteDelete;
  final PersistCaseStudySubmissionUseCase _persistSubmission;

  Future<SubmitCaseStudyOutcome> call({
    required final String userId,
    required final CaseStudyDraft draft,
    required final bool remoteSubmit,
    required final RetryDelay retryDelay,
    final void Function(double progress)? onProgress,
    final DateTime Function()? now,
  }) async {
    final CaseStudyCaseType? caseType = draft.caseType;
    if (caseType == null || !draft.isComplete) {
      return SubmitCaseStudyFailure(
        error: StateError('Case study draft incomplete'),
        stackTrace: StackTrace.current,
        remoteSubmitFinished: false,
      );
    }

    var beganRemoteCaseStudyUpload = false;
    var remoteSubmitFinished = false;
    DateTime? submittedAtUtc;

    try {
      await _upload.submitCase();

      final String caseId = draft.caseId;
      submittedAtUtc = (now ?? DateTime.now)().toUtc();

      if (remoteSubmit) {
        beganRemoteCaseStudyUpload = true;
        final int clipTotal = draft.answers.values
            .where((final path) => path.isNotEmpty)
            .length;
        final int totalSteps = clipTotal + 2;
        var done = 0;
        void reportProgress() {
          final double progress = totalSteps == 0
              ? 1
              : (done / totalSteps).clamp(0, 1);
          onProgress?.call(progress);
        }

        final Map<String, String> remoteKeys = Map<String, String>.from(
          draft.remoteObjectKeysByQuestion,
        );
        // Snapshot before await-in-loop; map getters must not be iterated live.
        final List<MapEntry<String, String>> answerEntries =
            List<MapEntry<String, String>>.from(draft.answers.entries);

        for (final MapEntry<String, String> entry in answerEntries) {
          final String questionId = entry.key;
          final String localPath = entry.value;
          if (localPath.isEmpty) continue;
          if (remoteKeys[questionId]?.isNotEmpty == true) {
            done += 1;
            reportProgress();
            continue;
          }

          final String objectKey = await _remote.uploadClip(
            caseId: caseId,
            questionId: questionId,
            localPath: localPath,
          );
          remoteKeys[questionId] = objectKey;
          done += 1;
          reportProgress();
        }

        await _remote.upsertRemoteDraft(
          caseId: caseId,
          doctorName: draft.doctorName,
          caseType: caseType,
          notes: draft.notes,
          remoteObjectKeysByQuestion: remoteKeys,
        );
        done += 1;
        reportProgress();
        await _remote.finalizeRemoteSubmission(
          caseId: caseId,
          doctorName: draft.doctorName,
          caseType: caseType,
          notes: draft.notes,
          remoteObjectKeysByQuestion: remoteKeys,
          submittedAtUtc: submittedAtUtc,
        );
        done += 1;
        reportProgress();
        onProgress?.call(1);
        remoteSubmitFinished = true;
      }

      final CaseStudyDraft fresh = await _persistSubmission(
        userId: userId,
        draft: draft,
        submittedAtUtc: submittedAtUtc,
        caseType: caseType,
        retryDelay: retryDelay,
      );
      return SubmitCaseStudySuccess(
        freshDraft: fresh,
        submittedAtUtc: submittedAtUtc,
      );
    } on Object catch (error, stackTrace) {
      if (beganRemoteCaseStudyUpload &&
          !remoteSubmitFinished &&
          draft.caseId.isNotEmpty) {
        try {
          await _remoteDelete.deleteCaseStudyRemote(caseId: draft.caseId);
        } on Object {
          // Preserve the original submission failure; cleanup is best-effort.
        }
      }
      return SubmitCaseStudyFailure(
        error: error,
        stackTrace: stackTrace,
        remoteSubmitFinished: remoteSubmitFinished,
        submittedAtUtc: submittedAtUtc,
      );
    }
  }
}
