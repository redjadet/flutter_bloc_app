import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/scapes/data/mock_scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';

/// Registers scapes repository.
void registerScapesServices() {
  registerLazySingletonIfAbsent<ScapesRepository>(MockScapesRepository.new);
}
