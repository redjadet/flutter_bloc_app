import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/example_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('responsive shell preserves desktop content cap', (tester) async {
    await _pumpDesktop(
      tester,
      child: ExamplePage(isFirebaseInitialized: false),
    );

    final card = find.byKey(const ValueKey('example-content-card'));
    expect(tester.getSize(card).width, lessThanOrEqualTo(840));
  });

  testWidgets('responsive shell keeps navigation icons proportionate', (
    tester,
  ) async {
    await _pumpDesktop(
      tester,
      child: ExamplePage(isFirebaseInitialized: false),
    );

    final icon = find.byIcon(Icons.checklist);
    expect(tester.getSize(icon).width, inInclusiveRange(20, 32));
  });

  testWidgets('responsive shell preserves desktop action bar cap', (
    tester,
  ) async {
    const barKey = ValueKey('action-bar');
    await _pumpDesktop(
      tester,
      child: Builder(
        builder: (context) => Align(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.barMaxWidth),
            child: const SizedBox(
              key: barKey,
              width: double.infinity,
              height: 48,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(barKey)).width, lessThanOrEqualTo(900));
  });
}

Future<void> _pumpDesktop(WidgetTester tester, {required Widget child}) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ResponsiveScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}
