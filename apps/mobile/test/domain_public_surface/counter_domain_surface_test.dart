import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counter domain types resolve (compile-time surface)', () {
    expect(CounterRepository, isA<Type>());
  });
}
