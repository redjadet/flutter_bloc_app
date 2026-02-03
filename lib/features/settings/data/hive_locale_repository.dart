import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_settings_repository.dart';

/// Hive-backed implementation of [LocaleRepository].
class HiveLocaleRepository extends HiveSettingsRepository<AppLocale>
    implements LocaleRepository {
  HiveLocaleRepository({required super.hiveService})
    : super(
        key: 'preferred_locale_code',
        fromString: AppLocale.fromTag,
        toStringValue: (final locale) => locale.tag,
      );
}
