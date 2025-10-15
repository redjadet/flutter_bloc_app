import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GraphqlDemoException stores message, type and cause', () {
    final GraphqlDemoException exception = GraphqlDemoException(
      'boom',
      cause: StateError('fail'),
      type: GraphqlDemoErrorType.network,
    );

    expect(exception.message, 'boom');
    expect(exception.cause, isA<StateError>());
    expect(exception.type, GraphqlDemoErrorType.network);
    expect(
      exception.toString(),
      contains('GraphqlDemoException(message: boom'),
    );
  });
}
