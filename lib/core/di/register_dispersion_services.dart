import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/dispersion/data/hive_dispersion_repository.dart';
import 'package:flutter_bloc_app/features/dispersion/data/image_import_service.dart';
import 'package:flutter_bloc_app/features/dispersion/data/image_import_service_impl.dart';
import 'package:flutter_bloc_app/features/dispersion/data/mann_whitney_service_impl.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_repository.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/mann_whitney_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';

void registerDispersionServices() {
  registerLazySingletonIfAbsent<MannWhitneyService>(
    MannWhitneyServiceImpl.new,
  );
  registerLazySingletonIfAbsent<ImageImportService>(
    ImageImportServiceImpl.new,
  );
  registerLazySingletonIfAbsent<DispersionRepository>(
    () => HiveDispersionRepository(
      hiveService: getIt<HiveService>(),
      mannWhitneyService: getIt<MannWhitneyService>(),
    ),
  );
}
