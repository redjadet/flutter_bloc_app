import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
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
  });
}
