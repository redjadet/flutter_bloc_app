import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_exception_mapper.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('graphqlDemoErrorTypeFromPostgrest', () {
    test('maps 401 and 403 to invalidRequest', () {
      expect(
        graphqlDemoErrorTypeFromPostgrest(
          const PostgrestException(message: 'nope', code: '401'),
        ),
        GraphqlDemoErrorType.invalidRequest,
      );
      expect(
        graphqlDemoErrorTypeFromPostgrest(
          const PostgrestException(message: 'forbidden', code: '403'),
        ),
        GraphqlDemoErrorType.invalidRequest,
      );
    });

    test('maps 5xx to server', () {
      expect(
        graphqlDemoErrorTypeFromPostgrest(
          const PostgrestException(message: 'boom', code: '503'),
        ),
        GraphqlDemoErrorType.server,
      );
    });

    test('defaults unknown or non-http code to network', () {
      expect(
        graphqlDemoErrorTypeFromPostgrest(
          const PostgrestException(message: 'network down'),
        ),
        GraphqlDemoErrorType.network,
      );
      expect(
        graphqlDemoErrorTypeFromPostgrest(
          const PostgrestException(message: 'bad code', code: 'abc'),
        ),
        GraphqlDemoErrorType.network,
      );
    });
  });

  test('graphqlDemoExceptionFromPostgrest preserves cause and mapped type', () {
    const PostgrestException failure = PostgrestException(
      message: 'bad request',
      code: '401',
    );

    final GraphqlDemoException exception = graphqlDemoExceptionFromPostgrest(
      failure,
    );

    expect(exception.message, 'bad request');
    expect(exception.cause, same(failure));
    expect(exception.type, GraphqlDemoErrorType.invalidRequest);
  });
}
