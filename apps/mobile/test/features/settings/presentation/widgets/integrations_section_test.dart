import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/integrations_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('IntegrationsSection trailing chevron is size-capped', (
    final tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(size: Size(1200, 900)),
          child: Scaffold(body: IntegrationsSection()),
        ),
      ),
    );

    final SizedBox box = tester.widget<SizedBox>(
      find.byWidgetPredicate(
        (final widget) =>
            widget is SizedBox &&
            widget.width == 24 &&
            widget.height == 24 &&
            widget.child is Center,
      ),
    );
    expect(box.width, 24);
    expect(box.height, 24);

    final Icon icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(IntegrationsSection),
        matching: find.byType(Icon),
      ),
    );
    expect(icon.size, 18);
  });
}
