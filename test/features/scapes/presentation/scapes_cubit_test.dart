import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_cubit.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers.dart' show FakeTimerService;

/// Stub that returns completed future so .then() runs in same turn when used in
/// timer callback.
class _StubScapesRepository implements ScapesRepository {
  _StubScapesRepository(this.scapes);

  final List<Scape> scapes;

  @override
  Future<List<Scape>> loadScapes() => Future.value(List<Scape>.from(scapes));
}

class _SyncThrowScapesRepository implements ScapesRepository {
  @override
  Future<List<Scape>> loadScapes() {
    throw StateError('sync load failure');
  }
}

List<Scape> _defaultScapes() => List.generate(
  6,
  (final i) => Scape(
    id: 'scape_$i',
    name: 'Scape ${i + 1}',
    imageUrl: 'https://example.com/$i.jpg',
    duration: Duration(seconds: 60 + i),
    assetCount: 10 + i,
  ),
);

void main() {
  late _StubScapesRepository repository;
  late FakeTimerService timerService;

  setUp(() {
    repository = _StubScapesRepository(_defaultScapes());
    timerService = FakeTimerService();
  });

  ScapesCubit buildCubit() =>
      ScapesCubit(repository: repository, timerService: timerService);

  group('ScapesCubit', () {
    blocTest<ScapesCubit, ScapesState>(
      'initial state emits loading then loads scapes',
      build: buildCubit,
      act: (final cubit) =>
          timerService.elapse(const Duration(milliseconds: 350)),
      // The constructor calls _loadScapes() which emits loading immediately,
      // but bloc_test doesn't capture states emitted synchronously during build phase.
      // We wait for the delayed completion state only.
      expect: () => [
        isA<ScapesState>()
            .having((final s) => s.isLoading, 'isLoading', false)
            .having((final s) => s.scapes.length, 'scapes length', 6),
      ],
    );

    blocTest<ScapesCubit, ScapesState>(
      'toggleViewMode switches between grid and list',
      build: buildCubit,
      seed: () => const ScapesState(viewMode: ScapesViewMode.grid),
      act: (final cubit) => cubit.toggleViewMode(),
      expect: () => [const ScapesState(viewMode: ScapesViewMode.list)],
    );

    blocTest<ScapesCubit, ScapesState>(
      'toggleViewMode switches from list to grid',
      build: buildCubit,
      seed: () => const ScapesState(viewMode: ScapesViewMode.list),
      act: (final cubit) => cubit.toggleViewMode(),
      expect: () => [const ScapesState(viewMode: ScapesViewMode.grid)],
    );

    blocTest<ScapesCubit, ScapesState>(
      'toggleFavorite toggles favorite status for specific scape',
      build: buildCubit,
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
      build: buildCubit,
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
      final cubit = buildCubit();
      addTearDown(cubit.close);

      timerService.elapse(const Duration(milliseconds: 350));

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
      final cubit = buildCubit();
      addTearDown(cubit.close);

      timerService.elapse(const Duration(milliseconds: 350));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.scapes.length, 6);
      expect(cubit.state.isLoading, isFalse);

      cubit.emit(cubit.state.copyWith(scapes: [], isLoading: false));
      cubit.reload();

      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.errorMessage, isNull);

      timerService.elapse(const Duration(milliseconds: 350));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.scapes.length, 6);
    });

    test(
      'load emits error state when repository throws synchronously',
      () async {
        final cubit = ScapesCubit(
          repository: _SyncThrowScapesRepository(),
          timerService: timerService,
        );
        addTearDown(cubit.close);

        timerService.elapse(const Duration(milliseconds: 350));

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.errorMessage, contains('sync load failure'));
      },
    );
  });
}
