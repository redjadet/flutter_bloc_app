import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/cubit/calculator_cubit.dart';

/// Abstraction describing the calculator interactions exposed to presentation.
abstract class CalculatorActions {
  void inputDigit(String digit);
  void inputOperation(CalculatorOperation operation);
  void inputDecimalPoint();
  void evaluate();
  void toggleSign();
  void applyPercentage();
  void clearAll();
  void backspace();
}

/// Concrete adapter wiring [CalculatorCubit] to [CalculatorActions].
class CalculatorCubitActions implements CalculatorActions {
  const new(this._cubit);

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
  void inputDigit(String digit) => _cubit.inputDigit(digit);

  @override
  void inputOperation(CalculatorOperation operation) =>
      _cubit.selectOperation(operation);

  @override
  void toggleSign() => _cubit.toggleSign();
}

/// Command object that encapsulates calculator keypad behaviour.
abstract class CalculatorCommand {
  const new();

  void execute(CalculatorActions actions);
}

class DigitCommand extends CalculatorCommand {
  const new(this.digit);

  final String digit;

  @override
  void execute(CalculatorActions actions) => actions.inputDigit(digit);
}

class OperationCommand extends CalculatorCommand {
  const new(this.operation);

  final CalculatorOperation operation;

  @override
  void execute(CalculatorActions actions) => actions.inputOperation(operation);
}

class DecimalCommand extends CalculatorCommand {
  const new();

  @override
  void execute(CalculatorActions actions) => actions.inputDecimalPoint();
}

class EvaluateCommand extends CalculatorCommand {
  const new();

  @override
  void execute(CalculatorActions actions) => actions.evaluate();
}

class ToggleSignCommand extends CalculatorCommand {
  const new();

  @override
  void execute(CalculatorActions actions) => actions.toggleSign();
}

class ApplyPercentageCommand extends CalculatorCommand {
  const new();

  @override
  void execute(CalculatorActions actions) => actions.applyPercentage();
}

class ClearAllCommand extends CalculatorCommand {
  const new();

  @override
  void execute(CalculatorActions actions) => actions.clearAll();
}

class BackspaceCommand extends CalculatorCommand {
  const new();

  @override
  void execute(CalculatorActions actions) => actions.backspace();
}
