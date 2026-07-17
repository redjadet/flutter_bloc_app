import 'package:flutter_bloc_app/app/composition/injector_factories.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';

/// Registers counter repository services.
void registerCounterServices() {
  registerLazySingletonIfAbsent<CounterRepository>(createCounterRepository);
}
