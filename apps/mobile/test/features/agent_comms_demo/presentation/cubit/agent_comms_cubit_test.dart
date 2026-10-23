import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/agent_comms_demo.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSession implements AgentEngineSession {
  _FakeSession();

  final StreamController<AgentEngineEvent> _controller =
      StreamController<AgentEngineEvent>.broadcast();
  final StreamController<AgentCommsFailure> _faults =
      StreamController<AgentCommsFailure>.broadcast();
  bool connected = false;
  int streamCalls = 0;

  @override
  Stream<AgentEngineEvent> get events => _controller.stream;

  @override
  Stream<AgentCommsFailure> get faults => _faults.stream;

  @override
  bool get isConnected => connected;

  @override
  String? get launcherDescription => connected ? 'fake:test' : null;

  @override
  Future<void> connect() async {
    connected = true;
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
    await _faults.close();
  }

  @override
  Future<AgentEngineInfo> ping() async {
    if (!connected) {
      throw const AgentCommsNotConnectedFailure();
    }
    return const AgentEngineInfo(
      engine: 'fake-engine',
      version: '9.9.9',
      pid: 4242,
    );
  }

  @override
  Future<int> streamDemo({int count = 3}) async {
    streamCalls++;
    for (var i = 1; i <= count; i++) {
      _controller.add(
        AgentEngineEvent(
          type: 'progress',
          message: 'tick $i',
          index: i,
          total: count,
        ),
      );
    }
    return count;
  }

  void emitFault(AgentCommsFailure failure) {
    _faults.add(failure);
  }
}

void main() {
  group('AgentCommsCubit', () {
    late _FakeSession session;

    setUp(() {
      session = _FakeSession();
    });

    blocTest<AgentCommsCubit, AgentCommsState>(
      'connect then ping records engine info',
      build: () => AgentCommsCubit(session: session),
      act: (cubit) async {
        await cubit.connect();
        await cubit.ping();
      },
      verify: (cubit) {
        expect(cubit.state.status, AgentCommsStatus.connected);
        expect(cubit.state.engineInfo?.engine, 'fake-engine');
        expect(cubit.state.launcherDescription, 'fake:test');
        expect(
          cubit.state.trustedHelperIdentity,
          'trusted-helper-extension-point',
        );
        expect(cubit.state.eventLog.any((e) => e.contains('ping ok')), isTrue);
      },
    );

    blocTest<AgentCommsCubit, AgentCommsState>(
      'streamDemo appends event log lines',
      build: () => AgentCommsCubit(session: session),
      act: (cubit) async {
        await cubit.connect();
        await cubit.streamDemo();
      },
      verify: (cubit) {
        expect(session.streamCalls, 1);
        expect(
          cubit.state.eventLog.any((e) => e.contains('event progress')),
          isTrue,
        );
        expect(
          cubit.state.eventLog.any((e) => e.contains('streamDemo completed')),
          isTrue,
        );
      },
    );

    blocTest<AgentCommsCubit, AgentCommsState>(
      'ping without connect emits failure',
      build: () => AgentCommsCubit(session: session),
      act: (cubit) => cubit.ping(),
      verify: (cubit) {
        expect(cubit.state.status, AgentCommsStatus.failure);
        expect(cubit.state.failure, isA<AgentCommsNotConnectedFailure>());
      },
    );

    test(
      'fault during connect keeps failure (not overwritten to connected)',
      () async {
        final _SlowTrustedHelper helper = _SlowTrustedHelper();
        final AgentCommsCubit cubit = AgentCommsCubit(
          session: session,
          trustedHelper: helper,
        );
        addTearDown(cubit.close);

        final Future<void> connecting = cubit.connect();
        await Future<void>.delayed(Duration.zero);
        session.emitFault(
          const AgentCommsTransportFailure('child exited early'),
        );
        helper.complete();
        await connecting;

        expect(cubit.state.status, AgentCommsStatus.failure);
        expect(cubit.state.failure, isA<AgentCommsTransportFailure>());
      },
    );
  });
}

final class _SlowTrustedHelper implements TrustedNativeHelper {
  final Completer<void> _gate = Completer<void>();

  void complete() {
    if (!_gate.isCompleted) {
      _gate.complete();
    }
  }

  @override
  Future<String> identity() async {
    await _gate.future;
    return 'slow-helper';
  }
}
