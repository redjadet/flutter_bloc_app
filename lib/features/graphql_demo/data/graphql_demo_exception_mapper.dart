import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps [PostgrestException] to [GraphqlDemoErrorType] for domain error handling.
GraphqlDemoErrorType graphqlDemoErrorTypeFromPostgrest(
  final PostgrestException e,
) {
  final int? status = e.code == null ? null : int.tryParse(e.code!);
  if (status == 401 || status == 403) {
    return GraphqlDemoErrorType.invalidRequest;
  }
  if (status != null && status >= 500) {
    return GraphqlDemoErrorType.server;
  }
  return GraphqlDemoErrorType.network;
}

/// Maps [PostgrestException] to [GraphqlDemoException] for use in repositories.
GraphqlDemoException graphqlDemoExceptionFromPostgrest(
  final PostgrestException e,
) => GraphqlDemoException(
  e.message,
  cause: e,
  type: graphqlDemoErrorTypeFromPostgrest(e),
);
