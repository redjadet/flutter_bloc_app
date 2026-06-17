import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/backend_disabled_banner.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(final Widget child) => MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('renders nothing when not visible', (final tester) async {
    await tester.pumpWidget(wrap(const BackendDisabledBanner(visible: false)));

    expect(find.byIcon(Icons.cloud_off), findsNothing);
    expect(find.text('Backend disabled'), findsNothing);
  });

  testWidgets('renders localized banner when visible', (final tester) async {
    await tester.pumpWidget(wrap(const BackendDisabledBanner(visible: true)));

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text('Backend disabled'), findsOneWidget);
    expect(
      find.text(
        'Running in web no-backend mode. Firebase/Supabase not configured.',
      ),
      findsOneWidget,
    );
  });
}
