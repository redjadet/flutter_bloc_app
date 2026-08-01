import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_factories.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';

/// Registers counter repository services.
void registerCounterServices() {
  registerLazySingletonIfAbsent<CounterRepository>(createCounterRepository);
  registerLazySingletonIfAbsent<CounterSyncDiagnosticsPort>(() {
    final CounterRepository repo = getIt<CounterRepository>();
    if (repo is CounterSyncDiagnosticsPort) {
      return repo as CounterSyncDiagnosticsPort;
    }
    return const NoPendingCounterSyncDiagnostics();
  });
}
