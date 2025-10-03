import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required ThemeRepository repository})
    : _repository = repository,
      super(ThemeMode.system);

  final ThemeRepository _repository;

  Future<void> loadInitial() async {
    final ThemeMode? loaded = await _repository.load();
    if (loaded != null) emit(loaded);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await _repository.save(mode);
  }

  Future<void> toggle() async {
    final ThemeMode next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
    await setMode(next);
  }
}
