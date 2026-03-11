import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of [runSupabaseEdgeThenTables].
class SupabaseEdgeThenTablesResult<T> {
  const SupabaseEdgeThenTablesResult(this.result, {required this.fromEdge});

  final List<T> result;
  final bool fromEdge;
}

/// Ensures Supabase is initialized. Throws [StateError] if not.
void ensureSupabaseConfigured() {
  if (!SupabaseBootstrapService.isSupabaseInitialized) {
    throw StateError('Supabase is not configured');
  }
}

/// Runs "try Edge function then fall back to tables" with consistent error
/// handling. Use in Supabase-backed repositories that prefer Edge and fall back
/// to table reads.
///
/// [tryEdge] should return an empty list on any failure (caller handles
/// logging inside [tryEdge] if desired). [fetchTables] runs when Edge returns
/// empty. [onPostgrestException] and [onGenericException] map errors to the
/// repository's domain exception type. [logContext] is used in [AppLogger].
/// [genericFailureMessage] is the message passed to [onGenericException] when
/// a non-Postgrest failure occurs; override so UI/tests see repository-specific
/// text.
Future<SupabaseEdgeThenTablesResult<T>> runSupabaseEdgeThenTables<T>({
  required final Future<List<T>> Function() tryEdge,
  required final Future<List<T>> Function() fetchTables,
  required final Exception Function(PostgrestException e) onPostgrestException,
  required final Exception Function(String message, Object? cause)
  onGenericException,
  required final String logContext,
  final String genericFailureMessage = 'Failed to load from Supabase',
}) async {
  ensureSupabaseConfigured();
  try {
    final fromEdge = await tryEdge();
    if (fromEdge.isNotEmpty) {
      return SupabaseEdgeThenTablesResult(fromEdge, fromEdge: true);
    }
    final fromTables = await fetchTables();
    return SupabaseEdgeThenTablesResult(fromTables, fromEdge: false);
  } on PostgrestException catch (e, s) {
    AppLogger.error(logContext, e, s);
    throw onPostgrestException(e);
  } on Object catch (e, s) {
    AppLogger.error(logContext, e, s);
    throw onGenericException(genericFailureMessage, e);
  }
}
