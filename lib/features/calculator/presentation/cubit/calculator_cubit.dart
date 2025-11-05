import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit_utils.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';

/// Cubit orchestrating payment calculator behaviour and summaries.
class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({required this.calculator}) : super(const CalculatorState());

  final PaymentCalculator calculator;

  double _parseDisplay([final CalculatorState? value]) =>
      calculator.parseCurrency((value ?? state).display);

  double _applyOperation({
    required final double lhs,
    required final double rhs,
    required final CalculatorOperation operation,
  }) => calculator.applyOperation(
    lhs: lhs,
    rhs: rhs,
    operation: operation,
  );

  String _format(final double value) => formatDisplay(calculator, value);

  double _resolveAccumulator(
    final CalculatorState current,
    final double currentValue,
  ) {
    if (current.accumulator != null &&
        current.operation != null &&
        !current.replaceInput) {
      return _applyOperation(
        lhs: current.accumulator!,
        rhs: currentValue,
        operation: current.operation!,
      );
    }
    return current.accumulator ?? currentValue;
  }

  String _pendingHistory(
    final double accumulator,
    final CalculatorOperation operation,
  ) => '${_format(accumulator)}${operationSymbol(operation)}';

  String _composeHistory({
    required final CalculatorState current,
    required final double lhs,
    required final double rhs,
    required final CalculatorOperation operation,
    final String? historyOverride,
  }) {
    final String seed = historyOverride ?? current.history;
    final String prefix = seed.isNotEmpty
        ? seed
        : _pendingHistory(lhs, operation);
    return '$prefix${_format(rhs)}';
  }

  void inputDigit(final String digit) {
    if (digit.length != 1 || int.tryParse(digit) == null) {
      return;
    }
    _writeDigits(digit);
  }

  void inputDecimalPoint() {
    final CalculatorState current = state;
    if (current.replaceInput) {
      emit(
        current.copyWith(
          display: '0.',
          replaceInput: false,
        ),
      );
      return;
    }

    if (current.display.contains('.')) {
      emit(current.copyWith(display: current.display));
      return;
    }

    emit(
      current.copyWith(
        display: '${current.display}.',
        replaceInput: false,
      ),
    );
  }

  void selectOperation(final CalculatorOperation operation) {
    final CalculatorState current = state;
    final double currentValue = _parseDisplay(current);
    final double accumulator = _resolveAccumulator(current, currentValue);

    emit(
      current.copyWith(
        accumulator: accumulator,
        operation: operation,
        display: _format(accumulator),
        replaceInput: true,
        lastOperand: null,
        lastOperation: null,
        history: _pendingHistory(accumulator, operation),
      ),
    );
  }

  void evaluate() {
    final CalculatorState current = state;
    final double currentValue = _parseDisplay(current);

    if (current.operation != null) {
      final double lhs = current.accumulator ?? currentValue;
      final double result = _applyOperation(
        lhs: lhs,
        rhs: currentValue,
        operation: current.operation!,
      );
      final String expression = _composeHistory(
        current: current,
        lhs: lhs,
        rhs: currentValue,
        operation: current.operation!,
      );

      emit(
        current.copyWith(
          display: _format(result),
          accumulator: null,
          operation: null,
          replaceInput: true,
          lastOperand: currentValue,
          lastOperation: current.operation,
          settledAmount: result,
          history: expression,
        ),
      );
      return;
    }

    if (current.lastOperation != null && current.lastOperand != null) {
      final double result = _applyOperation(
        lhs: currentValue,
        rhs: current.lastOperand!,
        operation: current.lastOperation!,
      );
      final String expression = _composeHistory(
        current: current,
        lhs: currentValue,
        rhs: current.lastOperand!,
        operation: current.lastOperation!,
        historyOverride: '',
      );

      emit(
        current.copyWith(
          display: _format(result),
          replaceInput: true,
          settledAmount: result,
          history: expression,
        ),
      );
      return;
    }

    final String expression = current.history.isNotEmpty
        ? current.history
        : _format(currentValue);
    emit(
      current.copyWith(
        display: _format(currentValue),
        replaceInput: true,
        settledAmount: currentValue,
        history: expression,
      ),
    );
  }

  void clearAll() {
    emit(const CalculatorState());
  }

  void toggleSign() => emit(toggleSignState(state, calculator));

  void applyPercentage() => emit(applyPercentageState(state, calculator));

  void backspace() {
    final CalculatorState current = state;
    if (current.replaceInput) {
      emit(current.copyWith(display: '0'));
      return;
    }

    final String display = current.display;
    if (display.length <= 1) {
      emit(current.copyWith(display: '0'));
      return;
    }

    String next = display.substring(0, display.length - 1);
    if (next.endsWith('.')) {
      next = next.substring(0, next.length - 1);
    }
    if (next.isEmpty) {
      next = '0';
    }

    emit(current.copyWith(display: next));
  }

  void setTaxRate(final double rate) {
    emit(state.copyWith(taxRate: clampRate(rate)));
  }

  void setTipRate(final double rate) {
    emit(state.copyWith(tipRate: clampRate(rate)));
  }

  void resetTip() => emit(state.copyWith(tipRate: 0));

  void resetTax() => emit(state.copyWith(taxRate: 0));

  void _writeDigits(final String digits) {
    emit(writeDigitsState(state, digits, calculator));
  }
}
