import 'dart:async';

import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_call_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleAppointment = Appointment(
    id: 'appt-1',
    therapistId: 'therapist-1',
    clientId: 'client-1',
    startAt: DateTime.utc(2026, 4, 22, 10),
    endAt: DateTime.utc(2026, 4, 22, 11),
    status: AppointmentStatus.confirmed,
    createdAt: DateTime.utc(2026, 4, 20),
  );
  final secondAppointment = Appointment(
    id: 'appt-2',
    therapistId: 'therapist-1',
    clientId: 'client-1',
    startAt: DateTime.utc(2026, 4, 23, 10),
    endAt: DateTime.utc(2026, 4, 23, 11),
    status: AppointmentStatus.confirmed,
    createdAt: DateTime.utc(2026, 4, 21),
  );

  final sampleSession = CallSession(
    id: 'session-1',
    appointmentId: 'appt-1',
    roomId: 'room-1',
    provider: CallProvider.simulated,
    joinStatus: CallJoinStatus.idle,
  );

  final joinedSession = CallSession(
    id: 'session-1',
    appointmentId: 'appt-1',
    roomId: 'room-1',
    provider: CallProvider.simulated,
    joinStatus: CallJoinStatus.connected,
  );

  group('CallCubit', () {
    test('refresh loads appointments and selects first', () async {
      final cubit = CallCubit(
        appointments: _FakeAppointmentRepository(
          listResult: <Appointment>[sampleAppointment],
        ),
        calls: _FakeCallRepository(),
      );
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.appointments, <Appointment>[sampleAppointment]);
      expect(cubit.state.selectedAppointmentId, 'appt-1');
      expect(cubit.state.errorMessage, isNull);
    });

    test(
      'createSession creates call session for selected appointment',
      () async {
        final cubit = CallCubit(
          appointments: _FakeAppointmentRepository(
            listResult: <Appointment>[sampleAppointment],
          ),
          calls: _FakeCallRepository(createResult: sampleSession),
        );
        addTearDown(cubit.close);

        await cubit.refresh();
        await cubit.createSession();

        expect(cubit.state.isBusy, isFalse);
        expect(cubit.state.session, sampleSession);
      },
    );

    test('join requires camera and microphone permissions', () async {
      final cubit = CallCubit(
        appointments: _FakeAppointmentRepository(
          listResult: <Appointment>[sampleAppointment],
        ),
        calls: _FakeCallRepository(),
      );
      addTearDown(cubit.close);

      await cubit.refresh();
      await cubit.createSession();
      await cubit.join();

      expect(
        cubit.state.errorMessage,
        'Permissions required (camera + microphone)',
      );
      expect(cubit.state.session?.joinStatus, CallJoinStatus.idle);
    });

    test('join updates session when permissions granted', () async {
      final cubit = CallCubit(
        appointments: _FakeAppointmentRepository(
          listResult: <Appointment>[sampleAppointment],
        ),
        calls: _FakeCallRepository(
          createResult: sampleSession,
          joinResult: joinedSession,
        ),
      );
      addTearDown(cubit.close);

      await cubit.refresh();
      cubit.toggleCameraPermission(granted: true);
      cubit.toggleMicrophonePermission(granted: true);
      await cubit.createSession();
      await cubit.join();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.session, joinedSession);
    });

    test('refresh surfaces repository failure', () async {
      final cubit = CallCubit(
        appointments: _ThrowingAppointmentRepository(),
        calls: _FakeCallRepository(),
      );
      addTearDown(cubit.close);

      await cubit.refresh();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('stale refresh does not overwrite newer appointments', () async {
      final delayedRepo = _DelayedAppointmentRepository(
        first: <Appointment>[sampleAppointment],
        second: <Appointment>[secondAppointment],
      );
      final cubit = CallCubit(
        appointments: delayedRepo,
        calls: _FakeCallRepository(),
      );
      addTearDown(cubit.close);

      unawaited(cubit.refresh());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await cubit.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.selectedAppointmentId, 'appt-2');
      expect(cubit.state.appointments.length, 1);
      expect(cubit.state.appointments.single.id, 'appt-2');
    });

    test('stale createSession does not overwrite appointment change', () async {
      final calls = _DelayedCallRepository();
      final cubit = CallCubit(
        appointments: _FakeAppointmentRepository(
          listResult: <Appointment>[sampleAppointment, secondAppointment],
        ),
        calls: calls,
      );
      addTearDown(cubit.close);

      await cubit.refresh();
      expect(cubit.state.selectedAppointmentId, 'appt-1');

      final Future<void> createFuture = cubit.createSession();
      await Future<void>.delayed(Duration.zero);
      cubit.selectAppointment('appt-2');
      calls.completeCreate(sampleSession);
      await createFuture;

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.selectedAppointmentId, 'appt-2');
      expect(cubit.state.session, isNull);
    });

    test('stale join does not overwrite appointment change', () async {
      final calls = _DelayedCallRepository(createResult: sampleSession);
      final cubit = CallCubit(
        appointments: _FakeAppointmentRepository(
          listResult: <Appointment>[sampleAppointment, secondAppointment],
        ),
        calls: calls,
      );
      addTearDown(cubit.close);

      await cubit.refresh();
      await cubit.createSession();
      cubit.toggleCameraPermission(granted: true);
      cubit.toggleMicrophonePermission(granted: true);

      final Future<void> joinFuture = cubit.join();
      await Future<void>.delayed(Duration.zero);
      cubit.selectAppointment('appt-2');
      calls.completeJoin(joinedSession);
      await joinFuture;

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.selectedAppointmentId, 'appt-2');
      expect(cubit.state.session, isNull);
    });
  });
}

