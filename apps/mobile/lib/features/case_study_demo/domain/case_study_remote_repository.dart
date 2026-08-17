import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';

/// Remote (Supabase-backed) persistence and playback helpers for the case study.
///
/// Domain contracts are Supabase-agnostic. Implementations live under `data/`.
abstract class CaseStudyRemoteRepository {
  /// Uploads a local clip file and returns a Supabase Storage object key.
  Future<String> uploadClip({
    required String caseId,
    required String questionId,
    required String localPath,
  });

  /// Writes a remote draft row (`status='draft'`) with any known remote keys.
  Future<void> upsertRemoteDraft({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
  });

  /// Finalizes the remote row as submitted.
  Future<void> finalizeRemoteSubmission({
    required String caseId,
    required String doctorName,
    required CaseStudyCaseType caseType,
    required String notes,
    required Map<String, String> remoteObjectKeysByQuestion,
    required DateTime submittedAtUtc,
  });

  /// Lists submitted cases for the current Supabase user.
  Future<List<RemoteCaseStudySummary>> listSubmittedCases();

  /// Gets a submitted case with full remote answers.
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required String caseId,
  });

  /// Creates a signed URL for playback from an object key.
  Future<String> createSignedPlaybackUrl({
    required String objectKey,
    required Duration ttl,
  });
}

/// Maximum TTL for signed clip playback URLs (long sessions should refresh).
const Duration kCaseStudySignedPlaybackUrlTtl = Duration(hours: 24);

class const RemoteCaseStudySummary({
  required final String caseId,
  required final DateTime submittedAtUtc,
  required final String doctorName,
  required final CaseStudyCaseType caseType,
  required final String notes,
});

class const RemoteCaseStudyDetail({
  required super.caseId,
  required super.submittedAtUtc,
  required super.doctorName,
  required super.caseType,
  required super.notes,
  required final Map<String, String> remoteObjectKeysByQuestion,
}) extends RemoteCaseStudySummary;
