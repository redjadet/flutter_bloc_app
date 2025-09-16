import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_error.freezed.dart';

enum CounterErrorType { cannotGoBelowZero, loadError, saveError, unknown }

@freezed
sealed class CounterError with _$CounterError {
  const CounterError._();

  const factory CounterError.cannotGoBelowZero() = _CannotGoBelowZero;

  const factory CounterError.load({Object? originalError, String? message}) =
      _LoadCounterError;

  const factory CounterError.save({Object? originalError, String? message}) =
      _SaveCounterError;

  const factory CounterError.unknown({Object? originalError, String? message}) =
      _UnknownCounterError;

  CounterErrorType get type => when(
    cannotGoBelowZero: () => CounterErrorType.cannotGoBelowZero,
    load: (_, _) => CounterErrorType.loadError,
    save: (_, _) => CounterErrorType.saveError,
    unknown: (_, _) => CounterErrorType.unknown,
  );

  Object? get originalError => when(
    cannotGoBelowZero: () => null,
    load: (originalError, _) => originalError,
    save: (originalError, _) => originalError,
    unknown: (originalError, _) => originalError,
  );

  String? get message => when(
    cannotGoBelowZero: () => null,
    load: (_, message) => message,
    save: (_, message) => message,
    unknown: (_, message) => message,
  );
}
