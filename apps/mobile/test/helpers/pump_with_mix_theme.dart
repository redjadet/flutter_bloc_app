import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps [child] inside [MaterialApp] with [MixScope] so mix tokens and
/// [AppStyles] resolve. Use for widget tests that depend on mix theme
/// (e.g. CommonCard, profile button styles).
///
/// Optional [theme] customizes [ThemeData]; [wrapWithScaffold] wraps the
/// child in a [Scaffold] for layout (default true).
Future<void> pumpWithMixTheme(
  WidgetTester tester, {
  required Widget child,
  ThemeData? theme,
  bool wrapWithScaffold = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) => buildAppMixScope(
          context,
          child: wrapWithScaffold ? Scaffold(body: child) : child,
        ),
      ),
    ),
  );
}
