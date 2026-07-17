import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/settings/data/hive_locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/hive_theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/data/package_info_app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:storage/storage.dart';

/// Registers settings locale/theme/app-info repositories.
void registerSettingsServices() {
  registerLazySingletonIfAbsent<LocaleRepository>(
    () => HiveLocaleRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<ThemeRepository>(
    () => HiveThemeRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<AppInfoRepository>(
    () => const PackageInfoAppInfoRepository(),
  );
}
