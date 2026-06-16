import 'dart:typed_data';

import 'package:flutter_bloc_app/core/supabase/edge_then_tables.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_mime.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_case_study_remote_repository_queries.part.dart';

class SupabaseCaseStudyRemoteRepository implements CaseStudyRemoteRepository {
  const SupabaseCaseStudyRemoteRepository({
    required this._clipFileStore,
  });

  final CaseStudyClipFileStore _clipFileStore;

  static const String _bucket = 'case_study_videos';
  static const Duration _maxTtl = kCaseStudySignedPlaybackUrlTtl;

  @override
  Future<String> uploadClip({
    required final String caseId,
    required final String questionId,
    required final String localPath,
  }) async {
    ensureSupabaseConfigured();
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Supabase user is not signed in');
    }

    final String clipId = DateTime.now().microsecondsSinceEpoch.toString();
    final String ext = fileExtensionForCaseStudyVideoPath(localPath);
    final String objectKey =
        'user/${user.id}/case/$caseId/question/$questionId/$clipId.$ext';

    final List<int> bytes = await _clipFileStore.readClipBytes(localPath);

    try {
      await Supabase.instance.client.storage
          .from(_bucket)
          .uploadBinary(
            objectKey,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              contentType: mimeTypeForCaseStudyVideoPath(localPath),
            ),
          );
      return objectKey;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteRepository.uploadClip',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> upsertRemoteDraft({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
  }) async {
    await upsertRow(
      caseId: caseId,
      doctorName: doctorName,
      caseType: caseType,
      notes: notes,
      status: 'draft',
      submittedAtUtc: null,
      remoteAnswers: remoteObjectKeysByQuestion,
    );
  }

  @override
  Future<void> finalizeRemoteSubmission({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final Map<String, String> remoteObjectKeysByQuestion,
    required final DateTime submittedAtUtc,
  }) async {
    await upsertRow(
      caseId: caseId,
      doctorName: doctorName,
      caseType: caseType,
      notes: notes,
      status: 'submitted',
      submittedAtUtc: submittedAtUtc.toUtc(),
      remoteAnswers: remoteObjectKeysByQuestion,
    );
  }

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() =>
      listSubmittedCasesImpl();

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required final String caseId,
  }) => getSubmittedCaseImpl(caseId: caseId);

  @override
  Future<String> createSignedPlaybackUrl({
    required final String objectKey,
    required final Duration ttl,
  }) async {
    ensureSupabaseConfigured();
    final Duration capped = ttl > _maxTtl ? _maxTtl : ttl;

    try {
      final response = await Supabase.instance.client.storage
          .from(_bucket)
          .createSignedUrl(objectKey, capped.inSeconds);
      return response;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteRepository.createSignedPlaybackUrl',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}
