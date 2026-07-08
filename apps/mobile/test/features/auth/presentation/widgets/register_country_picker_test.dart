import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_country_option.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_country_picker.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPickerHost(
    final WidgetTester tester, {
    required final TargetPlatform platform,
    required final Future<void> Function(BuildContext) onOpen,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (final context) {
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
      final tester,
    ) async {
      CountryOption? picked;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (final context, final child) => buildAppMixScope(
            context,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(
            body: Builder(
              builder: (final context) => TextButton(
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

    testWidgets('shows Cupertino action sheet on iOS', (final tester) async {
      await pumpPickerHost(
        tester,
        platform: TargetPlatform.iOS,
        onOpen: (final context) => showCountryPicker(
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
