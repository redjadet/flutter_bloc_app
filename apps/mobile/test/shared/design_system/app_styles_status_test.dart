import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

import '../../helpers/pump_with_mix_theme.dart';

void main() {
  group('AppStyles status styles', () {
    testWidgets('resolve documented status and outline styles', (
      final tester,
    ) async {
      await pumpWithMixTheme(
        tester,
        child: Column(
          children: [
            Box(style: AppStyles.statusSuccess, child: const Text('Success')),
            Box(style: AppStyles.statusError, child: const Text('Error')),
            Box(
              style: AppStyles.inputOutline,
              child: const SizedBox(width: 24, height: 24),
            ),
          ],
        ),
      );

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.byType(Box), findsNWidgets(3));
    });

    testWidgets('resolve layout and button styles', (final tester) async {
      await pumpWithMixTheme(
        tester,
        child: Column(
          children: [
            Box(style: AppStyles.card, child: const Text('Card')),
            Box(
              style: AppStyles.profileOutlinedButton,
              child: const Text('Profile'),
            ),
            Box(style: AppStyles.filledButton, child: const Text('Filled')),
            Box(style: AppStyles.outlinedButton, child: const Text('Outlined')),
            Box(style: AppStyles.listTile, child: const Text('Tile')),
            Box(style: AppStyles.inputField, child: const Text('Input')),
            Box(style: AppStyles.inputFieldShell, child: const Text('Shell')),
            Box(style: AppStyles.appBar, child: const Text('App bar')),
            Box(style: AppStyles.banner, child: const Text('Banner')),
            Box(style: AppStyles.emptyState, child: const Text('Empty')),
            Box(style: AppStyles.chip, child: const Text('Chip')),
          ],
        ),
      );

      expect(AppStyles.profileOutlinedButtonText, isNotNull);
      expect(AppStyles.filledButtonText, isNotNull);
      expect(AppStyles.outlinedButtonText, isNotNull);
      expect(find.byType(Box), findsNWidgets(11));
    });
  });
}
