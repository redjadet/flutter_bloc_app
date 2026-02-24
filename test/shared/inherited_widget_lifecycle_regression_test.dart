import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/playlearn_page.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/pages/vocabulary_list_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for "InheritedWidget in one-time lifecycle" bug.
///
/// Do not call context.l10n (or Theme.of(context), etc.) inside BlocProvider/Provider
/// `create` or in initState—those lifecycles run once and must not register as
/// InheritedWidget listeners. Read l10n in build() and pass the value into create.
///
void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
    getIt.registerSingleton<VocabularyRepository>(_FakeVocabularyRepository());
    getIt.registerSingleton<AudioPlaybackService>(_FakeAudioPlaybackService());
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('InheritedWidget in one-time lifecycle (BlocProvider create)', () {
    testWidgets(
      'PlaylearnPage builds without reading context.l10n in BlocProvider create',
      (WidgetTester tester) async {
        await _pumpLocalizedPage(tester, const PlaylearnPage());
        expect(tester.takeException(), isNull);
        expect(find.byType(PlaylearnPage), findsOneWidget);
      },
    );

    testWidgets(
      'VocabularyListPage builds without reading context.l10n in BlocProvider create',
      (WidgetTester tester) async {
        await _pumpLocalizedPage(
          tester,
          const VocabularyListPage(topicId: 'animals'),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(VocabularyListPage), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpLocalizedPage(
  final WidgetTester tester,
  final Widget page,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    ),
  );
  await tester.pump();
}

class _FakeVocabularyRepository implements VocabularyRepository {
  @override
  List<TopicItem> getTopics() => const <TopicItem>[];

  @override
  List<VocabularyItem> getWordsByTopic(final String topicId) =>
      const <VocabularyItem>[];
}

class _FakeAudioPlaybackService implements AudioPlaybackService {
  @override
  Future<void> speak(final String text) => Future<void>.value();

  @override
  Future<void> stop() => Future<void>.value();
}
