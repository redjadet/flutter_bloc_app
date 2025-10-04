import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_sections.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    UI.resetScreenUtilReady();
  });

  testWidgets('PlatformInfoSection shows loading indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithApp(
        const PlatformInfoSection(
          isLoading: true,
          info: null,
          errorMessage: null,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('PlatformInfoSection renders localized error message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithApp(
        const PlatformInfoSection(
          isLoading: false,
          info: null,
          errorMessage: 'boom',
        ),
      ),
    );

    final AppLocalizationsEn en = AppLocalizationsEn();
    expect(find.text(en.exampleNativeInfoError), findsOneWidget);
  });

  testWidgets('PlatformInfoSection shows resolved platform info', (
    WidgetTester tester,
  ) async {
    const NativePlatformInfo info = NativePlatformInfo(
      platform: 'iOS',
      version: '17.1',
      manufacturer: 'Apple',
      model: 'iPhone 15',
    );

    await tester.pumpWidget(
      _wrapWithApp(
        const PlatformInfoSection(
          isLoading: false,
          info: info,
          errorMessage: null,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('platform-info-iOS-17.1')),
      findsOneWidget,
    );
    expect(find.text(info.toString()), findsOneWidget);
  });

  testWidgets('IsolateResultSection shows loading indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithApp(
        const IsolateResultSection(
          isLoading: true,
          errorMessage: null,
          fibonacciInput: null,
          fibonacciResult: null,
          parallelValues: null,
          parallelDuration: null,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('IsolateResultSection renders error message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithApp(
        const IsolateResultSection(
          isLoading: false,
          errorMessage: 'Computation failed',
          fibonacciInput: null,
          fibonacciResult: null,
          parallelValues: null,
          parallelDuration: null,
        ),
      ),
    );

    expect(find.text('Computation failed'), findsOneWidget);
  });

  testWidgets('IsolateResultSection shows computed results', (
    WidgetTester tester,
  ) async {
    const Duration duration = Duration(milliseconds: 180);

    await tester.pumpWidget(
      _wrapWithApp(
        const IsolateResultSection(
          isLoading: false,
          errorMessage: null,
          fibonacciInput: 18,
          fibonacciResult: 2584,
          parallelValues: <int>[4, 8, 16],
          parallelDuration: duration,
        ),
      ),
    );

    final AppLocalizationsEn en = AppLocalizationsEn();
    expect(
      find.byKey(const ValueKey<String>('isolate-result-0:00:00.180000')),
      findsOneWidget,
    );
    expect(
      find.text(en.exampleIsolateFibonacciLabel(18, 2584)),
      findsOneWidget,
    );
    expect(
      find.text(en.exampleIsolateParallelComplete('4, 8, 16', 180)),
      findsOneWidget,
    );
  });
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
