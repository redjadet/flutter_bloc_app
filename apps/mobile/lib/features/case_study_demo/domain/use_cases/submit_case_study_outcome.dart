import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/use_cases/submit_case_study_use_case.dart'
    show SubmitCaseStudyUseCase;

/// Outcome of [SubmitCaseStudyUseCase].
sealed class SubmitCaseStudyOutcome {
  const SubmitCaseStudyOutcome();
}

/// Submit + local history persist succeeded; [freshDraft] is the next empty draft.
final class SubmitCaseStudySuccess extends SubmitCaseStudyOutcome {
  const SubmitCaseStudySuccess({
    required this.freshDraft,
    required this.submittedAtUtc,
  });

  final CaseStudyDraft freshDraft;
  final DateTime submittedAtUtc;
}

/// Submit failed. When [remoteSubmitFinished] is true, remote finalize
/// succeeded but local history persist failed (caller may retry persist).
final class SubmitCaseStudyFailure extends SubmitCaseStudyOutcome {
  const SubmitCaseStudyFailure({
    required this.error,
    required this.stackTrace,
    required this.remoteSubmitFinished,
    this.submittedAtUtc,
  });

  final Object error;
  final StackTrace stackTrace;
  final bool remoteSubmitFinished;
  final DateTime? submittedAtUtc;
}
