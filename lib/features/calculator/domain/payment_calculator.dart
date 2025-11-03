import 'dart:math' as math;

/// Supported operations for the payment calculator.
enum CalculatorOperation { add, subtract, multiply, divide }

/// Stateless domain service that provides arithmetic utilities tailored for
/// currency style calculations.
class PaymentCalculator {
  const PaymentCalculator({this.scale = 2});

  /// Number of fraction digits to retain.
  final int scale;

  /// Applies [operation] to [lhs] and [rhs], rounding the result using the
  /// configured [scale].
  double applyOperation({
    required final double lhs,
    required final double rhs,
    required final CalculatorOperation operation,
  }) {
    final double result = switch (operation) {
      CalculatorOperation.add => lhs + rhs,
      CalculatorOperation.subtract => lhs - rhs,
      CalculatorOperation.multiply => lhs * rhs,
      CalculatorOperation.divide => rhs == 0 ? 0 : lhs / rhs,
    };
    return round(result);
  }

  /// Parses currency text into a double, normalising thousand separators and
  /// constraining the scale.
  double parseCurrency(final String value) {
    final String normalised = value.replaceAll(',', '');
    final double parsed = double.tryParse(normalised) ?? 0;
    return round(parsed);
  }

  /// Rounds [value] to the configured [scale].
  double round(final double value) {
    final double mod = math.pow(10, scale).toDouble();
    return (value * mod).roundToDouble() / mod;
  }
}
