import 'dart:convert';

import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';

/// Wire DTO for [CaseStudyDraft] Hive persistence.
class CaseStudyDraftDto {
  const CaseStudyDraftDto({
    required this.caseId,
    required this.doctorName,
    required this.caseType,
    required this.notes,
    required this.answers,
    required this.remoteObjectKeysByQuestion,
    required this.currentQuestionIndex,
    required this.phase,
  });

  CaseStudyDraftDto.fromDomain(final CaseStudyDraft draft)
    : caseId = draft.caseId,
      doctorName = draft.doctorName,
      caseType = draft.caseType,
      notes = draft.notes,
      answers = Map<String, String>.from(draft.answers),
      remoteObjectKeysByQuestion = Map<String, String>.from(
        draft.remoteObjectKeysByQuestion,
      ),
      currentQuestionIndex = draft.currentQuestionIndex,
      phase = draft.phase;

  final String caseId;
  final String doctorName;
  final CaseStudyCaseType? caseType;
  final String notes;
  final Map<String, String> answers;
  final Map<String, String> remoteObjectKeysByQuestion;
  final int currentQuestionIndex;
  final CaseStudyDraftPhase phase;

  CaseStudyDraft toDomain() => CaseStudyDraft(
    caseId: caseId,
    doctorName: doctorName,
    caseType: caseType,
    notes: notes,
    answers: answers,
    remoteObjectKeysByQuestion: remoteObjectKeysByQuestion,
    currentQuestionIndex: currentQuestionIndex,
    phase: phase,
  );

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

  static CaseStudyDraftDto? fromJson(final Map<String, Object?>? json) {
    if (json == null) return null;
    try {
      final Map<String, dynamic> answersRaw = Map<String, dynamic>.from(
        json['answers'] as Map? ?? const {},
      );
      final Map<String, String> answers = answersRaw.map(
        (final k, final v) => MapEntry(k, v?.toString() ?? ''),
      );

      final Map<String, dynamic> remoteRaw = Map<String, dynamic>.from(
        json['remoteObjectKeysByQuestion'] as Map? ?? const {},
      );
      final Map<String, String> remoteObjectKeysByQuestion = remoteRaw.map(
        (final k, final v) => MapEntry(k, v?.toString() ?? ''),
      );

      return CaseStudyDraftDto(
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
  static String encode(final CaseStudyDraft draft) =>
      jsonEncode(CaseStudyDraftDto.fromDomain(draft).toJson());

  static CaseStudyDraft? decode(final String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      // check-ignore: small payload (<8KB) - demo draft
      final Object? parsed = jsonDecode(raw);
      if (parsed is Map<String, Object?>) {
        return CaseStudyDraftDto.fromJson(parsed)?.toDomain();
      }
      if (parsed is Map) {
        return CaseStudyDraftDto.fromJson(
          parsed.map(
            (final dynamic k, final dynamic v) =>
                MapEntry(k.toString(), v as Object?),
          ),
        )?.toDomain();
      }
    } on Object {
      return null;
    }
    return null;
  }
}
