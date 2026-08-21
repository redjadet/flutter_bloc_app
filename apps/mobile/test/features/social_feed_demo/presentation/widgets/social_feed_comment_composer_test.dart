import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_comment_composer.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCubit extends Mock implements SocialFeedCubit {}

void main() {
  testWidgets(
    'comment sheet opens with re-provided SocialFeedCubit (no ProviderNotFound)',
    (WidgetTester tester) async {
      final _MockCubit cubit = _MockCubit();
      when(() => cubit.stream).thenAnswer(
        (_) => Stream<SocialFeedState>.value(
          SocialFeedState.initial(SocialFeedViewer.alex),
        ),
      );
      when(() => cubit.state)
          .thenReturn(SocialFeedState.initial(SocialFeedViewer.alex));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<SocialFeedCubit>.value(
            value: cubit,
            child: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () =>
                        SocialFeedCommentComposer.show(context, postId: 'p1'),
                    child: const Text('open'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const ValueKey('social-feed-comment-field')),
        findsOneWidget,
      );
      final Finder submit = find.byKey(
        const ValueKey('social-feed-comment-submit'),
      );
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);

      await tester.enterText(
        find.byKey(const ValueKey('social-feed-comment-field')),
        'Nice post',
      );
      await tester.pump();
      expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );
}
