import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed implementation of [LocaleRepository].
class HiveLocaleRepository extends HiveRepositoryBase
    implements LocaleRepository {
  HiveLocaleRepository({required super.hiveService});

  static const String _boxName = 'settings';
  static const String _keyLocale = 'preferred_locale_code';

  @override
  String get boxName => _boxName;

  @override
  Future<AppLocale?> load() async => StorageGuard.run<AppLocale?>(
    logContext: 'HiveLocaleRepository.load',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic localeValue = box.get(_keyLocale);

      // Validate type and content
      if (localeValue is! String || localeValue.isEmpty) {
        return null;
      }

      try {
        return AppLocale.fromTag(localeValue);
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'Invalid locale tag in Hive: $localeValue',
          error,
          stackTrace,
        );
        // Clean up invalid data
        await safeDeleteKey(box, _keyLocale);
        return null;
      }
    },
    fallback: () => null,
  );

  @override
  Future<void> save(final AppLocale? locale) async => StorageGuard.run<void>(
    logContext: 'HiveLocaleRepository.save',
    action: () async {
      final Box<dynamic> box = await getBox();
      if (locale == null) {
        await box.delete(_keyLocale);
      } else {
        await box.put(_keyLocale, locale.tag);
      }
    },
    fallback: () {},
  );
}