class _FakeAppointmentRepository implements AppointmentRepository {
  _FakeAppointmentRepository({required this.listResult});

  final List<Appointment> listResult;

  @override
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() async =>
      listResult;
}

class _DelayedAppointmentRepository implements AppointmentRepository {
  _DelayedAppointmentRepository({required this.first, required this.second});

  final List<Appointment> first;
  final List<Appointment> second;
  int _callCount = 0;

  @override
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() async {
    _callCount++;
    if (_callCount == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return first;
    }
    return second;
  }
}

class _ThrowingAppointmentRepository implements AppointmentRepository {
  @override
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) => throw UnimplementedError();

  @override
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  }) => throw UnimplementedError();

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() {
    throw StateError('list failed');
  }
}

class _FakeCallRepository implements TherapyCallRepository {
  _FakeCallRepository({this.createResult, this.joinResult});

  final CallSession? createResult;
  final CallSession? joinResult;

  @override
  Future<CallSession> createSession({required String appointmentId}) async {
    return createResult ??
        CallSession(
          id: 'generated',
          appointmentId: appointmentId,
          roomId: 'room',
          provider: CallProvider.simulated,
          joinStatus: CallJoinStatus.idle,
        );
  }

  @override
  Future<CallSession> join({required String callSessionId}) async {
    return joinResult ??
        CallSession(
          id: callSessionId,
          appointmentId: 'appt',
          roomId: 'room',
          provider: CallProvider.simulated,
          joinStatus: CallJoinStatus.connected,
        );
  }
}

class _DelayedCallRepository implements TherapyCallRepository {
  _DelayedCallRepository({this.createResult});

  final CallSession? createResult;
  Completer<CallSession>? _createCompleter;
  Completer<CallSession>? _joinCompleter;

  void completeCreate(final CallSession session) {
    _createCompleter?.complete(session);
  }

  void completeJoin(final CallSession session) {
    _joinCompleter?.complete(session);
  }

  @override
  Future<CallSession> createSession({required String appointmentId}) {
    if (createResult case final session?) {
      return Future<CallSession>.value(session);
    }
    _createCompleter = Completer<CallSession>();
    return _createCompleter!.future;
  }

  @override
  Future<CallSession> join({required String callSessionId}) {
    _joinCompleter = Completer<CallSession>();
    return _joinCompleter!.future;
  }
}
