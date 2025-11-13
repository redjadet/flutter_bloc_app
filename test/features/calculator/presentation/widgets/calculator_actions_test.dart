import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';
import 'package:flutter_bloc_app/features/calculator/presentation/widgets/calculator_actions.dart';

void main() {
  group('CalculatorActions', () {
    late CalculatorCubit cubit;
    late CalculatorCubitActions actions;

    setUp(() {
      cubit = CalculatorCubit(calculator: const PaymentCalculator());
      actions = CalculatorCubitActions(cubit);
    });

    tearDown(() {
      cubit.close();
    });

    group('CalculatorCubitActions', () {
      test('inputDigit calls cubit inputDigit', () {
        actions.inputDigit('5');
        expect(cubit.state.display, '5');
      });

      test('inputOperation calls cubit selectOperation', () {
        actions.inputOperation(CalculatorOperation.add);
        expect(cubit.state.operation, CalculatorOperation.add);
      });

      test('inputDecimalPoint calls cubit inputDecimalPoint', () {
        actions.inputDecimalPoint();
        expect(cubit.state.display, '0.');
      });

      test('evaluate calls cubit evaluate', () {
        cubit.inputDigit('1');
        cubit.inputDigit('0');
        cubit.selectOperation(CalculatorOperation.add);
        cubit.inputDigit('5');
        actions.evaluate();
        expect(cubit.state.display, '15');
      });

      test('toggleSign calls cubit toggleSign', () {
        cubit.inputDigit('5');
        actions.toggleSign();
        expect(cubit.state.display, '-5');
      });

      test('applyPercentage calls cubit applyPercentage', () {
        cubit.inputDigit('5');
        cubit.inputDigit('0');
        actions.applyPercentage();
        expect(cubit.state.display, '0.5');
      });

      test('clearAll calls cubit clearAll', () {
        cubit.inputDigit('1');
        cubit.inputDigit('2');
        actions.clearAll();
        expect(cubit.state.display, '0');
      });

      test('backspace calls cubit backspace', () {
        cubit.inputDigit('1');
        cubit.inputDigit('2');
        actions.backspace();
        expect(cubit.state.display, '1');
      });
    });

    group('CalculatorCommand', () {
      test('DigitCommand executes inputDigit', () {
        final command = DigitCommand('7');
        command.execute(actions);
        expect(cubit.state.display, '7');
      });

      test('OperationCommand executes inputOperation', () {
        final command = OperationCommand(CalculatorOperation.subtract);
        command.execute(actions);
        expect(cubit.state.operation, CalculatorOperation.subtract);
      });

      test('DecimalCommand executes inputDecimalPoint', () {
        final command = DecimalCommand();
        command.execute(actions);
        expect(cubit.state.display, '0.');
      });

      test('EvaluateCommand executes evaluate', () {
        cubit.inputDigit('2');
        cubit.selectOperation(CalculatorOperation.multiply);
        cubit.inputDigit('3');
        final command = EvaluateCommand();
        command.execute(actions);
        expect(cubit.state.display, '6');
      });

      test('ToggleSignCommand executes toggleSign', () {
        cubit.inputDigit('8');
        final command = ToggleSignCommand();
        command.execute(actions);
        expect(cubit.state.display, '-8');
      });

      test('ApplyPercentageCommand executes applyPercentage', () {
        cubit.inputDigit('2');
        cubit.inputDigit('5');
        final command = ApplyPercentageCommand();
        command.execute(actions);
        expect(cubit.state.display, '0.25');
      });

      test('ClearAllCommand executes clearAll', () {
        cubit.inputDigit('9');
        cubit.inputDigit('9');
        final command = ClearAllCommand();
        command.execute(actions);
        expect(cubit.state.display, '0');
      });

      test('BackspaceCommand executes backspace', () {
        cubit.inputDigit('4');
        cubit.inputDigit('5');
        cubit.inputDigit('6');
        final command = BackspaceCommand();
        command.execute(actions);
        expect(cubit.state.display, '45');
      });
    });
  });
}
