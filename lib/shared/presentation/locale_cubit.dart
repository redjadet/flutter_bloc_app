import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/domain/locale_repository.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit({required LocaleRepository repository})
    : _repository = repository,
      super(null);

  final LocaleRepository _repository;

  Future<void> loadInitial() async {
    final Locale? stored = await _repository.load();
    if (!_isSame(stored, state)) {
      emit(stored);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (_isSame(locale, state)) return;
    emit(locale);
    await _repository.save(locale);
  }

  bool _isSame(Locale? a, Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}
