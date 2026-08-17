import 'dart:convert';

import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';

/// Wire DTO for [CaseStudyDraft] Hive persistence.
class const CaseStudyDraftDto({
  required final String caseId,
  required final String doctorName,
  required final CaseStudyCaseType? caseType,
  required final String notes,
  required final Map<String, String> answers,
  required final Map<String, String> remoteObjectKeysByQuestion,
  required final int currentQuestionIndex,
  required final CaseStudyDraftPhase phase,
}) {
  CaseStudyDraftDto.fromDomain(CaseStudyDraft draft)
    : this(
        caseId: draft.caseId,
        doctorName: draft.doctorName,
        caseType: draft.caseType,
        notes: draft.notes,
        answers: Map<String, String>.from(draft.answers),
        remoteObjectKeysByQuestion: Map<String, String>.from(
          draft.remoteObjectKeysByQuestion,
        ),
        currentQuestionIndex: draft.currentQuestionIndex,
        phase: draft.phase,
      );

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

  static CaseStudyDraftDto? fromJson(Map<String, Object?>? json) {
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
  static String encode(CaseStudyDraft draft) => jsonEncode(
    CaseStudyDraftDto.fromDomain(draft).toJson(),
  );

  static CaseStudyDraft? decode(String? raw) {
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
            (dynamic k, dynamic v) => MapEntry(k.toString(), v as Object?),
          ),
        )?.toDomain();
      }
    } on Object {
      return null;
    }
    return null;
  }
}
