import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';

/// Abstraction for persisting and loading theme mode.
abstract class ThemeRepository {
  Future<ThemePreference?> load();
  Future<void> save(final ThemePreference mode);
}
