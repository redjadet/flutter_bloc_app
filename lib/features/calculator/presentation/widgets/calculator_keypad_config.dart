part of 'calculator_keypad.dart';

_ButtonConfig _digit(final String label) => _ButtonConfig.number(
  label: label,
  command: DigitCommand(label),
);

enum _ButtonType { number, operation, function }

class _ButtonConfig {
  const _ButtonConfig._({
    required this.label,
    required this.type,
    required this.command,
    this.semanticsLabel,
    this.tooltip,
  });

  const _ButtonConfig.number({
    required final String label,
    required final CalculatorCommand command,
    final String? semanticsLabel,
    final String? tooltip,
  }) : this._(
         label: label,
         type: _ButtonType.number,
         command: command,
         semanticsLabel: semanticsLabel,
         tooltip: tooltip,
       );

  const _ButtonConfig.operation({
    required final String label,
    required final CalculatorCommand command,
    final String? semanticsLabel,
    final String? tooltip,
  }) : this._(
         label: label,
         type: _ButtonType.operation,
         command: command,
         semanticsLabel: semanticsLabel,
         tooltip: tooltip,
       );

  const _ButtonConfig.function({
    required final String label,
    required final CalculatorCommand command,
    final String? semanticsLabel,
    final String? tooltip,
  }) : this._(
         label: label,
         type: _ButtonType.function,
         command: command,
         semanticsLabel: semanticsLabel,
         tooltip: tooltip,
       );

  final String label;
  final _ButtonType type;
  final CalculatorCommand command;
  final String? semanticsLabel;
  final String? tooltip;
}
