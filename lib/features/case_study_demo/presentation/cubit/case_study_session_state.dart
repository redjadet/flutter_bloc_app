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
    this.submitProgress = 0,
    this.submitProgressDeterminate = true,
  });

  final CaseStudyHydrationStatus hydration;
  final CaseStudyDraft draft;
  final String? pickErrorKey;
  final bool isSubmitting;
  final bool submitError;
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
    final double? submitProgress,
    final bool clearSubmitProgress = false,
    final bool? submitProgressDeterminate,
  }) {
    return CaseStudySessionState(
      hydration: hydration ?? this.hydration,
      draft: draft ?? this.draft,
      pickErrorKey: clearPickError ? null : (pickErrorKey ?? this.pickErrorKey),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
      submitProgress: clearSubmitProgress
          ? 0
          : (submitProgress ?? this.submitProgress),
      submitProgressDeterminate:
          clearSubmitProgress ||
          (submitProgressDeterminate ?? this.submitProgressDeterminate),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    hydration,
    draft,
    pickErrorKey,
    isSubmitting,
    submitError,
    submitProgress,
    submitProgressDeterminate,
  ];
}
