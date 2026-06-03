import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';

AppError graphqlDemoAppErrorFromException(
  final GraphqlDemoException exception,
) {
  return graphqlDemoAppErrorFromType(
    exception.type,
    exception.message,
    cause: exception.cause,
  );
}

AppError graphqlDemoAppErrorFromType(
  final GraphqlDemoErrorType? type,
  final String? message, {
  final Object? cause,
}) {
  final String trimmed = message?.trim() ?? '';
  final String resolved = trimmed.isNotEmpty ? trimmed : 'GraphQL demo error';
  switch (type) {
    case GraphqlDemoErrorType.network:
      return NetworkError(
        message: resolved,
        kind: NetworkErrorKind.offline,
        cause: cause,
      );
    case GraphqlDemoErrorType.server:
      return NetworkError(
        message: resolved,
        kind: NetworkErrorKind.server,
        cause: cause,
      );
    case GraphqlDemoErrorType.invalidRequest:
      return NetworkError(
        message: resolved,
        kind: NetworkErrorKind.client,
        cause: cause,
      );
    case GraphqlDemoErrorType.data:
      return StorageError(
        message: resolved,
        kind: StorageErrorKind.read,
        cause: cause,
      );
    case GraphqlDemoErrorType.unknown:
    case null:
      return UnknownError(message: resolved, cause: cause);
  }
}
