import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/common_app_bar.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget({
    required String title,
    required String homeTooltip,
    List<Widget>? actions,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: CommonAppBar(
          title: title,
          homeTooltip: homeTooltip,
          actions: actions,
        ),
        body: const Text('Content'),
      ),
    );
  }

  group('CommonAppBar', () {
    testWidgets('renders with title and home tooltip', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Home';

      await tester.pumpWidget(
        createTestWidget(title: title, homeTooltip: homeTooltip),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byType(RootAwareBackButton), findsOneWidget);
    });

    testWidgets('renders with actions', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Home';
      final actions = [
        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ];

      await tester.pumpWidget(
        createTestWidget(
          title: title,
          homeTooltip: homeTooltip,
          actions: actions,
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('renders without actions', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Home';

      await tester.pumpWidget(
        createTestWidget(title: title, homeTooltip: homeTooltip),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byType(RootAwareBackButton), findsOneWidget);
    });

    testWidgets('passes home tooltip to RootAwareBackButton', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Go Home';

      await tester.pumpWidget(
        createTestWidget(title: title, homeTooltip: homeTooltip),
      );

      final backButton = tester.widget<RootAwareBackButton>(
        find.byType(RootAwareBackButton),
      );
      expect(backButton.homeTooltip, equals(homeTooltip));
    });

    testWidgets('renders as AppBar with correct properties', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Home';

      await tester.pumpWidget(
        createTestWidget(title: title, homeTooltip: homeTooltip),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      expect((appBar.title as Text).data, equals(title));
      expect(appBar.leading, isA<RootAwareBackButton>());
    });

    testWidgets('applies theme correctly', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Home';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: CommonAppBar(title: title, homeTooltip: homeTooltip),
            body: const Text('Content'),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Colors.blue));
    });

    testWidgets('handles empty actions list', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Home';

      await tester.pumpWidget(
        createTestWidget(
          title: title,
          homeTooltip: homeTooltip,
          actions: const [],
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byType(RootAwareBackButton), findsOneWidget);
    });

    testWidgets('handles null actions', (tester) async {
      const title = 'Test Page';
      const homeTooltip = 'Home';

      await tester.pumpWidget(
        createTestWidget(title: title, homeTooltip: homeTooltip, actions: null),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byType(RootAwareBackButton), findsOneWidget);
    });
  });
}
