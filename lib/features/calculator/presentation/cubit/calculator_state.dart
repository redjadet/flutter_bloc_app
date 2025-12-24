import 'package:flutter_bloc_app/features/calculator/domain/calculator_error.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculator_state.freezed.dart';

@freezed
abstract class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    @Default('0') final String display,
    final double? accumulator,
    final CalculatorOperation? operation,
    final CalculatorOperation? lastOperation,
    final double? lastOperand,
    @Default(true) final bool replaceInput,
    @Default(0.0) final double taxRate,
    @Default(0.0) final double tipRate,
    @Default(0.0) final double settledAmount,
    @Default('') final String history,
    final CalculatorError? error,
  }) = _CalculatorState;

  const CalculatorState._();

  double subtotal(final PaymentCalculator calculator) =>
      calculator.round(settledAmount);

  double taxAmount(final PaymentCalculator calculator) =>
      calculator.round(subtotal(calculator) * taxRate);

  double tipAmount(final PaymentCalculator calculator) =>
      calculator.round(subtotal(calculator) * tipRate);

  double total(final PaymentCalculator calculator) => calculator.round(
    subtotal(calculator) + taxAmount(calculator) + tipAmount(calculator),
  );
}
