import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';

/// In-progress case metadata + per-question clip paths (local files).
// check-ignore: freezed_preferred - demo model (kept lightweight)
class CaseStudyDraft extends Equatable {
  const CaseStudyDraft({
    required this.caseId,
    required this.doctorName,
    required this.caseType,
    required this.notes,
    required this.answers,
    required this.remoteObjectKeysByQuestion,
    required this.currentQuestionIndex,
    required this.phase,
  });

  factory CaseStudyDraft.fresh({required final String caseId}) {
    return CaseStudyDraft(
      caseId: caseId,
      doctorName: '',
      caseType: null,
      notes: '',
      answers: const <String, String>{},
      remoteObjectKeysByQuestion: const <String, String>{},
      currentQuestionIndex: 0,
      phase: CaseStudyDraftPhase.metadata,
    );
  }

  final String caseId;
  final String doctorName;
  final CaseStudyCaseType? caseType;
  final String notes;
  final Map<String, String> answers;

  /// Supabase object keys for uploaded clips (keyed by question id).
  ///
  /// This must stay separate from [answers] because [answers] are local file paths
  /// used for in-progress playback.
  final Map<String, String> remoteObjectKeysByQuestion;
  final int currentQuestionIndex;
  final CaseStudyDraftPhase phase;

  bool get hasMetadata => doctorName.trim().isNotEmpty && caseType != null;

  bool get isComplete => CaseStudyQuestions.isCompleteAnswers(answers);

  CaseStudyQuestionId get currentQuestionId =>
      CaseStudyQuestions.orderedIds[currentQuestionIndex.clamp(
        0,
        CaseStudyQuestions.orderedIds.length - 1,
      )];

  CaseStudyDraft copyWith({
    final String? caseId,
    final String? doctorName,
    final CaseStudyCaseType? caseType,
    final bool clearCaseType = false,
    final String? notes,
    final Map<String, String>? answers,
    final Map<String, String>? remoteObjectKeysByQuestion,
    final int? currentQuestionIndex,
    final CaseStudyDraftPhase? phase,
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

  Map<String, Object?> toJson() => <String, Object?>{
    'caseId': caseId,
    'doctorName': doctorName,
    'caseType': caseType?.storageName,
    'notes': notes,
    'answers': answers,
    'remoteObjectKeysByQuestion': remoteObjectKeysByQuestion,
    'currentQuestionIndex': currentQuestionIndex,
    'phase': phase.name,
  };

  static CaseStudyDraft? fromJson(final Map<String, Object?>? json) {
    if (json == null) return null;
    try {
      final Map<String, dynamic> answersRaw = Map<String, dynamic>.from(
        json['answers'] as Map? ?? const {},
      );
      final Map<String, String> answers = answersRaw.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      );

      final Map<String, dynamic> remoteRaw = Map<String, dynamic>.from(
        json['remoteObjectKeysByQuestion'] as Map? ?? const {},
      );
      final Map<String, String> remoteObjectKeysByQuestion = remoteRaw.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      );

      return CaseStudyDraft(
        caseId: json['caseId'] as String? ?? '',
        doctorName: json['doctorName'] as String? ?? '',
        caseType: CaseStudyCaseTypeX.tryParse(json['caseType'] as String?),
        notes: json['notes'] as String? ?? '',
        answers: answers,
        remoteObjectKeysByQuestion: remoteObjectKeysByQuestion,
        currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
        phase:
            CaseStudyDraftPhaseX.tryParse(json['phase'] as String?) ??
            CaseStudyDraftPhase.metadata,
      );
    } on Object {
      return null;
    }
  }

  // check-ignore: small payload (<8KB) - demo draft
  static String encode(final CaseStudyDraft draft) => jsonEncode(
    draft.toJson(),
  );

  static CaseStudyDraft? decode(final String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      // check-ignore: small payload (<8KB) - demo draft
      final Object? parsed = jsonDecode(
        raw,
      );
      if (parsed is Map<String, Object?>) {
        return CaseStudyDraft.fromJson(parsed);
      }
      if (parsed is Map) {
        return CaseStudyDraft.fromJson(
          parsed.map(
            (final dynamic k, final dynamic v) =>
                MapEntry(k.toString(), v as Object?),
          ),
        );
      }
    } on Object {
      return null;
    }
    return null;
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
  static CaseStudyDraftPhase? tryParse(final String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final CaseStudyDraftPhase v in CaseStudyDraftPhase.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}
