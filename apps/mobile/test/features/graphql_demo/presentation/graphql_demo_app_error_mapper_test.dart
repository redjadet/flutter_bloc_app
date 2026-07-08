import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_app_error_mapper.dart';
import 'package:utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('graphqlDemoAppErrorFromType maps server errors as retryable', () {
    final AppError error = graphqlDemoAppErrorFromType(
      GraphqlDemoErrorType.server,
      'boom',
    );
    expect(error, isA<NetworkError>());
    expect(error.isRetryable, isTrue);
  });

  test('graphqlDemoAppErrorFromType maps invalidRequest as non-retryable', () {
    final AppError error = graphqlDemoAppErrorFromType(
      GraphqlDemoErrorType.invalidRequest,
      'bad',
    );
    expect(error, isA<NetworkError>());
    expect(error.isRetryable, isFalse);
  });
}
