import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/listen_button.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/word_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const VocabularyItem item = VocabularyItem(
    id: '1',
    wordEn: 'Cat',
    topicId: 'animals',
  );

  Future<void> pumpWordCard(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: WordCard(item: item, onListen: () {}),
        ),
      ),
    );
  }

  group('WordCard', () {
    testWidgets('displays word text', (WidgetTester tester) async {
      await pumpWordCard(tester);

      expect(find.text('Cat'), findsOneWidget);
    });

    testWidgets('shows ListenButton', (WidgetTester tester) async {
      await pumpWordCard(tester);

      expect(find.byType(ListenButton), findsOneWidget);
    });

    testWidgets('invokes onListen when listen button is tapped', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WordCard(item: item, onListen: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(ListenButton));
      expect(tapped, isTrue);
    });
  });
}
