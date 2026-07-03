part of 'supabase_case_study_remote_repository.dart';

extension _SupabaseCaseStudyRemoteRepositoryQueries
    on SupabaseCaseStudyRemoteRepository {
  Future<void> upsertRow({
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

  Future<List<RemoteCaseStudySummary>> listSubmittedCasesImpl() async {
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

  Future<RemoteCaseStudyDetail?> getSubmittedCaseImpl({
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
}
