import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:utilities/utilities.dart';

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
  return switch (type) {
    GraphqlDemoErrorType.network => NetworkError(
      message: resolved,
      kind: NetworkErrorKind.offline,
      cause: cause,
    ),
    GraphqlDemoErrorType.server => NetworkError(
      message: resolved,
      kind: NetworkErrorKind.server,
      cause: cause,
    ),
    GraphqlDemoErrorType.invalidRequest => NetworkError(
      message: resolved,
      kind: NetworkErrorKind.client,
      cause: cause,
    ),
    GraphqlDemoErrorType.data => StorageError(
      message: resolved,
      kind: StorageErrorKind.read,
      cause: cause,
    ),
    GraphqlDemoErrorType.unknown ||
    null => UnknownError(message: resolved, cause: cause),
  };
}
