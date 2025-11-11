import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';

/// Abstraction for persisting and loading a user-selected app locale.
abstract class LocaleRepository {
  Future<AppLocale?> load();
  Future<void> save(final AppLocale? locale);
}
