import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeThemeRepository implements ThemeRepository {
  ThemePreference? stored;

  @override
  Future<ThemePreference?> load() async => stored;

  @override
  Future<void> save(ThemePreference mode) async {
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
}
