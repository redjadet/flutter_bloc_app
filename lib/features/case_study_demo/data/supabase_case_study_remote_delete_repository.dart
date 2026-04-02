import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCaseStudyRemoteDeleteRepository
    implements CaseStudyRemoteDeleteRepository {
  const SupabaseCaseStudyRemoteDeleteRepository();

  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {
    final String trimmed = caseId.trim();
    if (trimmed.isEmpty) return;
    if (!SupabaseBootstrapService.isSupabaseInitialized) return;

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'delete-case-study',
        body: <String, Object?>{'caseId': trimmed},
      );

      if (response.status != 200) {
        throw StateError('Edge delete-case-study failed: ${response.status}');
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteDeleteRepository.deleteCaseStudyRemote',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}
