import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings domain types resolve (compile-time surface)', () {
    expect(LocaleRepository, isA<Type>());
    expect(ThemeRepository, isA<Type>());
  });
}
