import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_add_device_dialog.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpDialog(
  final WidgetTester tester, {
  required final Future<void> Function(BuildContext) open,
  final ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (final context) => Scaffold(
          body: Center(
            child: TextButton(onPressed: () async => open(context), child: const Text('Open')),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('IotDemoAddDeviceDialogBody', () {
    final AppLocalizationsEn l10n = AppLocalizationsEn();

    testWidgets('empty name shows error and does not close', (final tester) async {
      IotDemoAddDeviceResult? result;
      await _pumpDialog(
        tester,
        open: (final ctx) async {
          result = await showAdaptiveDialog<IotDemoAddDeviceResult>(
            context: ctx,
            builder: (_) => IotDemoAddDeviceDialogBody(l10n: l10n),
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.iotDemoAddDevice), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.iotDemoAddDeviceNameRequired), findsOneWidget);
      expect(result, isNull);
    });

    testWidgets('valid name and type returns result', (final tester) async {
      IotDemoAddDeviceResult? result;
      await _pumpDialog(
        tester,
        open: (final ctx) async {
          result = await showAdaptiveDialog<IotDemoAddDeviceResult>(
            context: ctx,
            builder: (_) => IotDemoAddDeviceDialogBody(l10n: l10n),
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My Light');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.name, 'My Light');
      expect(result!.type.toString(), contains('light'));
      expect(result!.initialValue, 0);
    });

    // Regression: Cupertino path must wrap content in Material so that
    // DropdownButtonFormField (and Slider) have a Material ancestor.
    // Without the wrapper, "No Material widget found" is thrown on iOS.
    testWidgets('builds without error in Cupertino context (Material ancestor for '
        'dropdown)', (final tester) async {
      await _pumpDialog(
        tester,
        theme: ThemeData(platform: TargetPlatform.iOS),
        open: (final ctx) async {
          await showAdaptiveDialog<IotDemoAddDeviceResult>(
            context: ctx,
            builder: (_) => IotDemoAddDeviceDialogBody(l10n: l10n),
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.iotDemoAddDevice), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<IotDeviceType>), findsOneWidget);
    });
  });
}
