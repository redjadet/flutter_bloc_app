import 'dart:io';

import 'package:flutter_bloc_app/core/supabase/edge_then_tables.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCaseStudyRemoteRepository implements CaseStudyRemoteRepository {
  const SupabaseCaseStudyRemoteRepository();

  static const String _bucket = 'case_study_videos';
  static const Duration _maxTtl = Duration(hours: 24);

  @override
  Future<String> uploadClip({
    required final String caseId,
    required final String questionId,
    required final String localPath,
  }) async {
    ensureSupabaseConfigured();
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Supabase user is not signed in');
    }

    final String clipId = DateTime.now().microsecondsSinceEpoch.toString();
    final String objectKey =
        'user/${user.id}/case/$caseId/question/$questionId/$clipId.mp4';

    final File file = File(localPath);

    try {
      await Supabase.instance.client.storage
          .from(_bucket)
          .upload(
            objectKey,
            file,
            fileOptions: const FileOptions(
              contentType: 'video/mp4',
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
    await _upsertRow(
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
    await _upsertRow(
      caseId: caseId,
      doctorName: doctorName,
      caseType: caseType,
      notes: notes,
      status: 'submitted',
      submittedAtUtc: submittedAtUtc.toUtc(),
      remoteAnswers: remoteObjectKeysByQuestion,
    );
  }

  Future<void> _upsertRow({
    required final String caseId,
    required final String doctorName,
    required final CaseStudyCaseType caseType,
    required final String notes,
    required final String status,
    required final DateTime? submittedAtUtc,
    required final Map<String, String> remoteAnswers,
  }) async {
    ensureSupabaseConfigured();
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Supabase user is not signed in');
    }

    try {
      await Supabase.instance.client.from('case_studies').upsert(
        <String, Object?>{
          'case_id': caseId,
          'user_id': user.id,
          'status': status,
          'submitted_at': submittedAtUtc?.toIso8601String(),
          'doctor_name': doctorName,
          'case_type': caseType.storageName,
          'notes': notes,
          'remote_answers': remoteAnswers,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteRepository._upsertRow',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<RemoteCaseStudySummary>> listSubmittedCases() async {
    ensureSupabaseConfigured();
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Supabase user is not signed in');
    }

    try {
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('case_studies')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'submitted')
          .order('submitted_at', ascending: false);

      final List<RemoteCaseStudySummary> out = <RemoteCaseStudySummary>[];
      for (final Map<String, dynamic> row in data) {
        final String? id = row['case_id']?.toString();
        final String? submittedAt = row['submitted_at']?.toString();
        final String? doctorName = row['doctor_name']?.toString();
        final String? caseTypeRaw = row['case_type']?.toString();
        if (id == null ||
            submittedAt == null ||
            doctorName == null ||
            caseTypeRaw == null) {
          continue;
        }
        final CaseStudyCaseType? type = CaseStudyCaseTypeX.tryParse(
          caseTypeRaw,
        );
        if (type == null) continue;
        final DateTime at =
            DateTime.tryParse(submittedAt)?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
        out.add(
          RemoteCaseStudySummary(
            caseId: id,
            submittedAtUtc: at,
            doctorName: doctorName,
            caseType: type,
            notes: row['notes']?.toString() ?? '',
          ),
        );
      }
      return out;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteRepository.listSubmittedCases',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<RemoteCaseStudyDetail?> getSubmittedCase({
    required final String caseId,
  }) async {
    ensureSupabaseConfigured();
    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Supabase user is not signed in');
    }

    try {
      final Map<String, dynamic>? data = await Supabase.instance.client
          .from('case_studies')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'submitted')
          .eq('case_id', caseId)
          .maybeSingle();

      if (data == null) return null;

      final String? submittedAt = data['submitted_at']?.toString();
      final String? doctorName = data['doctor_name']?.toString();
      final String? caseTypeRaw = data['case_type']?.toString();
      if (submittedAt == null || doctorName == null || caseTypeRaw == null) {
        return null;
      }
      final CaseStudyCaseType? type = CaseStudyCaseTypeX.tryParse(caseTypeRaw);
      if (type == null) return null;

      final DateTime at =
          DateTime.tryParse(submittedAt)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

      final Map<String, String> remoteAnswers = <String, String>{};
      final Object? rawAnswers = data['remote_answers'];
      if (rawAnswers is Map<dynamic, dynamic>) {
        for (final MapEntry<dynamic, dynamic> entry in rawAnswers.entries) {
          final String k = entry.key.toString();
          final String v = entry.value?.toString() ?? '';
          if (k.isNotEmpty && v.isNotEmpty) remoteAnswers[k] = v;
        }
      }

      return RemoteCaseStudyDetail(
        caseId: caseId,
        submittedAtUtc: at,
        doctorName: doctorName,
        caseType: type,
        notes: data['notes']?.toString() ?? '',
        remoteObjectKeysByQuestion: remoteAnswers,
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteRepository.getSubmittedCase',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

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
