import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_compare_graph.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DispersionCompareGraph', () {
    Widget buildSubject({
      final List<DispersionPoint> pointsA = const [],
      final List<DispersionPoint> pointsB = const [],
    }) {
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: DispersionCompareGraph(
              pointsA: pointsA,
              pointsB: pointsB,
            ),
          ),
        ),
      );
    }

    testWidgets('shows No points when both lists empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('No points'), findsOneWidget);
    });

    testWidgets('shows legend with A and B when points provided', (tester) async {
      final pointsA = <DispersionPoint>[
        const DispersionPoint(
          id: '1',
          xMm: 5,
          yMm: 0,
          radialMm: 5,
          holeDiameterMm: 5,
        ),
      ];
      await tester.pumpWidget(buildSubject(pointsA: pointsA));
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('Outlier'), findsOneWidget);
    });

    testWidgets('renders CustomPaint when points exist', (tester) async {
      final pointsA = <DispersionPoint>[
        const DispersionPoint(
          id: '1',
          xMm: 1,
          yMm: 0,
          radialMm: 1,
          holeDiameterMm: 5,
        ),
      ];
      await tester.pumpWidget(buildSubject(pointsA: pointsA));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPaint), findsAtLeast(1));
    });
  });
}
