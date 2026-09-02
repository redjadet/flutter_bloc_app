import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:material_ui/material_ui.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit({required this._repository}) : super(null);

  final LocaleRepository _repository;

  Future<void> loadInitial() async {
    try {
      final AppLocale? stored = await _repository.load();
      if (isClosed) return;
      final Locale? resolved = _toLocale(stored);
      if (!_isSame(resolved, state)) {
        emit(resolved);
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'LocaleCubit.loadInitial failed',
        error,
        stackTrace,
      );
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (_isSame(locale, state)) return;
    final Locale? previous = state;
    emit(locale);
    try {
      await _repository.save(_toAppLocale(locale));
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'LocaleCubit.setLocale save failed',
        error,
        stackTrace,
      );
      if (!isClosed) {
        emit(previous);
      }
    }
  }

  bool _isSame(Locale? a, Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }

  Locale? _toLocale(AppLocale? locale) {
    if (locale == null) return null;
    return Locale(locale.languageCode, locale.countryCode);
  }

  AppLocale? _toAppLocale(Locale? locale) {
    if (locale == null) return null;
    return AppLocale(
      languageCode: locale.languageCode,
      countryCode: locale.countryCode,
    );
  }
}
