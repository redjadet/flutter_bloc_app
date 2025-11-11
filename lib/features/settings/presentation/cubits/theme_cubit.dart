import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required final ThemeRepository repository})
    : _repository = repository,
      super(ThemeMode.system);

  final ThemeRepository _repository;

  Future<void> loadInitial() async {
    final ThemePreference? loaded = await _repository.load();
    if (loaded != null) emit(_toThemeMode(loaded));
  }

  Future<void> setMode(final ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await _repository.save(_toPreference(mode));
  }

  Future<void> toggle() async {
    final ThemeMode next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
    await setMode(next);
  }

  ThemeMode _toThemeMode(final ThemePreference preference) =>
      switch (preference) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system => ThemeMode.system,
      };

  ThemePreference _toPreference(final ThemeMode mode) => switch (mode) {
    ThemeMode.light => ThemePreference.light,
    ThemeMode.dark => ThemePreference.dark,
    ThemeMode.system => ThemePreference.system,
  };
}
