import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:utilities/utilities.dart' show AppMemoryTrimLevel;

/// Provides locale-aware formatters used across the calculator feature.
///
/// Formatters are cached per locale to avoid expensive NumberFormat
/// instantiation on every build, improving performance in hot rebuild paths.
/// Why static cache: `NumberFormat` allocation is costly; the map is reachable
/// for the process lifetime until [trimMemory] / [clearCache] ends retention so
/// GC can collect unused locale data (see docs/performance/dart_memory_under_the_hood.md).
class CalculatorFormatters {
  const new _({required this.currency, required this.percent});

  /// Creates formatters based on the locale available in [context].
  ///
  /// Formatters are cached per locale to avoid recreating NumberFormat
  /// instances on every build, which is expensive due to locale data allocation.
  /// Does not retain [context] — only the locale name is stored as the map key.
  factory of(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String localeName = Intl.canonicalizedLocale(locale.toString());

    return _cache.putIfAbsent(
      localeName,
      () => CalculatorFormatters._(
        currency: NumberFormat.simpleCurrency(locale: localeName),
        percent: NumberFormat.percentPattern(localeName),
      ),
    );
  }

  static final Map<String, CalculatorFormatters> _cache =
      <String, CalculatorFormatters>{};

  /// Currency formatter respecting the current locale.
  final NumberFormat currency;

  /// Percent formatter respecting the current locale.
  final NumberFormat percent;

  /// Clears the static locale cache so retained `NumberFormat`s can become
  /// unreachable. Called from `AppMemoryService` on memory pressure.
  static void trimMemory(AppMemoryTrimLevel level) {
    if (level == AppMemoryTrimLevel.pressure) {
      clearCache();
    }
  }

  @visibleForTesting
  static void clearCache() {
    _cache.clear();
  }

  @visibleForTesting
  static int get debugCacheSize => _cache.length;
}
