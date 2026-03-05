import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/locale_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocaleRepository implements LocaleRepository {
  _FakeLocaleRepository({this.throwOnSave = false});

  AppLocale? stored;
  final bool throwOnSave;

  @override
  Future<AppLocale?> load() async => stored;

  @override
  Future<void> save(final AppLocale? locale) async {
    if (throwOnSave) {
      throw StateError('save failed');
    }
    stored = locale;
  }
}

void main() {
  test('loadInitial emits stored locale when available', () async {
    final repo = _FakeLocaleRepository()
      ..stored = const AppLocale(languageCode: 'tr', countryCode: 'TR');
    final cubit = LocaleCubit(repository: repo);
    await cubit.loadInitial();
    expect(cubit.state?.languageCode, 'tr');
    expect(cubit.state?.countryCode, 'TR');
  });

  test('loadInitial emits null when store is empty', () async {
    final repo = _FakeLocaleRepository();
    final cubit = LocaleCubit(repository: repo);
    await cubit.loadInitial();
    expect(cubit.state, isNull);
  });

  test('setLocale updates state and persists', () async {
    final repo = _FakeLocaleRepository();
    final cubit = LocaleCubit(repository: repo);
    await cubit.setLocale(const Locale('fr', 'FR'));
    expect(cubit.state?.languageCode, 'fr');
    expect(cubit.state?.countryCode, 'FR');
    expect(repo.stored?.languageCode, 'fr');
    expect(repo.stored?.countryCode, 'FR');
  });

  test('setLocale reverts state and rethrows when save throws', () async {
    final repo = _FakeLocaleRepository(throwOnSave: true);
    final cubit = LocaleCubit(repository: repo);
    await cubit.loadInitial();
    expect(cubit.state, isNull);

    await expectLater(
      cubit.setLocale(const Locale('de', 'DE')),
      throwsA(
        isA<StateError>().having((e) => e.message, 'message', 'save failed'),
      ),
    );
    expect(cubit.state, isNull);
    expect(repo.stored, isNull);
  });
}
