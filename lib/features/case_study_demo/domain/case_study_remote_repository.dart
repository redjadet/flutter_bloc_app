import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';

/// Remote (Supabase-backed) persistence and playback helpers for the case study.
///
/// Domain contracts are Supabase-agnostic. Implementations live under `data/`.
abstract class CaseStudyRemoteRepository {
  /// Uploads a local clip file and returns a Supabase Storage object key.
  Future<String> uploadClip({
    required final String caseId,
    required final String questionId,
    required final String localPath,
  });

  /// Writes a remote draft row (`status='draft'`) with any known remote keys.
  Future<void> upsertRemoteDraft({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
  });

  /// Finalizes the remote row as submitted.
  Future<void> finalizeRemoteSubmission({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
    required final DateTime submittedAtUtc,
  });

  /// Lists submitted cases for the current Supabase user.
  Future<List<RemoteCaseStudySummary>> listSubmittedCases();

  /// Gets a submitted case with full remote answers.
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required final String caseId,
  });

  /// Creates a signed URL for playback from an object key.
  Future<String> createSignedPlaybackUrl({
    required final String objectKey,
    required final Duration ttl,
  });
}

class RemoteCaseStudySummary {
  const RemoteCaseStudySummary({
    required this.caseId,
    required this.submittedAtUtc,
    required this.doctorName,
    required this.caseType,
    required this.notes,
  });

  final String caseId;
  final DateTime submittedAtUtc;
  final String doctorName;
  final CaseStudyCaseType caseType;
  final String notes;
}

class RemoteCaseStudyDetail extends RemoteCaseStudySummary {
  const RemoteCaseStudyDetail({
    required super.caseId,
    required super.submittedAtUtc,
    required super.doctorName,
    required super.caseType,
    required super.notes,
    required this.remoteObjectKeysByQuestion,
  });

  final Map<String, String> remoteObjectKeysByQuestion;
}
