import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/calculator/calculator.dart';

void main() {
  const PaymentCalculator calculator = PaymentCalculator();

  CalculatorCubit buildCubit() => CalculatorCubit(calculator: calculator);

  test('initial state is empty', () {
    final cubit = buildCubit();
    expect(cubit.state, const CalculatorState());
  });

  blocTest<CalculatorCubit, CalculatorState>(
    'inputDigit composes new amount',
    build: buildCubit,
    act: (final cubit) => cubit
      ..inputDigit('1')
      ..inputDigit('2')
      ..inputDigit('3'),
    expect: () => const <CalculatorState>[
      CalculatorState(display: '1', replaceInput: false),
      CalculatorState(display: '12', replaceInput: false),
      CalculatorState(display: '123', replaceInput: false),
    ],
  );

  blocTest<CalculatorCubit, CalculatorState>(
    'decimal point is added only once',
    build: buildCubit,
    act: (final cubit) => cubit
      ..inputDigit('4')
      ..inputDecimalPoint()
      ..inputDecimalPoint()
      ..inputDigit('5'),
    expect: () => const <CalculatorState>[
      CalculatorState(display: '4', replaceInput: false),
      CalculatorState(display: '4.', replaceInput: false),
      CalculatorState(display: '4.', replaceInput: false),
      CalculatorState(display: '4.5', replaceInput: false),
    ],
  );

  blocTest<CalculatorCubit, CalculatorState>(
    'evaluates addition and stores last operand for repeated equals',
    build: buildCubit,
    act: (final cubit) => cubit
      ..inputDigit('1')
      ..inputDigit('0')
      ..selectOperation(CalculatorOperation.add)
      ..inputDigit('5')
      ..evaluate()
      ..evaluate(),
    expect: () => <CalculatorState>[
      const CalculatorState(display: '1', replaceInput: false),
      const CalculatorState(display: '10', replaceInput: false),
      const CalculatorState(
        display: '10',
        accumulator: 10,
        operation: CalculatorOperation.add,
        replaceInput: true,
        history: '10+',
      ),
      const CalculatorState(
        display: '5',
        accumulator: 10,
        operation: CalculatorOperation.add,
        replaceInput: false,
        history: '10+',
      ),
      const CalculatorState(
        display: '15',
        replaceInput: true,
        lastOperand: 5,
        lastOperation: CalculatorOperation.add,
        settledAmount: 15,
        history: '10+5',
      ),
      const CalculatorState(
        display: '20',
        replaceInput: true,
        lastOperand: 5,
        lastOperation: CalculatorOperation.add,
        settledAmount: 20,
        history: '15+5',
      ),
    ],
  );

  blocTest<CalculatorCubit, CalculatorState>(
    'backspace removes digits and resets to zero',
    build: buildCubit,
    act: (final cubit) => cubit
      ..inputDigit('9')
      ..inputDigit('9')
      ..backspace()
      ..backspace(),
    expect: () => const <CalculatorState>[
      CalculatorState(display: '9', replaceInput: false),
      CalculatorState(display: '99', replaceInput: false),
      CalculatorState(display: '9', replaceInput: false),
      CalculatorState(display: '0', replaceInput: false),
    ],
  );

  blocTest<CalculatorCubit, CalculatorState>(
    'clearAll resets to defaults',
    build: buildCubit,
    act: (final cubit) => cubit
      ..inputDigit('3')
      ..setTaxRate(0.2)
      ..setTipRate(0.15)
      ..clearAll(),
    expect: () => const <CalculatorState>[
      CalculatorState(display: '3', replaceInput: false),
      CalculatorState(display: '3', replaceInput: false, taxRate: 0.2),
      CalculatorState(
        display: '3',
        replaceInput: false,
        taxRate: 0.2,
        tipRate: 0.15,
      ),
      CalculatorState(),
    ],
  );

  test('summary helpers honour tax and tip rates after evaluation', () {
    final cubit = buildCubit();
    cubit
      ..inputDigit('2')
      ..inputDigit('5')
      ..inputDecimalPoint()
      ..inputDigit('0')
      ..setTaxRate(0.08)
      ..setTipRate(0.18)
      ..evaluate();

    final CalculatorState state = cubit.state;
    expect(state.subtotal(calculator), 25.0);
    expect(state.taxAmount(calculator), 2.0);
    expect(state.tipAmount(calculator), 4.5);
    expect(state.total(calculator), 31.5);
  });

  test('summary values remain unchanged until evaluation', () {
    final cubit = buildCubit();
    cubit
      ..inputDigit('5')
      ..inputDigit('0');

    expect(cubit.state.subtotal(calculator), 0);

    cubit.evaluate();
    expect(cubit.state.subtotal(calculator), 50);
  });

  test('toggleSign negates the current value', () {
    final cubit = buildCubit();
    cubit
      ..inputDigit('4')
      ..inputDigit('2')
      ..toggleSign();

    expect(cubit.state.display, '-42');

    cubit.toggleSign();
    expect(cubit.state.display, '42');
  });

  test('applyPercentage divides value by 100', () {
    final cubit = buildCubit();
    cubit
      ..inputDigit('5')
      ..inputDigit('0')
      ..applyPercentage();

    expect(cubit.state.display, '0.5');
  });

  test('toggleSign keeps zero untouched', () {
    final cubit = buildCubit();
    cubit.toggleSign();
    expect(cubit.state.display, '0');
  });

  blocTest<CalculatorCubit, CalculatorState>(
    'new entry after evaluation clears history',
    build: buildCubit,
    act: (final cubit) => cubit
      ..inputDigit('9')
      ..selectOperation(CalculatorOperation.add)
      ..inputDigit('1')
      ..evaluate()
      ..inputDigit('2'),
    expect: () => <CalculatorState>[
      const CalculatorState(display: '9', replaceInput: false),
      const CalculatorState(
        display: '9',
        accumulator: 9,
        operation: CalculatorOperation.add,
        replaceInput: true,
        history: '9+',
      ),
      const CalculatorState(
        display: '1',
        accumulator: 9,
        operation: CalculatorOperation.add,
        replaceInput: false,
        history: '9+',
      ),
      const CalculatorState(
        display: '10',
        replaceInput: true,
        settledAmount: 10,
        history: '9+1',
      ),
      const CalculatorState(display: '2', replaceInput: false),
    ],
  );

  test('divide by zero returns zero without errors', () {
    final cubit = buildCubit();
    cubit
      ..inputDigit('8')
      ..selectOperation(CalculatorOperation.divide)
      ..inputDigit('0')
      ..evaluate();

    expect(
      cubit.state,
      const CalculatorState(
        display: '0',
        replaceInput: true,
        settledAmount: 0,
        history: '8÷0',
        lastOperand: 0,
        lastOperation: CalculatorOperation.divide,
      ),
    );
  });
}
