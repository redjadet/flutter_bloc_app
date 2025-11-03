import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart'
    show CalculatorOperation, PaymentCalculator;
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_state.dart';

double clampRate(final double rate) => rate.clamp(0, 1).toDouble();

bool reachedDecimalLimit(final String buffer, final int scale) {
  if (!buffer.contains('.')) {
    return false;
  }
  final int decimals = buffer.split('.')[1].length;
  return decimals >= scale;
}

String formatDisplay(
  final PaymentCalculator calculator,
  final double value,
) {
  final double rounded = calculator.round(value);
  if (rounded == 0) {
    return '0';
  }
  if (rounded == rounded.truncateToDouble()) {
    return rounded.truncate().toString();
  }
  final String fixed = rounded.toStringAsFixed(calculator.scale);
  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String operationSymbol(final CalculatorOperation operation) =>
    switch (operation) {
      CalculatorOperation.add => '+',
      CalculatorOperation.subtract => '−',
      CalculatorOperation.multiply => '×',
      CalculatorOperation.divide => '÷',
    };

CalculatorState toggleSignState(
  final CalculatorState current,
  final PaymentCalculator calculator,
) {
  final double value = calculator.parseCurrency(current.display);
  if (value == 0) {
    if (current.display.startsWith('-')) {
      return current.copyWith(display: current.display.substring(1));
    }
    return current;
  }
  final double toggled = -value;
  return current.copyWith(
    display: formatDisplay(calculator, toggled),
    replaceInput: false,
  );
}

CalculatorState applyPercentageState(
  final CalculatorState current,
  final PaymentCalculator calculator,
) {
  final double value = calculator.parseCurrency(current.display);
  final double percent = value / 100;
  return current.copyWith(
    display: formatDisplay(calculator, percent),
    replaceInput: true,
  );
}

CalculatorState writeDigitsState(
  final CalculatorState current,
  final String digits,
  final PaymentCalculator calculator,
) {
  String buffer = current.replaceInput ? '0' : current.display;
  bool replace = current.replaceInput;

  for (final String digit in digits.split('')) {
    if (int.tryParse(digit) == null) {
      continue;
    }
    if (replace) {
      buffer = digit == '0' ? '0' : digit;
      replace = false;
      continue;
    }

    if (reachedDecimalLimit(buffer, calculator.scale)) {
      continue;
    }

    if (buffer == '0' && digit != '0' && !buffer.contains('.')) {
      buffer = digit;
    } else {
      buffer += digit;
    }
  }

  final bool clearHistory = current.replaceInput && current.operation == null;
  return current.copyWith(
    display: buffer,
    replaceInput: false,
    history: clearHistory ? '' : current.history,
    lastOperand: clearHistory ? null : current.lastOperand,
    lastOperation: clearHistory ? null : current.lastOperation,
    accumulator: clearHistory ? null : current.accumulator,
    settledAmount: clearHistory ? 0 : current.settledAmount,
  );
}
