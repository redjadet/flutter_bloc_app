import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeLocaleRepository implements LocaleRepository {
  _FakeLocaleRepository({this.throwOnSave = false, this.throwOnLoad = false});

  AppLocale? stored;
  final bool throwOnSave;
  final bool throwOnLoad;

  @override
  Future<AppLocale?> load() async {
    if (throwOnLoad) {
      throw StateError('load failed');
    }
    return stored;
  }

  @override
  Future<void> save(AppLocale? locale) async {
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

  test('loadInitial keeps default state when load throws', () async {
    final repo = _FakeLocaleRepository(throwOnLoad: true);
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

  test('setLocale reverts state and completes when save throws', () async {
    final repo = _FakeLocaleRepository(throwOnSave: true);
    final cubit = LocaleCubit(repository: repo);
    await cubit.loadInitial();
    expect(cubit.state, isNull);

    await cubit.setLocale(const Locale('de', 'DE'));
    expect(cubit.state, isNull);
    expect(repo.stored, isNull);
  });
}
