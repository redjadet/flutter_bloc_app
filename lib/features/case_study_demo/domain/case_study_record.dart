import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';

/// A submitted (mock-uploaded) case for history.
// check-ignore: freezed_preferred - demo model (kept lightweight)
class CaseStudyRecord extends Equatable {
  const CaseStudyRecord({
    required this.id,
    required this.submittedAt,
    required this.doctorName,
    required this.caseType,
    required this.notes,
    required this.answers,
  });

  final String id;
  final DateTime submittedAt;
  final String doctorName;
  final CaseStudyCaseType caseType;
  final String notes;
  final Map<String, String> answers;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'submittedAt': submittedAt.toIso8601String(),
    'doctorName': doctorName,
    'caseType': caseType.storageName,
    'notes': notes,
    'answers': answers,
  };

  static CaseStudyRecord? fromJson(final Map<String, Object?>? json) {
    if (json == null) return null;
    try {
      final String? id = json['id'] as String?;
      final String? at = json['submittedAt'] as String?;
      if (id == null || at == null) return null;
      final CaseStudyCaseType? type = CaseStudyCaseTypeX.tryParse(
        json['caseType'] as String?,
      );
      if (type == null) return null;

      final Map<String, dynamic> answersRaw = Map<String, dynamic>.from(
        json['answers'] as Map? ?? const {},
      );
      final Map<String, String> answers = answersRaw.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      );

      return CaseStudyRecord(
        id: id,
        submittedAt:
            DateTime.tryParse(at) ?? DateTime.fromMillisecondsSinceEpoch(0),
        doctorName: json['doctorName'] as String? ?? '',
        caseType: type,
        notes: json['notes'] as String? ?? '',
        answers: answers,
      );
    } on Object {
      return null;
    }
  }

  // check-ignore: small payload (<8KB) - demo history
  static String encodeList(final List<CaseStudyRecord> records) => jsonEncode(
    records.map((r) => r.toJson()).toList(),
  );

  static List<CaseStudyRecord> decodeList(final String? raw) {
    if (raw == null || raw.isEmpty) return <CaseStudyRecord>[];
    try {
      // check-ignore: small payload (<8KB) - demo history
      final Object? parsed = jsonDecode(
        raw,
      );
      if (parsed is! List) return <CaseStudyRecord>[];
      final List<CaseStudyRecord> out = <CaseStudyRecord>[];
      for (final Object? item in parsed) {
        if (item is Map<String, Object?>) {
          final CaseStudyRecord? r = CaseStudyRecord.fromJson(item);
          if (r != null) out.add(r);
        } else if (item is Map) {
          final CaseStudyRecord? r = CaseStudyRecord.fromJson(
            item.map(
              (final dynamic k, final dynamic v) =>
                  MapEntry(k.toString(), v as Object?),
            ),
          );
          if (r != null) out.add(r);
        }
      }
      return out;
    } on Object {
      return <CaseStudyRecord>[];
    }
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    submittedAt,
    doctorName,
    caseType,
    notes,
    answers,
  ];
}
