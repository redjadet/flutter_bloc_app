import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

/// Pumps [child] inside [MaterialApp] with [MixTheme] so mix tokens and
/// [AppStyles] resolve. Use for widget tests that depend on mix theme
/// (e.g. CommonCard, profile button styles).
///
/// Optional [theme] customizes [ThemeData]; [wrapWithScaffold] wraps the
/// child in a [Scaffold] for layout (default true).
Future<void> pumpWithMixTheme(
  final WidgetTester tester, {
  required final Widget child,
  final ThemeData? theme,
  final bool wrapWithScaffold = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (final context) => MixTheme(
          data: buildAppMixThemeData(context),
          child: wrapWithScaffold ? Scaffold(body: child) : child,
        ),
      ),
    ),
  );
}
