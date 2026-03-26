import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/data/fake_in_app_purchase_repository.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/domain/iap_demo_controls.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit.dart';
import 'package:flutter_bloc_app/features/in_app_purchase_demo/presentation/pages/in_app_purchase_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helpers.dart';

void main() {
  group('InAppPurchaseDemoPage', () {
    Widget buildWidget(final InAppPurchaseDemoCubit cubit) => MaterialApp(
      locale: const Locale('en', 'US'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: cubit,
        child: const Scaffold(body: InAppPurchaseDemoPage()),
      ),
    );

    testWidgets('renders page title and products section', (tester) async {
      final repo = FakeInAppPurchaseRepository(
        delay: Duration.zero,
        timerService: FakeTimerService(),
      );
      addTearDown(repo.dispose);
      final cubit = InAppPurchaseDemoCubit(
        fakeRepository: repo,
        realRepository: repo,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await cubit.initialize();
      await tester.pumpAndSettle();

      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Entitlements'), findsOneWidget);
    });

    testWidgets('disables buy for owned premium/subscription', (tester) async {
      final repo = FakeInAppPurchaseRepository(
        delay: Duration.zero,
        timerService: FakeTimerService(),
      );
      addTearDown(repo.dispose);
      final cubit = InAppPurchaseDemoCubit(
        fakeRepository: repo,
        realRepository: repo,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(buildWidget(cubit));
      await cubit.initialize();
      await tester.pumpAndSettle();

      // Purchase premium and subscription to mark them as owned/active.
      repo.forcedOutcome = IapDemoForcedOutcome.success;
      await cubit.buy(
        (await repo.loadProducts()).firstWhere(
          (p) => p.title == 'Premium Unlock',
        ),
      );
      await cubit.buy(
        (await repo.loadProducts()).firstWhere((p) => p.title == 'Pro Monthly'),
      );
      await tester.pumpAndSettle();

      // There should be disabled buttons for those products now.
      final filledButtons = find.byType(FilledButton);
      expect(filledButtons, findsWidgets);
      final List<FilledButton> buttons = tester
          .widgetList<FilledButton>(filledButtons)
          .toList();
      expect(buttons.any((b) => b.onPressed == null), isTrue);
    });
  });
}
