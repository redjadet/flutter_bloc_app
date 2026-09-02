import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeThemeRepository implements ThemeRepository {
  ThemePreference? stored;
  bool throwOnSave = false;
  bool throwOnLoad = false;

  @override
  Future<ThemePreference?> load() async {
    if (throwOnLoad) {
      throw StateError('load failed');
    }
    return stored;
  }

  @override
  Future<void> save(ThemePreference mode) async {
    if (throwOnSave) {
      throw StateError('save failed');
    }
    stored = mode;
  }
}

void main() {
  test('loadInitial emits stored mode when available', () async {
    final repo = _FakeThemeRepository()..stored = ThemePreference.dark;
    final cubit = ThemeCubit(repository: repo);
    await cubit.loadInitial();
    expect(cubit.state, ThemeMode.dark);
  });

  test('loadInitial keeps default state when load throws', () async {
    final repo = _FakeThemeRepository()..throwOnLoad = true;
    final cubit = ThemeCubit(repository: repo);
    await cubit.loadInitial();
    expect(cubit.state, ThemeMode.system);
  });

  test('setMode updates state and persists', () async {
    final repo = _FakeThemeRepository();
    final cubit = ThemeCubit(repository: repo);
    await cubit.setMode(ThemeMode.light);
    expect(cubit.state, ThemeMode.light);
    expect(repo.stored, ThemePreference.light);
  });

  test('toggle cycles through modes', () async {
    final repo = _FakeThemeRepository();
    final cubit = ThemeCubit(repository: repo);

    await cubit.toggle();
    expect(cubit.state, ThemeMode.dark);

    await cubit.toggle();
    expect(cubit.state, ThemeMode.light);
  });

  test('setMode reverts state and completes when save throws', () async {
    final repo = _FakeThemeRepository()..throwOnSave = true;
    final cubit = ThemeCubit(repository: repo);
    expect(cubit.state, ThemeMode.system);

    await cubit.setMode(ThemeMode.dark);
    expect(cubit.state, ThemeMode.system);
    expect(repo.stored, isNull);
  });
}
