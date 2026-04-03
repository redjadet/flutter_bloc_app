import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCaseStudyRemoteDeleteRepository
    implements CaseStudyRemoteDeleteRepository {
  const SupabaseCaseStudyRemoteDeleteRepository();

  static String? _readSupabaseAnonKey() {
    final String anonKey = SecretConfig.supabaseAnonKey?.trim() ?? '';
    return anonKey.isEmpty ? null : anonKey;
  }

  static Future<String?> _tryExtractJwtIssuer(final String token) async {
    // JWT: header.payload.signature (base64url)
    final List<String> parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final String normalized = base64Url.normalize(parts[1]);
      final String payloadJson = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payload = await decodeJsonMap(payloadJson);
      final Object? iss = payload['iss'];
      return iss is String && iss.trim().isNotEmpty ? iss.trim() : null;
    } on Object {
      return null;
    }
  }

  Future<void> _debugLogAuthSnapshot(final String label) async {
    if (!kDebugMode) return;
    if (!SupabaseBootstrapService.isSupabaseInitialized) return;
    try {
      final client = Supabase.instance.client;
      final Session? session = client.auth.currentSession;
      final User? user = client.auth.currentUser;
      final DateTime nowUtc = DateTime.now().toUtc();
      final String? token = session?.accessToken;
      if (token != null && token.isNotEmpty) {
        AppLogger.debug('Supabase access token (debug only): $token');
      }
      final String? tokenIssuer = token == null || token.isEmpty
          ? null
          : await _tryExtractJwtIssuer(token);
      final int? expiresAt = session?.expiresAt;
      final DateTime? expiresAtUtc = expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              expiresAt * 1000,
              isUtc: true,
            );
      final String? apiKey = _readSupabaseAnonKey();
      AppLogger.debug(
        [
          'Supabase delete-case-study auth snapshot ($label):',
          'url=${Supabase.instance.client.rest.url}',
          'hasSession=${session != null}',
          'userId=${user?.id ?? 'null'}',
          'tokenLen=${token?.length ?? 0}',
          'tokenIss=${tokenIssuer ?? 'null'}',
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
      await _debugLogAuthSnapshot('before');
      final Session? session = Supabase.instance.client.auth.currentSession;
      final String? token = session?.accessToken;
      if (token == null || token.isEmpty) {
        throw const HttpRequestFailure(401, 'Authentication required');
      }
      final String? apiKey = _readSupabaseAnonKey();
      if (apiKey == null) {
        throw const HttpRequestFailure(
          500,
          'Supabase anon key missing (SUPABASE_ANON_KEY)',
        );
      }
      final response = await Supabase.instance.client.functions.invoke(
        'delete-case-study',
        body: <String, Object?>{'caseId': trimmed},
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'apikey': apiKey,
        },
      );
      if (kDebugMode) {
        AppLogger.debug(
          'delete-case-study response: status=${response.status} data=${response.data}',
        );
      }

      if (response.status != 200) {
        throw HttpRequestFailure(
          response.status,
          'Edge delete-case-study failed: ${response.data ?? response.status}',
        );
      }
    } on FunctionException catch (error, stackTrace) {
      // Common: access token expired -> refreshSession fixes it. If refresh fails
      // (revoked/invalid refresh token), sign out so UI can re-auth cleanly.
      if (error.status == 401 &&
          SupabaseBootstrapService.isSupabaseInitialized) {
        try {
          await _debugLogAuthSnapshot('401_before_refresh');
          await Supabase.instance.client.auth.refreshSession();
          await _debugLogAuthSnapshot('401_after_refresh');
          final Session? refreshed =
              Supabase.instance.client.auth.currentSession;
          final String? refreshedToken = refreshed?.accessToken;
          if (refreshedToken == null || refreshedToken.isEmpty) {
            throw const HttpRequestFailure(401, 'Authentication required');
          }
          final String? apiKey = _readSupabaseAnonKey();
          if (apiKey == null) {
            throw const HttpRequestFailure(
              500,
              'Supabase anon key missing (SUPABASE_ANON_KEY)',
            );
          }
          final retry = await Supabase.instance.client.functions.invoke(
            'delete-case-study',
            body: <String, Object?>{'caseId': trimmed},
            headers: <String, String>{
              'Authorization': 'Bearer $refreshedToken',
              'apikey': apiKey,
            },
          );
          if (kDebugMode) {
            AppLogger.debug(
              'delete-case-study retry response: status=${retry.status} data=${retry.data}',
            );
          }
          if (retry.status == 200) {
            return;
          }
        } on Object {
          // Ignore and fall through to user-facing error.
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
}
