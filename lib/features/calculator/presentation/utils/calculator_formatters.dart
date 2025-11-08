import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Provides locale-aware formatters used across the calculator feature.
class CalculatorFormatters {
  const CalculatorFormatters._({
    required this.currency,
    required this.percent,
  });

  /// Creates formatters based on the locale available in [context].
  factory CalculatorFormatters.of(final BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String localeName = Intl.canonicalizedLocale(locale.toString());
    return CalculatorFormatters._(
      currency: NumberFormat.simpleCurrency(locale: localeName),
      percent: NumberFormat.percentPattern(localeName),
    );
  }

  /// Currency formatter respecting the current locale.
  final NumberFormat currency;

  /// Percent formatter respecting the current locale.
  final NumberFormat percent;
}
