import 'dart:convert';

import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';

/// Wire DTO for [CaseStudyRecord] Hive persistence.
class CaseStudyRecordDto {
  const CaseStudyRecordDto({
    required this.id,
    required this.submittedAt,
    required this.doctorName,
    required this.caseType,
    required this.notes,
    required this.answers,
  });

  CaseStudyRecordDto.fromDomain(final CaseStudyRecord record)
    : id = record.id,
      submittedAt = record.submittedAt,
      doctorName = record.doctorName,
      caseType = record.caseType,
      notes = record.notes,
      answers = Map<String, String>.from(record.answers);

  final String id;
  final DateTime submittedAt;
  final String doctorName;
  final CaseStudyCaseType caseType;
  final String notes;
  final Map<String, String> answers;

  CaseStudyRecord toDomain() => CaseStudyRecord(
    id: id,
    submittedAt: submittedAt,
    doctorName: doctorName,
    caseType: caseType,
    notes: notes,
    answers: answers,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'submittedAt': submittedAt.toIso8601String(),
    'doctorName': doctorName,
    'caseType': caseType.storageName,
    'notes': notes,
    'answers': answers,
  };

  static CaseStudyRecordDto? fromJson(final Map<String, Object?>? json) {
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
        (final k, final v) => MapEntry(k, v?.toString() ?? ''),
      );

      return CaseStudyRecordDto(
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
    records
        .map((final r) => CaseStudyRecordDto.fromDomain(r).toJson())
        .toList(),
  );

  static List<CaseStudyRecord> decodeList(final String? raw) {
    if (raw == null || raw.isEmpty) return <CaseStudyRecord>[];
    try {
      // check-ignore: small payload (<8KB) - demo history
      final Object? parsed = jsonDecode(raw);
      if (parsed is! List) return <CaseStudyRecord>[];
      final List<CaseStudyRecord> out = <CaseStudyRecord>[];
      for (final Object? item in parsed) {
        final CaseStudyRecordDto? dto = switch (item) {
          final Map<String, Object?> map => CaseStudyRecordDto.fromJson(map),
          final Map<Object?, Object?> map => CaseStudyRecordDto.fromJson(
            map.map(
              (final dynamic k, final dynamic v) =>
                  MapEntry(k.toString(), v as Object?),
            ),
          ),
          _ => null,
        };
        if (dto != null) out.add(dto.toDomain());
      }
      return out;
    } on Object {
      return <CaseStudyRecord>[];
    }
  }
}
