import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Provides locale-aware formatters used across the calculator feature.
///
/// Formatters are cached per locale to avoid expensive NumberFormat
/// instantiation on every build, improving performance in hot rebuild paths.
class CalculatorFormatters {
  const CalculatorFormatters._({
    required this.currency,
    required this.percent,
  });

  /// Creates formatters based on the locale available in [context].
  ///
  /// Formatters are cached per locale to avoid recreating NumberFormat
  /// instances on every build, which is expensive due to locale data allocation.
  factory CalculatorFormatters.of(final BuildContext context) {
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
}
