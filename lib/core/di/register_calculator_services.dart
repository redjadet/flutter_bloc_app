import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/calculator/domain/payment_calculator.dart';

void registerCalculatorServices() {
  registerLazySingletonIfAbsent<PaymentCalculator>(PaymentCalculator.new);
}
