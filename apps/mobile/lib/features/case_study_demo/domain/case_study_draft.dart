import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';

/// In-progress case metadata + per-question clip paths (local files).
// check-ignore: freezed_preferred - demo model (kept lightweight)
class const CaseStudyDraft({
  required final String caseId,
  required final String doctorName,
  required final CaseStudyCaseType? caseType,
  required final String notes,
  required final Map<String, String> answers,

  /// Supabase object keys for uploaded clips (keyed by question id).
  ///
  /// This must stay separate from [answers] because [answers] are local file
  /// paths used for in-progress playback.
  required final Map<String, String> remoteObjectKeysByQuestion,
  required final int currentQuestionIndex,
  required final CaseStudyDraftPhase phase,
}) extends Equatable {
  factory CaseStudyDraft.fresh({required String caseId}) {
    return CaseStudyDraft(
      caseId: caseId,
      doctorName: '',
      caseType: null,
      notes: '',
      answers: const <String, String>{},
      remoteObjectKeysByQuestion: const <String, String>{},
      currentQuestionIndex: 0,
      phase: .metadata,
    );
  }

  bool get hasMetadata => doctorName.trim().isNotEmpty && caseType != null;

  bool get isComplete => CaseStudyQuestions.isCompleteAnswers(answers);

  CaseStudyQuestionId get currentQuestionId =>
      CaseStudyQuestions.orderedIds[currentQuestionIndex.clamp(
        0,
        CaseStudyQuestions.orderedIds.length - 1,
      )];

  CaseStudyDraft copyWith({
    String? caseId,
    String? doctorName,
    CaseStudyCaseType? caseType,
    bool clearCaseType = false,
    String? notes,
    Map<String, String>? answers,
    Map<String, String>? remoteObjectKeysByQuestion,
    int? currentQuestionIndex,
    CaseStudyDraftPhase? phase,
  }) {
    return CaseStudyDraft(
      caseId: caseId ?? this.caseId,
      doctorName: doctorName ?? this.doctorName,
      caseType: clearCaseType ? null : (caseType ?? this.caseType),
      notes: notes ?? this.notes,
      answers: answers ?? Map<String, String>.from(this.answers),
      remoteObjectKeysByQuestion:
          remoteObjectKeysByQuestion ??
          Map<String, String>.from(this.remoteObjectKeysByQuestion),
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      phase: phase ?? this.phase,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    caseId,
    doctorName,
    caseType,
    notes,
    answers,
    remoteObjectKeysByQuestion,
    currentQuestionIndex,
    phase,
  ];
}

enum CaseStudyDraftPhase {
  metadata,
  recording,
  reviewing,
}

extension CaseStudyDraftPhaseX on CaseStudyDraftPhase {
  static CaseStudyDraftPhase? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final CaseStudyDraftPhase v in CaseStudyDraftPhase.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}
