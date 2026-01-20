import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart' as genui;
import 'package:mocktail/mocktail.dart';

class _MockGenUiDemoAgent extends Mock implements GenUiDemoAgent {}

void main() {
  group('GenUiDemoCubit', () {
    late _MockGenUiDemoAgent mockAgent;
    late StreamController<GenUiSurfaceEvent> surfaceEventsController;
    late StreamController<String> errorsController;
    late genui.GenUiManager mockHostHandle;

    GenUiDemoCubit buildCubit() {
      mockAgent = _MockGenUiDemoAgent();
      surfaceEventsController = StreamController<GenUiSurfaceEvent>.broadcast();
      errorsController = StreamController<String>.broadcast();

      when(
        () => mockAgent.surfaceEvents,
      ).thenAnswer((_) => surfaceEventsController.stream);
      when(() => mockAgent.errors).thenAnswer((_) => errorsController.stream);
      when(() => mockAgent.hostHandle).thenReturn(mockHostHandle);
      when(() => mockAgent.initialize()).thenAnswer((_) async {});
      when(() => mockAgent.sendMessage(any())).thenAnswer((_) async {});
      when(() => mockAgent.dispose()).thenAnswer((_) async {});

      final cubit = GenUiDemoCubit(agent: mockAgent);
      addTearDown(() async {
        await surfaceEventsController.close();
        await errorsController.close();
        await cubit.close();
      });
      return cubit;
    }

    setUp(() {
      // Create a mock host handle (GenUiManager)
      // Since it's an abstract interface, we'll use a mock
      mockHostHandle = _MockGenUiManager();
    });

    test('initial state is initial', () {
      final cubit = buildCubit();
      expect(cubit.state, const GenUiDemoState.initial());
    });

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'initialize emits loading then ready state',
      build: buildCubit,
      act: (final cubit) async {
        await cubit.initialize();
      },
      expect: () => [
        const GenUiDemoState.loading(),
        isA<GenUiDemoState>().having(
          (final state) =>
              state.maybeWhen(ready: (_, _, _) => true, orElse: () => false),
          'isReady',
          true,
        ),
      ],
      verify: (final cubit) {
        verify(() => mockAgent.initialize()).called(1);
      },
    );

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'initialize does nothing if already ready',
      build: buildCubit,
      seed: () => GenUiDemoState.ready(
        surfaceIds: const [],
        hostHandle: mockHostHandle,
      ),
      act: (final cubit) async {
        await cubit.initialize();
      },
      expect: () => <GenUiDemoState>[],
      verify: (final cubit) {
        verifyNever(() => mockAgent.initialize());
      },
    );

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'initialize emits error state on failure',
      build: () {
        final agent = _MockGenUiDemoAgent();
        when(
          () => agent.surfaceEvents,
        ).thenAnswer((_) => const Stream<GenUiSurfaceEvent>.empty());
        when(
          () => agent.errors,
        ).thenAnswer((_) => const Stream<String>.empty());
        when(() => agent.hostHandle).thenReturn(mockHostHandle);
        when(
          () => agent.initialize(),
        ).thenThrow(Exception('Initialization failed'));
        when(() => agent.dispose()).thenAnswer((_) async {});

        final cubit = GenUiDemoCubit(agent: agent);
        addTearDown(cubit.close);
        return cubit;
      },
      act: (final cubit) async {
        await cubit.initialize();
      },
      expect: () => [
        const GenUiDemoState.loading(),
        isA<GenUiDemoState>().having(
          (final state) => state.maybeWhen(
            error: (message, _, _) => message.isNotEmpty,
            orElse: () => false,
          ),
          'isError',
          true,
        ),
      ],
    );

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'sendMessage updates isSending flag',
      build: buildCubit,
      seed: () => GenUiDemoState.ready(
        surfaceIds: const [],
        hostHandle: mockHostHandle,
      ),
      act: (final cubit) async {
        await cubit.sendMessage('Hello');
      },
      expect: () => [
        isA<GenUiDemoState>().having(
          (final state) => state.maybeWhen(
            ready: (_, _, isSending) => isSending,
            orElse: () => false,
          ),
          'isSending',
          true,
        ),
        isA<GenUiDemoState>().having(
          (final state) => state.maybeWhen(
            ready: (_, _, isSending) => isSending,
            orElse: () => false,
          ),
          'isSending',
          false,
        ),
      ],
      verify: (final cubit) {
        verify(() => mockAgent.sendMessage('Hello')).called(1);
      },
    );

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'sendMessage does nothing if text is empty',
      build: buildCubit,
      seed: () => GenUiDemoState.ready(
        surfaceIds: const [],
        hostHandle: mockHostHandle,
      ),
      act: (final cubit) async {
        await cubit.sendMessage('   ');
      },
      expect: () => <GenUiDemoState>[],
      verify: (final cubit) {
        verifyNever(() => mockAgent.sendMessage(any()));
      },
    );

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'sendMessage does nothing if not ready or loading',
      build: buildCubit,
      seed: () => const GenUiDemoState.initial(),
      act: (final cubit) async {
        await cubit.sendMessage('Hello');
      },
      expect: () => <GenUiDemoState>[],
      verify: (final cubit) {
        verifyNever(() => mockAgent.sendMessage(any()));
      },
    );

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'sendMessage emits error on failure',
      build: () {
        final agent = _MockGenUiDemoAgent();
        surfaceEventsController =
            StreamController<GenUiSurfaceEvent>.broadcast();
        errorsController = StreamController<String>.broadcast();

        when(
          () => agent.surfaceEvents,
        ).thenAnswer((_) => surfaceEventsController.stream);
        when(() => agent.errors).thenAnswer((_) => errorsController.stream);
        when(() => agent.hostHandle).thenReturn(mockHostHandle);
        when(() => agent.initialize()).thenAnswer((_) async {});
        when(
          () => agent.sendMessage(any()),
        ).thenThrow(Exception('Send failed'));
        when(() => agent.dispose()).thenAnswer((_) async {});

        final cubit = GenUiDemoCubit(agent: agent);
        addTearDown(() async {
          await surfaceEventsController.close();
          await errorsController.close();
          await cubit.close();
        });
        return cubit;
      },
      seed: () => GenUiDemoState.ready(
        surfaceIds: const ['surface1'],
        hostHandle: mockHostHandle,
      ),
      act: (final cubit) async {
        await cubit.sendMessage('Hello');
      },
      expect: () => [
        isA<GenUiDemoState>().having(
          (final state) => state.maybeWhen(
            ready: (_, _, isSending) => isSending,
            orElse: () => false,
          ),
          'isSending',
          true,
        ),
        isA<GenUiDemoState>().having(
          (final state) => state.maybeWhen(
            error: (message, surfaceIds, _) =>
                message.isNotEmpty && surfaceIds.contains('surface1'),
            orElse: () => false,
          ),
          'isError',
          true,
        ),
      ],
    );

    test('surfaceAdded event adds surface to list', () async {
      final cubit = buildCubit();
      await cubit.initialize();

      // Set initial state with one surface after initialization
      cubit.emit(
        GenUiDemoState.ready(
          surfaceIds: const ['surface1'],
          hostHandle: mockHostHandle,
        ),
      );

      // Emit surface added event
      surfaceEventsController.add(
        const GenUiSurfaceEvent.added(surfaceId: 'surface2'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(
        cubit.state.maybeWhen(
          ready: (surfaceIds, _, _) =>
              surfaceIds.contains('surface1') &&
              surfaceIds.contains('surface2'),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('surfaceRemoved event removes surface from list', () async {
      final cubit = buildCubit();
      await cubit.initialize();

      // Set initial state with two surfaces after initialization
      cubit.emit(
        GenUiDemoState.ready(
          surfaceIds: const ['surface1', 'surface2'],
          hostHandle: mockHostHandle,
        ),
      );

      // Emit surface removed event
      surfaceEventsController.add(
        const GenUiSurfaceEvent.removed(surfaceId: 'surface1'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(
        cubit.state.maybeWhen(
          ready: (surfaceIds, _, _) =>
              !surfaceIds.contains('surface1') &&
              surfaceIds.contains('surface2'),
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('error stream updates state to error', () async {
      final cubit = buildCubit();
      await cubit.initialize();

      // Set initial state after initialization
      cubit.emit(
        GenUiDemoState.ready(
          surfaceIds: const ['surface1'],
          hostHandle: mockHostHandle,
        ),
      );

      // Emit error
      errorsController.add('Test error message');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(
        cubit.state.maybeWhen(
          error: (message, surfaceIds, _) =>
              message == 'Test error message' &&
              surfaceIds.contains('surface1'),
          orElse: () => false,
        ),
        isTrue,
      );
    });
  });
}

// Mock for GenUiManager since it's an abstract interface
class _MockGenUiManager extends Mock implements genui.GenUiManager {}
