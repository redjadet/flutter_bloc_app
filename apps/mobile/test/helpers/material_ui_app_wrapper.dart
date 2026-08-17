import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Wrapper for golden_toolkit [pumpWidgetBuilder] after Flutter 3.47.
///
/// `package:golden_toolkit` [materialAppWrapper] still builds
/// `package:flutter/material.dart` [MaterialApp]. App widgets look up
/// `package:material_ui` [ThemeData] and [MaterialLocalizations], so that
/// wrapper drops dark theme and fails locales such as `tr`.
Widget Function(Widget child) materialUiAppWrapper({
  TargetPlatform platform = TargetPlatform.android,
  ThemeData? theme,
  Iterable<Locale>? localeOverrides,
}) {
  return (child) => MaterialApp(
    localizationsDelegates: appLocalizationDelegates,
    supportedLocales: localeOverrides ?? AppLocalizations.supportedLocales,
    locale: localeOverrides != null && localeOverrides.isNotEmpty
        ? localeOverrides.first
        : null,
    theme: (theme ?? ThemeData.light()).copyWith(platform: platform),
    debugShowCheckedModeBanner: false,
    home: Material(child: child),
  );
}
