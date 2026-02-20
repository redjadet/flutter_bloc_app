import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/calculator/domain/calculator_error.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit_utils.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';

part 'calculator_cubit_helpers.dart';

/// Cubit orchestrating payment calculator behaviour and summaries.
class CalculatorCubit extends Cubit<CalculatorState>
    with CalculatorCubitHelpers {
  CalculatorCubit({required this.calculator}) : super(const CalculatorState());

  @override
  final PaymentCalculator calculator;

  void inputDigit(final String digit) {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }

    if (digit.length != 1 || int.tryParse(digit) == null) {
      return;
    }
    _writeDigits(digit);
  }

  void inputDecimalPoint() {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }

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
    if (!_ensureEditable(resetForInput: false)) {
      return;
    }

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
    if (!_ensureEditable(resetForInput: false)) {
      return;
    }

    final CalculatorState current = state;
    final double currentValue = _parseDisplay(current);

    if (current.operation case final op?) {
      final double lhsCandidate = current.accumulator ?? currentValue;
      if (_isNonPositiveTotal(lhsCandidate)) {
        emit(_errorState(current, CalculatorError.nonPositiveTotal));
        return;
      }
      emit(
        _applyEvaluation(
          current: current,
          lhs: current.accumulator ?? currentValue,
          rhs: currentValue,
          operation: op,
          historyOverride: null,
          updateRepeatOperation: true,
          clearPendingOperation: true,
        ),
      );
      return;
    }

    if ((current.lastOperation, current.lastOperand) case (
      final lastOp?,
      final lastOperand?,
    )) {
      if (_isNonPositiveTotal(currentValue)) {
        emit(_errorState(current, CalculatorError.nonPositiveTotal));
        return;
      }
      emit(
        _applyEvaluation(
          current: current,
          lhs: currentValue,
          rhs: lastOperand,
          operation: lastOp,
          historyOverride: '',
        ),
      );
      return;
    }

    final String expression = current.history.isNotEmpty
        ? current.history
        : _format(currentValue);
    if (_isNonPositiveTotal(currentValue)) {
      emit(_errorState(current, CalculatorError.nonPositiveTotal));
      return;
    }
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

  void toggleSign() {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }
    emit(toggleSignState(state, calculator));
  }

  void applyPercentage() {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }
    emit(applyPercentageState(state, calculator));
  }

  void backspace() {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }

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
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }
    emit(state.copyWith(taxRate: clampRate(rate)));
  }

  void setTipRate(final double rate) {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }
    emit(state.copyWith(tipRate: clampRate(rate)));
  }

  void resetTip() {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }
    emit(state.copyWith(tipRate: 0));
  }

  void resetTax() {
    if (!_ensureEditable(resetForInput: true)) {
      return;
    }
    emit(state.copyWith(taxRate: 0));
  }

  void _writeDigits(final String digits) {
    emit(writeDigitsState(state, digits, calculator));
  }
}
