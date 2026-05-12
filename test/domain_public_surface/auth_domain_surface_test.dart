import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth domain types resolve (compile-time surface)', () {
    expect(AuthRepository, isA<Type>());
  });
}
