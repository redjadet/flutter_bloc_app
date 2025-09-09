// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get autoLabel => 'Auto';

  @override
  String get pausedLabel => 'Paused';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Next auto-decrement in: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Auto-decrement paused !!!';

  @override
  String get lastChangedLabel => 'Last changed:';

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String get homeTitle => 'Flutter Demo Home Page';

  @override
  String get pushCountLabel => 'You have pushed the button this many times:';

  @override
  String get incrementTooltip => 'Increment';

  @override
  String get decrementTooltip => 'Decrement';

  @override
  String get loadErrorMessage => 'Failed to load saved counter';
}
