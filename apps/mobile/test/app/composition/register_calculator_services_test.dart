import 'package:flutter_bloc_app/app/composition/features/register_calculator_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test('registerCalculatorServices registers PaymentCalculator', () {
    registerCalculatorServices();
    expect(getIt<PaymentCalculator>(), isA<PaymentCalculator>());
  });
}
