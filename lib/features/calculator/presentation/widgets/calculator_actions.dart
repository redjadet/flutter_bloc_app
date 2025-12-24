import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';

/// Abstraction describing the calculator interactions exposed to presentation.
abstract class CalculatorActions {
  void inputDigit(final String digit);
  void inputOperation(final CalculatorOperation operation);
  void inputDecimalPoint();
  void evaluate();
  void toggleSign();
  void applyPercentage();
  void clearAll();
  void backspace();
}

/// Concrete adapter wiring [CalculatorCubit] to [CalculatorActions].
class CalculatorCubitActions implements CalculatorActions {
  const CalculatorCubitActions(this._cubit);

  final CalculatorCubit _cubit;

  @override
  void applyPercentage() => _cubit.applyPercentage();

  @override
  void backspace() => _cubit.backspace();

  @override
  void clearAll() => _cubit.clearAll();

  @override
  void evaluate() => _cubit.evaluate();

  @override
  void inputDecimalPoint() => _cubit.inputDecimalPoint();

  @override
  void inputDigit(final String digit) => _cubit.inputDigit(digit);

  @override
  void inputOperation(final CalculatorOperation operation) =>
      _cubit.selectOperation(operation);

  @override
  void toggleSign() => _cubit.toggleSign();
}

/// Command object that encapsulates calculator keypad behaviour.
abstract class CalculatorCommand {
  const CalculatorCommand();

  void execute(final CalculatorActions actions);
}

class DigitCommand extends CalculatorCommand {
  const DigitCommand(this.digit);

  final String digit;

  @override
  void execute(final CalculatorActions actions) => actions.inputDigit(digit);
}

class OperationCommand extends CalculatorCommand {
  const OperationCommand(this.operation);

  final CalculatorOperation operation;

  @override
  void execute(final CalculatorActions actions) =>
      actions.inputOperation(operation);
}

class DecimalCommand extends CalculatorCommand {
  const DecimalCommand();

  @override
  void execute(final CalculatorActions actions) => actions.inputDecimalPoint();
}

class EvaluateCommand extends CalculatorCommand {
  const EvaluateCommand();

  @override
  void execute(final CalculatorActions actions) => actions.evaluate();
}

class ToggleSignCommand extends CalculatorCommand {
  const ToggleSignCommand();

  @override
  void execute(final CalculatorActions actions) => actions.toggleSign();
}

class ApplyPercentageCommand extends CalculatorCommand {
  const ApplyPercentageCommand();

  @override
  void execute(final CalculatorActions actions) => actions.applyPercentage();
}

class ClearAllCommand extends CalculatorCommand {
  const ClearAllCommand();

  @override
  void execute(final CalculatorActions actions) => actions.clearAll();
}

class BackspaceCommand extends CalculatorCommand {
  const BackspaceCommand();

  @override
  void execute(final CalculatorActions actions) => actions.backspace();
}
