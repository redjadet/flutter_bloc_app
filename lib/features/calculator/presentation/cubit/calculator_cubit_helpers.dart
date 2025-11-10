part of 'calculator_cubit.dart';

mixin CalculatorCubitHelpers on Cubit<CalculatorState> {
  PaymentCalculator get calculator;

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

  CalculatorState _applyEvaluation({
    required CalculatorState current,
    required double lhs,
    required double rhs,
    required CalculatorOperation operation,
    required String? historyOverride,
    bool updateRepeatOperation = false,
    bool clearPendingOperation = false,
  }) {
    if (operation == CalculatorOperation.divide && rhs == 0) {
      return _errorState(current, CalculatorError.divisionByZero);
    }

    final double result = _applyOperation(
      lhs: lhs,
      rhs: rhs,
      operation: operation,
    );
    if (!result.isFinite) {
      return _errorState(current, CalculatorError.invalidResult);
    }

    final String expression = _composeHistory(
      current: current,
      lhs: lhs,
      rhs: rhs,
      operation: operation,
      historyOverride: historyOverride,
    );

    return current.copyWith(
      display: _format(result),
      accumulator: clearPendingOperation ? null : current.accumulator,
      operation: clearPendingOperation ? null : current.operation,
      replaceInput: true,
      lastOperand: updateRepeatOperation ? rhs : current.lastOperand,
      lastOperation: updateRepeatOperation ? operation : current.lastOperation,
      settledAmount: result,
      history: expression,
    );
  }

  CalculatorState _errorState(
    final CalculatorState current,
    final CalculatorError error,
  ) => current.copyWith(
    display: '0',
    accumulator: null,
    operation: null,
    replaceInput: true,
    lastOperand: null,
    lastOperation: null,
    settledAmount: 0,
    history: '',
    error: error,
  );

  CalculatorState _clearErrorState(final CalculatorState current) =>
      current.copyWith(
        display: '0',
        accumulator: null,
        operation: null,
        replaceInput: true,
        lastOperand: null,
        lastOperation: null,
        settledAmount: 0,
        history: '',
        error: null,
      );

  bool _ensureEditable({required bool resetForInput}) {
    if (state.error == null) {
      return true;
    }
    if (!resetForInput) {
      return false;
    }
    emit(_clearErrorState(state));
    return true;
  }

  bool _isNonPositiveTotal(final double amount) => amount <= 0;
}
