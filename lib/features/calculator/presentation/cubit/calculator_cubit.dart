import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit_utils.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';

/// Cubit orchestrating payment calculator behaviour and summaries.
class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit({required final PaymentCalculator calculator})
    : _calculator = calculator,
      super(const CalculatorState());

  final PaymentCalculator _calculator;

  PaymentCalculator get calculator => _calculator;

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
    final double currentValue = _calculator.parseCurrency(current.display);

    double accumulator = current.accumulator ?? currentValue;
    if (current.accumulator != null &&
        current.operation != null &&
        !current.replaceInput) {
      accumulator = _calculator.applyOperation(
        lhs: current.accumulator!,
        rhs: currentValue,
        operation: current.operation!,
      );
    }

    emit(
      current.copyWith(
        accumulator: accumulator,
        operation: operation,
        display: formatDisplay(_calculator, accumulator),
        replaceInput: true,
        lastOperand: null,
        lastOperation: null,
        history:
            '${formatDisplay(_calculator, accumulator)}${operationSymbol(operation)}',
      ),
    );
  }

  void evaluate() {
    final CalculatorState current = state;
    final double currentValue = _calculator.parseCurrency(current.display);

    if (current.operation != null) {
      final double lhs = current.accumulator ?? currentValue;
      final double result = _calculator.applyOperation(
        lhs: lhs,
        rhs: currentValue,
        operation: current.operation!,
      );
      final String prefix = current.history.isNotEmpty
          ? current.history
          : '${formatDisplay(_calculator, lhs)}${operationSymbol(current.operation!)}';
      final String expression =
          '$prefix${formatDisplay(_calculator, currentValue)}';

      emit(
        current.copyWith(
          display: formatDisplay(_calculator, result),
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
      final double result = _calculator.applyOperation(
        lhs: currentValue,
        rhs: current.lastOperand!,
        operation: current.lastOperation!,
      );
      final String expression =
          '${formatDisplay(_calculator, currentValue)}${operationSymbol(current.lastOperation!)}${formatDisplay(_calculator, current.lastOperand!)}';

      emit(
        current.copyWith(
          display: formatDisplay(_calculator, result),
          replaceInput: true,
          settledAmount: result,
          history: expression,
        ),
      );
      return;
    }

    final String expression = current.history.isNotEmpty
        ? current.history
        : formatDisplay(_calculator, currentValue);
    emit(
      current.copyWith(
        display: formatDisplay(_calculator, currentValue),
        replaceInput: true,
        settledAmount: currentValue,
        history: expression,
      ),
    );
  }

  void clearAll() {
    emit(
      state.copyWith(
        display: '0',
        accumulator: null,
        operation: null,
        lastOperand: null,
        lastOperation: null,
        replaceInput: true,
        taxRate: 0,
        tipRate: 0,
        settledAmount: 0,
        history: '',
      ),
    );
  }

  void toggleSign() {
    emit(toggleSignState(state, _calculator));
  }

  void applyPercentage() {
    emit(applyPercentageState(state, _calculator));
  }

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
    emit(writeDigitsState(state, digits, _calculator));
  }
}
