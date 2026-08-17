import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_country_option.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_country_picker.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpPickerHost(
    WidgetTester tester, {
    required TargetPlatform platform,
    required Future<void> Function(BuildContext) onOpen,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => onOpen(context),
                child: const Text('Open picker'),
              ),
            );
          },
        ),
      ),
    );
  }

  group('showCountryPicker', () {
    testWidgets('returns selected country from Material bottom sheet', (
      tester,
    ) async {
      CountryOption? picked;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => buildAppMixScope(
            context,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  picked = await showCountryPicker(
                    context: context,
                    selected: CountryOption.defaultCountry,
                  );
                },
                child: const Text('Open picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Canada'));
      await tester.pumpAndSettle();

      expect(picked?.code, 'CA');
    });

    testWidgets('shows Cupertino action sheet on iOS', (tester) async {
      await pumpPickerHost(
        tester,
        platform: TargetPlatform.iOS,
        onOpen: (context) => showCountryPicker(
          context: context,
          selected: CountryOption.defaultCountry,
        ),
      );

      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
