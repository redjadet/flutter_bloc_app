import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:material_ui/material_ui.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required this._repository}) : super(ThemeMode.system);

  final ThemeRepository _repository;

  Future<void> loadInitial() async {
    try {
      final ThemePreference? loaded = await _repository.load();
      if (isClosed) return;
      if (loaded != null) emit(_toThemeMode(loaded));
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ThemeCubit.loadInitial failed',
        error,
        stackTrace,
      );
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    final ThemeMode previous = state;
    emit(mode);
    try {
      await _repository.save(_toPreference(mode));
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ThemeCubit.setMode save failed',
        error,
        stackTrace,
      );
      if (!isClosed) {
        emit(previous);
      }
    }
  }

  Future<void> toggle() async {
    final ThemeMode next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
    await setMode(next);
  }

  ThemeMode _toThemeMode(ThemePreference preference) => switch (preference) {
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.system => ThemeMode.system,
  };

  ThemePreference _toPreference(ThemeMode mode) => switch (mode) {
    ThemeMode.light => ThemePreference.light,
    ThemeMode.dark => ThemePreference.dark,
    ThemeMode.system => ThemePreference.system,
  };
}
