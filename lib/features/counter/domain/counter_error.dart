import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_error.freezed.dart';

enum CounterErrorType { cannotGoBelowZero, loadError, saveError, unknown }

@freezed
sealed class CounterError with _$CounterError implements Exception {
  const CounterError._();

  const factory CounterError.cannotGoBelowZero() = _CannotGoBelowZero;

  const factory CounterError.load({
    final Object? originalError,
    final String? message,
  }) = _LoadCounterError;

  const factory CounterError.save({
    final Object? originalError,
    final String? message,
  }) = _SaveCounterError;

  const factory CounterError.unknown({
    final Object? originalError,
    final String? message,
  }) = _UnknownCounterError;

  CounterErrorType get type => when(
    cannotGoBelowZero: () => CounterErrorType.cannotGoBelowZero,
    load: (_, _) => CounterErrorType.loadError,
    save: (_, _) => CounterErrorType.saveError,
    unknown: (_, _) => CounterErrorType.unknown,
  );

  Object? get originalError => when(
    cannotGoBelowZero: () => null,
    load: (final originalError, _) => originalError,
    save: (final originalError, _) => originalError,
    unknown: (final originalError, _) => originalError,
  );

  String? get message => when(
    cannotGoBelowZero: () => null,
    load: (_, final message) => message,
    save: (_, final message) => message,
    unknown: (_, final message) => message,
  );
}
