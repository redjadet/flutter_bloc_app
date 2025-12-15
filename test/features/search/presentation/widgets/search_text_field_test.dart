import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_cubit.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_text_field.dart';
import 'package:flutter_bloc_app/features/search/domain/search_repository.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../test_helpers.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  group('SearchTextField', () {
    late MockSearchRepository mockRepository;
    late FakeTimerService fakeTimerService;
    late SearchCubit cubit;

    setUp(() {
      mockRepository = MockSearchRepository();
      fakeTimerService = FakeTimerService();
      cubit = SearchCubit(
        repository: mockRepository,
        timerService: fakeTimerService,
      );
    });

    tearDown(() {
      cubit.close();
    });

    Widget buildSubject() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<SearchCubit>.value(
            value: cubit,
            child: const SearchTextField(),
          ),
        ),
      );
    }

    testWidgets('renders text field', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(SearchTextField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has initial value "dogs"', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('dogs'));
    });

    testWidgets('calls cubit search on text change', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'cats');
      await tester.pump();

      // The cubit should receive the search call (debounced, so query is set but not executed yet)
      expect(cubit.state.query, equals('cats'));
    });

    testWidgets('clears text when cubit query becomes empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Set some text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Clear search via cubit
      cubit.clearSearch();
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('has correct styling', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Search...'), findsOneWidget);
    });
  });
}
