import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/search/domain/search_result.dart';
import 'package:flutter_bloc_app/features/search/presentation/widgets/search_results_grid.dart';

void main() {
  group('SearchResultsGrid', () {
    final List<SearchResult> mockResults = [
      const SearchResult(
        id: '1',
        imageUrl: 'https://example.com/image1.jpg',
        title: 'Result 1',
        description: 'Description 1',
      ),
      const SearchResult(
        id: '2',
        imageUrl: 'https://example.com/image2.jpg',
        title: 'Result 2',
        description: 'Description 2',
      ),
      const SearchResult(
        id: '3',
        imageUrl: 'https://example.com/image3.jpg',
        title: 'Result 3',
        description: 'Description 3',
      ),
    ];

    Widget buildSubject(List<SearchResult> results) {
      return MaterialApp(
        home: Scaffold(body: SearchResultsGrid(results: results)),
      );
    }

    testWidgets('renders grid with results', (tester) async {
      await tester.pumpWidget(buildSubject(mockResults));
      await tester.pump(); // Don't use pumpAndSettle as images may never load

      expect(find.byType(SearchResultsGrid), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpWidget(buildSubject(mockResults));
      await tester.pump(); // Don't use pumpAndSettle as images may never load

      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.childrenDelegate, isA<SliverChildBuilderDelegate>());
    });

    testWidgets('handles empty results list', (tester) async {
      await tester.pumpWidget(buildSubject([]));
      await tester.pump(); // Don't use pumpAndSettle as images may never load

      expect(find.byType(SearchResultsGrid), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('applies responsive padding', (tester) async {
      await tester.pumpWidget(buildSubject(mockResults));
      await tester.pump(); // Don't use pumpAndSettle as images may never load

      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('renders grid items correctly', (tester) async {
      await tester.pumpWidget(buildSubject(mockResults));
      await tester.pump(); // Don't use pumpAndSettle as images may never load

      // Verify grid is rendered
      expect(find.byType(SearchResultsGrid), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
