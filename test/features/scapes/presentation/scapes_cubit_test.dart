import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScapesCubit', () {
    blocTest<ScapesCubit, ScapesState>(
      'initial state emits loading then loads scapes',
      build: ScapesCubit.new,
      // The constructor calls _loadScapes() which emits loading immediately,
      // but bloc_test doesn't capture states emitted synchronously during build phase.
      // We wait for the delayed completion state only.
      wait: const Duration(milliseconds: 350),
      expect: () => [
        isA<ScapesState>()
            .having((final s) => s.isLoading, 'isLoading', false)
            .having((final s) => s.scapes.length, 'scapes length', 6),
      ],
    );

    blocTest<ScapesCubit, ScapesState>(
      'toggleViewMode switches between grid and list',
      build: ScapesCubit.new,
      seed: () => const ScapesState(viewMode: ScapesViewMode.grid),
      act: (final cubit) => cubit.toggleViewMode(),
      expect: () => [const ScapesState(viewMode: ScapesViewMode.list)],
    );

    blocTest<ScapesCubit, ScapesState>(
      'toggleViewMode switches from list to grid',
      build: ScapesCubit.new,
      seed: () => const ScapesState(viewMode: ScapesViewMode.list),
      act: (final cubit) => cubit.toggleViewMode(),
      expect: () => [const ScapesState(viewMode: ScapesViewMode.grid)],
    );

    blocTest<ScapesCubit, ScapesState>(
      'toggleFavorite toggles favorite status for specific scape',
      build: ScapesCubit.new,
      seed: () => ScapesState(
        scapes: [
          Scape(
            id: 'scape_0',
            name: 'Test Scape',
            imageUrl: 'https://example.com/image.jpg',
            duration: const Duration(minutes: 5),
            assetCount: 10,
            isFavorite: false,
          ),
          Scape(
            id: 'scape_1',
            name: 'Another Scape',
            imageUrl: 'https://example.com/image2.jpg',
            duration: const Duration(minutes: 3),
            assetCount: 5,
            isFavorite: false,
          ),
        ],
      ),
      act: (final cubit) => cubit.toggleFavorite('scape_0'),
      expect: () => [
        isA<ScapesState>().having(
          (final s) => s.scapes.first.isFavorite,
          'first scape isFavorite',
          true,
        ),
      ],
      verify: (final cubit) {
        expect(cubit.state.scapes.first.isFavorite, isTrue);
        expect(cubit.state.scapes[1].isFavorite, isFalse);
      },
    );

    blocTest<ScapesCubit, ScapesState>(
      'toggleFavorite toggles favorite from true to false',
      build: ScapesCubit.new,
      seed: () => ScapesState(
        scapes: [
          Scape(
            id: 'scape_0',
            name: 'Test Scape',
            imageUrl: 'https://example.com/image.jpg',
            duration: const Duration(minutes: 5),
            assetCount: 10,
            isFavorite: true,
          ),
        ],
      ),
      act: (final cubit) => cubit.toggleFavorite('scape_0'),
      expect: () => [
        isA<ScapesState>().having(
          (final s) => s.scapes.first.isFavorite,
          'first scape isFavorite',
          false,
        ),
      ],
    );

    test('toggleFavorite does nothing for non-existent scape id', () async {
      final cubit = ScapesCubit();
      addTearDown(cubit.close);

      // Wait for initial load
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // Set up test state with known scape
      final initialState = cubit.state;
      final testScapes = [
        Scape(
          id: 'scape_0',
          name: 'Test Scape',
          imageUrl: 'https://example.com/image.jpg',
          duration: const Duration(minutes: 5),
          assetCount: 10,
          isFavorite: false,
        ),
      ];
      cubit.emit(initialState.copyWith(scapes: testScapes));

      // Try to toggle non-existent scape
      cubit.toggleFavorite('non_existent');

      // State should be unchanged (no emission, or emission with same scapes)
      expect(cubit.state.scapes.length, 1);
      expect(cubit.state.scapes.first.isFavorite, isFalse);
    });

    test('reload resets loading state and loads scapes', () async {
      final cubit = ScapesCubit();
      addTearDown(cubit.close);

      // Wait for initial load to complete
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // Verify initial load completed
      expect(cubit.state.scapes.length, 6);
      expect(cubit.state.isLoading, isFalse);

      // Clear scapes manually and call reload
      cubit.emit(cubit.state.copyWith(scapes: [], isLoading: false));
      cubit.reload();

      // Check loading state is set immediately
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.errorMessage, isNull);

      // Wait for reload to complete
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // Check loaded state
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.scapes.length, 6);
    });
  });
}
