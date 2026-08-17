import 'package:flutter_bloc_app/app/widgets/backend_disabled_banner.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('renders nothing when not visible', (tester) async {
    await tester.pumpWidget(wrap(const BackendDisabledBanner(visible: false)));

    expect(find.byIcon(Icons.cloud_off), findsNothing);
    expect(find.text('Backend disabled'), findsNothing);
  });

  testWidgets('renders localized banner when visible', (tester) async {
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
