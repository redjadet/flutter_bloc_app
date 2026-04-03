import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';

enum CaseStudyHydrationStatus { initial, loading, ready }

// check-ignore: freezed_preferred - demo state (kept lightweight)
class CaseStudySessionState extends Equatable {
  const CaseStudySessionState({
    required this.hydration,
    required this.draft,
    this.pickErrorKey,
    this.isSubmitting = false,
    this.submitError = false,
    this.submitLocalHistoryFailed = false,
    this.submitProgress = 0,
    this.submitProgressDeterminate = true,
  });

  final CaseStudyHydrationStatus hydration;
  final CaseStudyDraft draft;
  final String? pickErrorKey;
  final bool isSubmitting;
  final bool submitError;

  /// Remote submission finished but persisting local history/draft failed.
  /// When true, submitError is also true; use for clearer UX and retry.
  final bool submitLocalHistoryFailed;
  final double submitProgress;

  /// When false (local-only mock submit), UI shows an indeterminate bar.
  final bool submitProgressDeterminate;

  CaseStudySessionState copyWith({
    final CaseStudyHydrationStatus? hydration,
    final CaseStudyDraft? draft,
    final String? pickErrorKey,
    final bool clearPickError = false,
    final bool? isSubmitting,
    final bool? submitError,
    final bool? submitLocalHistoryFailed,
    final bool clearSubmitLocalHistoryFailed = false,
    final double? submitProgress,
    final bool clearSubmitProgress = false,
    final bool? submitProgressDeterminate,
  }) {
    final bool nextSubmitLocalHistoryFailed;
    if (clearSubmitLocalHistoryFailed) {
      nextSubmitLocalHistoryFailed = false;
    } else {
      nextSubmitLocalHistoryFailed = submitLocalHistoryFailed ?? this.submitLocalHistoryFailed;
    }
    return CaseStudySessionState(
      hydration: hydration ?? this.hydration,
      draft: draft ?? this.draft,
      pickErrorKey: clearPickError ? null : (pickErrorKey ?? this.pickErrorKey),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
      submitLocalHistoryFailed: nextSubmitLocalHistoryFailed,
      submitProgress: clearSubmitProgress ? 0 : (submitProgress ?? this.submitProgress),
      submitProgressDeterminate: submitProgressDeterminate ?? this.submitProgressDeterminate,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    hydration,
    draft,
    pickErrorKey,
    isSubmitting,
    submitError,
    submitLocalHistoryFailed,
    submitProgress,
    submitProgressDeterminate,
  ];
}
