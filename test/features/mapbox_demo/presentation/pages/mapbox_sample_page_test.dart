import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/mapbox_demo/presentation/pages/mapbox_sample_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() {
    SecretConfig.resetForTest();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required TargetPlatform platform,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MapboxSamplePage(platformOverride: platform),
      ),
    );
  }

  group('MapboxSamplePage', () {
    testWidgets('shows unsupported message on non-mobile platforms', (
      tester,
    ) async {
      await pumpPage(tester, platform: TargetPlatform.macOS);
      await tester.pumpAndSettle();

      expect(find.text(l10n.mapboxPageUnsupportedDescription), findsOneWidget);
      expect(find.byType(MapWidget), findsNothing);
    });

    testWidgets(
      'shows missing token message when MAPBOX_ACCESS_TOKEN is absent',
      (tester) async {
        await pumpPage(tester, platform: TargetPlatform.android);
        await tester.pumpAndSettle();

        expect(find.text(l10n.mapboxPageMissingTokenTitle), findsOneWidget);
        expect(
          find.text(l10n.mapboxPageMissingTokenDescription),
          findsOneWidget,
        );
        expect(find.byType(MapWidget), findsNothing);
      },
    );
  });
}
