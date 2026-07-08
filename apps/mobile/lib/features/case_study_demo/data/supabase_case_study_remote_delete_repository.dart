import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/app/http/supabase/supabase_session_manager.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utilities/utilities.dart';

class SupabaseCaseStudyRemoteDeleteRepository
    implements CaseStudyRemoteDeleteRepository {
  SupabaseCaseStudyRemoteDeleteRepository({
    SupabaseSessionManager? sessionManager,
  }) : _sessionManager = sessionManager ?? SupabaseSessionManager();

  final SupabaseSessionManager _sessionManager;

  static String? _readSupabaseAnonKey() {
    final String anonKey = SecretConfig.supabaseAnonKey?.trim() ?? '';
    return anonKey.isEmpty ? null : anonKey;
  }

  void _debugLogAuthSnapshot(final String label) {
    if (!kDebugMode) return;
    if (!SupabaseBootstrapService.isSupabaseInitialized) return;
    try {
      final client = Supabase.instance.client;
      final Session? session = client.auth.currentSession;
      final User? user = client.auth.currentUser;
      final DateTime nowUtc = DateTime.now().toUtc();
      final int? expiresAt = session?.expiresAt;
      final DateTime? expiresAtUtc = expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true);
      final String? apiKey = _readSupabaseAnonKey();
      AppLogger.debug(
        [
          'Supabase delete-case-study auth snapshot ($label):',
          'url=${Supabase.instance.client.rest.url}',
          'hasSession=${session != null}',
          'userId=${user?.id ?? 'null'}',
          'hasApiKey=${apiKey != null}',
          'expiresAtUtc=${expiresAtUtc?.toIso8601String() ?? 'null'}',
          'nowUtc=${nowUtc.toIso8601String()}',
        ].join(' '),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteDeleteRepository._debugLogAuthSnapshot',
        error,
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteCaseStudyRemote({required final String caseId}) async {
    final String trimmed = caseId.trim();
    if (trimmed.isEmpty) return;
    if (!SupabaseBootstrapService.isSupabaseInitialized) return;

    try {
      _debugLogAuthSnapshot('before');
      final String? token = _sessionManager.getAccessToken();
      if (token == null || token.isEmpty) {
        throw const HttpRequestFailure(401, 'Authentication required');
      }
      await _invokeDelete(caseId: trimmed, token: token);
    } on FunctionException catch (error, stackTrace) {
      if (error.status == 401 &&
          SupabaseBootstrapService.isSupabaseInitialized) {
        try {
          _debugLogAuthSnapshot('401_before_refresh');
          final String? refreshedToken = await _sessionManager
              .refreshAccessTokenAfterUnauthorized();
          _debugLogAuthSnapshot('401_after_refresh');
          if (refreshedToken != null && refreshedToken.isNotEmpty) {
            await _invokeDelete(caseId: trimmed, token: refreshedToken);
            return;
          }
        } on Object {
          // Fall through to user-facing error.
        }
      }

      AppLogger.error(
        'SupabaseCaseStudyRemoteDeleteRepository.deleteCaseStudyRemote',
        error,
        stackTrace,
      );

      final int statusCode = error.status;
      final String message =
          (error.details is Map &&
              (error.details as Map).containsKey('message'))
          ? '${(error.details as Map)['message']}'
          : (error.reasonPhrase ?? 'Request failed');
      throw HttpRequestFailure(statusCode, message);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SupabaseCaseStudyRemoteDeleteRepository.deleteCaseStudyRemote',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _invokeDelete({
    required final String caseId,
    required final String token,
  }) async {
    final String? apiKey = _readSupabaseAnonKey();
    if (apiKey == null) {
      throw const HttpRequestFailure(
        500,
        'Supabase anon key missing (SUPABASE_ANON_KEY)',
      );
    }
    final response = await Supabase.instance.client.functions.invoke(
      'delete-case-study',
      body: <String, Object?>{'caseId': caseId},
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'apikey': apiKey,
      },
    );
    if (kDebugMode) {
      AppLogger.debug(
        'delete-case-study response: status=${response.status}',
      );
    }
    if (response.status != 200) {
      throw HttpRequestFailure(
        response.status,
        'Edge delete-case-study failed: ${response.data ?? response.status}',
      );
    }
  }
}
