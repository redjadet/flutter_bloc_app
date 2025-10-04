import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/example_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel(
    'com.example.flutter_bloc_app/native',
  );

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('ExamplePage loads native info and runs isolate samples', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          return <String, Object?>{
            'platform': 'Android',
            'version': '14',
            'manufacturer': 'Google',
            'model': 'Pixel',
          };
        });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ExamplePage(),
      ),
    );

    await tester.tap(find.text(AppLocalizationsEn().exampleNativeInfoButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.byKey(const ValueKey<String>('platform-info-Android-14')),
      findsOneWidget,
    );

    final Finder isolateButtonText = find.text(
      AppLocalizationsEn().exampleRunIsolatesButton,
    );
    await tester.scrollUntilVisible(isolateButtonText, 200);
    await tester.tap(find.byKey(const ValueKey('example-run-isolates-button')));
    await tester.pump();

    ButtonStyleButton isolateButton = tester.widget<ButtonStyleButton>(
      find.byKey(const ValueKey('example-run-isolates-button')),
    );
    expect(isolateButton.onPressed, isNull);

    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('ExamplePage surfaces native info errors', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          throw PlatformException(code: 'unavailable');
        });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ExamplePage(),
      ),
    );

    await tester.tap(find.text(AppLocalizationsEn().exampleNativeInfoButton));
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().exampleNativeInfoError),
      findsOneWidget,
    );
  });
}
