import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_messaging_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logged-in role switch refreshes the fake API user', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final admin = FakeTherapyAdminRepository(api: api);
    final cubit = OnlineTherapyDemoSessionCubit(
      auth: auth,
      networkModeController: api,
    );
    addTearDown(cubit.close);

    await cubit.login();
    expect(cubit.state.user?.role, TherapyRole.client);

    await cubit.setRole(TherapyRole.admin);

    expect(cubit.state.role, TherapyRole.admin);
    expect(cubit.state.user?.role, TherapyRole.admin);
    expect(api.currentUser?.role, TherapyRole.admin);
    expect(await admin.listPendingTherapists(), isNotEmpty);
  });

  test(
    'messaging refresh clears stale conversation after role switch',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final therapists = FakeTherapistRepository(api: api);
      final appointments = FakeAppointmentRepository(api: api);
      final messaging = FakeTherapyMessagingRepository(api: api);
      final cubit = MessagingCubit(messaging: messaging);
      addTearDown(cubit.close);

      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
      final therapist = (await therapists.listTherapists()).first;
      final slot = (await therapists.listAvailability(
        therapistId: therapist.id,
        date: DateTime.utc(2026, 4, 22),
      )).first;
      await appointments.createAppointment(
        therapistId: slot.therapistId,
        startAt: slot.startAt,
        endAt: slot.endAt,
      );
      await cubit.refresh();
      expect(cubit.state.selectedConversationId, isNotNull);

      await auth.login(email: 'admin@example.com', role: TherapyRole.admin);
      await cubit.refresh();

      expect(cubit.state.selectedConversationId, isNull);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.errorMessage, isNull);
    },
  );

  test(
    'selecting another therapist clears stale availability while loading',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final admin = FakeTherapyAdminRepository(api: api);
      final therapists = FakeTherapistRepository(api: api);
      final appointments = FakeAppointmentRepository(api: api);
      final cubit = ClientBookingCubit(
        therapists: therapists,
        appointments: appointments,
      );
      addTearDown(cubit.close);

      await auth.login(email: 'admin@example.com', role: TherapyRole.admin);
      await admin.approveTherapist(therapistId: 't_2');
      await auth.login(email: 'demo@example.com', role: TherapyRole.client);

      await cubit.loadTherapists();
      expect(cubit.state.therapists, hasLength(2));
      expect(cubit.state.availability, isNotEmpty);

      final nextTherapist = cubit.state.therapists.last.id;
      final load = cubit.selectTherapist(nextTherapist);

      expect(cubit.state.selectedTherapistId, nextTherapist);
      expect(cubit.state.availability, isEmpty);

      await load;
      expect(cubit.state.availability, isNotEmpty);
      expect(
        cubit.state.availability.every((s) => s.therapistId == nextTherapist),
        isTrue,
      );
      expect(cubit.state.isBusy, isFalse);
    },
  );

  test(
    'selecting another conversation clears stale messages while loading',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final therapists = FakeTherapistRepository(api: api);
      final appointments = FakeAppointmentRepository(api: api);
      final messaging = FakeTherapyMessagingRepository(api: api);
      final cubit = MessagingCubit(messaging: messaging);
      addTearDown(cubit.close);

      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
      final therapist = (await therapists.listTherapists()).first;
      final slots = await therapists.listAvailability(
        therapistId: therapist.id,
        date: DateTime.utc(2026, 4, 22),
      );
      for (final slot in slots.take(2)) {
        await appointments.createAppointment(
          therapistId: slot.therapistId,
          startAt: slot.startAt,
          endAt: slot.endAt,
        );
      }

      await cubit.refresh();
      expect(cubit.state.conversations, hasLength(2));
      cubit.setDraft('hello');
      await cubit.send();
      expect(cubit.state.messages, isNotEmpty);

      final nextConversation = cubit.state.conversations.last.id;
      final load = cubit.selectConversation(nextConversation);

      expect(cubit.state.selectedConversationId, nextConversation);
      expect(cubit.state.messages, isEmpty);

      await load;
      expect(cubit.state.selectedConversationId, nextConversation);
      expect(cubit.state.isBusy, isFalse);
    },
  );

  test('stale loadAvailability does not leave isBusy true', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final admin = FakeTherapyAdminRepository(api: api);
    final therapists = _DelayedAvailabilityTherapistRepository(
      FakeTherapistRepository(api: api),
    );
    final appointments = FakeAppointmentRepository(api: api);
    final cubit = ClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
    );
    addTearDown(cubit.close);

    await auth.login(email: 'admin@example.com', role: TherapyRole.admin);
    await admin.approveTherapist(therapistId: 't_2');
    await auth.login(email: 'demo@example.com', role: TherapyRole.client);

    await cubit.loadTherapists();
    final first = cubit.state.therapists.first.id;
    final second = cubit.state.therapists.last.id;

    unawaited(cubit.selectTherapist(first));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await cubit.selectTherapist(second);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.selectedTherapistId, second);
  });

  test('refresh loads availability for selected therapist', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final cubit = ClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
    );
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);

    await cubit.refresh();

    final selected = cubit.state.selectedTherapistId;
    expect(selected, isNotNull);
    expect(cubit.state.availability, isNotEmpty);
    expect(
      cubit.state.availability.every((slot) => slot.therapistId == selected),
      isTrue,
    );
    expect(cubit.state.isBusy, isFalse);
  });

  test(
    'createAppointmentFromSlot reports success when superseded after write',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final therapists = FakeTherapistRepository(api: api);
      final appointments = _GatedAppointmentRepository(
        FakeAppointmentRepository(api: api),
      );
      final cubit = ClientBookingCubit(
        therapists: therapists,
        appointments: appointments,
      );
      addTearDown(cubit.close);

      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
      await cubit.refresh();
      final slot = cubit.state.availability.firstWhere(
        (slot) => slot.status == AvailabilitySlotStatus.available,
      );

      final Future<bool> booking = cubit.createAppointmentFromSlot(slot);
      await cubit.refresh();
      appointments.releaseCreate();
      final booked = await booking;

      expect(booked, isTrue);
      final created = await appointments.listAppointmentsForCurrentRole();
      expect(
        created.any(
          (appointment) =>
              appointment.therapistId == slot.therapistId &&
              appointment.startAt == slot.startAt,
        ),
        isTrue,
      );
    },
  );

  test(
    'createAppointmentFromSlot reports success when superseded during reload',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final therapists = _DelayedAvailabilityTherapistRepository(
        FakeTherapistRepository(api: api),
      );
      final appointments = FakeAppointmentRepository(api: api);
      final cubit = ClientBookingCubit(
        therapists: therapists,
        appointments: appointments,
      );
      addTearDown(cubit.close);

      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
      await cubit.refresh();
      final slot = cubit.state.availability.firstWhere(
        (slot) => slot.status == AvailabilitySlotStatus.available,
      );

      final Future<bool> booking = cubit.createAppointmentFromSlot(slot);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await cubit.refresh();
      final booked = await booking;

      expect(booked, isTrue);
      final created = await appointments.listAppointmentsForCurrentRole();
      expect(
        created.any(
          (appointment) =>
              appointment.therapistId == slot.therapistId &&
              appointment.startAt == slot.startAt,
        ),
        isTrue,
      );
    },
  );

  test('createAppointmentFromSlot refreshes availability state', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final cubit = ClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
    );
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    await cubit.refresh();
    final slot = cubit.state.availability.firstWhere(
      (slot) => slot.status == AvailabilitySlotStatus.available,
    );

    final booked = await cubit.createAppointmentFromSlot(slot);

    expect(booked, isTrue);
    expect(cubit.state.appointments, isNotEmpty);
    final refreshedSlot = cubit.state.availability.firstWhere(
      (candidate) => candidate.id == slot.id,
    );
    expect(refreshedSlot.status, AvailabilitySlotStatus.booked);
    expect(cubit.state.isBusy, isFalse);
  });

  test('cancelAppointment refreshes availability state', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final cubit = ClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
    );
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    await cubit.refresh();
    final slot = cubit.state.availability.firstWhere(
      (slot) => slot.status == AvailabilitySlotStatus.available,
    );
    final appointment = await appointments.createAppointment(
      therapistId: slot.therapistId,
      startAt: slot.startAt,
      endAt: slot.endAt,
    );

    await cubit.cancelAppointment(appointment.id);

    final refreshedSlot = cubit.state.availability.firstWhere(
      (candidate) => candidate.id == slot.id,
    );
    expect(refreshedSlot.status, AvailabilitySlotStatus.available);
    expect(cubit.state.isBusy, isFalse);
  });

  test('stale selectConversation does not leave isBusy true', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final messaging = _DelayedMessagingRepository(
      FakeTherapyMessagingRepository(api: api),
    );
    final cubit = MessagingCubit(messaging: messaging);
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    final therapist = (await therapists.listTherapists()).first;
    final slots = await therapists.listAvailability(
      therapistId: therapist.id,
      date: DateTime.utc(2026, 4, 22),
    );
    for (final slot in slots.take(2)) {
      await appointments.createAppointment(
        therapistId: slot.therapistId,
        startAt: slot.startAt,
        endAt: slot.endAt,
      );
    }

    await cubit.refresh();
    final first = cubit.state.conversations.first.id;
    final second = cubit.state.conversations.last.id;

    unawaited(cubit.selectConversation(first));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await cubit.selectConversation(second);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.selectedConversationId, second);
  });

  test('cancelling an appointment reopens the booked slot', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    final therapist = (await therapists.listTherapists()).first;
    final slot = (await therapists.listAvailability(
      therapistId: therapist.id,
      date: DateTime.utc(2026, 4, 22),
    )).first;

    final appt = await appointments.createAppointment(
      therapistId: slot.therapistId,
      startAt: slot.startAt,
      endAt: slot.endAt,
    );
    await appointments.cancelAppointment(
      appointmentId: appt.id,
      reason: 'test',
    );

    final slots = await therapists.listAvailability(
      therapistId: therapist.id,
      date: DateTime.utc(2026, 4, 22),
    );
    final reopened = slots.firstWhere((s) => s.id == slot.id);
    expect(reopened.status, AvailabilitySlotStatus.available);
  });

  test('cancelAppointment with empty id is a no-op', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final cubit = ClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
    );
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    await cubit.refresh();
    final before = cubit.state;

    await cubit.cancelAppointment('   ');

    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.appointments, before.appointments);
    expect(cubit.state.availability, before.availability);
  });

  test('selectTherapist with empty id clears selection without busy', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final cubit = ClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
    );
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    await cubit.refresh();
    expect(cubit.state.selectedTherapistId, isNotNull);

    await cubit.selectTherapist('');

    expect(cubit.state.selectedTherapistId, isNull);
    expect(cubit.state.availability, isEmpty);
    expect(cubit.state.isBusy, isFalse);
  });

  test(
    'selectTherapist with empty id cancels in-flight availability',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final admin = FakeTherapyAdminRepository(api: api);
      final therapists = _DelayedAvailabilityTherapistRepository(
        FakeTherapistRepository(api: api),
      );
      final appointments = FakeAppointmentRepository(api: api);
      final cubit = ClientBookingCubit(
        therapists: therapists,
        appointments: appointments,
      );
      addTearDown(cubit.close);

      await auth.login(email: 'admin@example.com', role: TherapyRole.admin);
      await admin.approveTherapist(therapistId: 't_2');
      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
      await cubit.refresh();

      final first = cubit.state.therapists.first.id;
      unawaited(cubit.selectTherapist(first));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await cubit.selectTherapist('  ');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(cubit.state.selectedTherapistId, isNull);
      expect(cubit.state.availability, isEmpty);
      expect(cubit.state.isBusy, isFalse);
    },
  );

  test(
    'loadAvailability with empty therapist id skips repository call',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final therapists = _CountingAvailabilityTherapistRepository(
        FakeTherapistRepository(api: api),
      );
      final appointments = FakeAppointmentRepository(api: api);
      final cubit = ClientBookingCubit(
        therapists: therapists,
        appointments: appointments,
      );
      addTearDown(cubit.close);

      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
      await cubit.refresh();
      final availabilityBefore = cubit.state.availability;
      therapists.resetCount();

      await cubit.loadAvailability(therapistId: '  ');

      expect(therapists.listAvailabilityCalls, 0);
      expect(cubit.state.availability, isEmpty);
      expect(cubit.state.isBusy, isFalse);
      expect(availabilityBefore, isNotEmpty);
    },
  );

  test('messaging retry with empty id is a no-op', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final messaging = FakeTherapyMessagingRepository(api: api);
    final cubit = MessagingCubit(messaging: messaging);
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    final therapist = (await therapists.listTherapists()).first;
    final slot = (await therapists.listAvailability(
      therapistId: therapist.id,
      date: DateTime.utc(2026, 4, 22),
    )).first;
    await appointments.createAppointment(
      therapistId: slot.therapistId,
      startAt: slot.startAt,
      endAt: slot.endAt,
    );
    await cubit.refresh();
    final before = cubit.state;

    await cubit.retry('');

    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.messages, before.messages);
  });

  test(
    'selectConversation with empty id clears selection without busy',
    () async {
      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final therapists = FakeTherapistRepository(api: api);
      final appointments = FakeAppointmentRepository(api: api);
      final messaging = FakeTherapyMessagingRepository(api: api);
      final cubit = MessagingCubit(messaging: messaging);
      addTearDown(cubit.close);

      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
      final therapist = (await therapists.listTherapists()).first;
      final slot = (await therapists.listAvailability(
        therapistId: therapist.id,
        date: DateTime.utc(2026, 4, 22),
      )).first;
      await appointments.createAppointment(
        therapistId: slot.therapistId,
        startAt: slot.startAt,
        endAt: slot.endAt,
      );
      await cubit.refresh();
      expect(cubit.state.selectedConversationId, isNotNull);

      await cubit.selectConversation('  ');

      expect(cubit.state.selectedConversationId, isNull);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.isBusy, isFalse);
    },
  );

  test('selectConversation with empty id cancels in-flight messages', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    final messaging = _DelayedMessagingRepository(
      FakeTherapyMessagingRepository(api: api),
    );
    final cubit = MessagingCubit(messaging: messaging);
    addTearDown(cubit.close);

    await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    final therapist = (await therapists.listTherapists()).first;
    final slots = await therapists.listAvailability(
      therapistId: therapist.id,
      date: DateTime.utc(2026, 4, 22),
    );
    for (final slot in slots.take(2)) {
      await appointments.createAppointment(
        therapistId: slot.therapistId,
        startAt: slot.startAt,
        endAt: slot.endAt,
      );
    }
    await cubit.refresh();

    final first = cubit.state.conversations.first.id;
    unawaited(cubit.selectConversation(first));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await cubit.selectConversation('  ');
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(cubit.state.selectedConversationId, isNull);
    expect(cubit.state.messages, isEmpty);
    expect(cubit.state.isBusy, isFalse);
  });
}

class _CountingAvailabilityTherapistRepository implements TherapistRepository {
  _CountingAvailabilityTherapistRepository(this._inner);

  final TherapistRepository _inner;
  int listAvailabilityCalls = 0;

  void resetCount() => listAvailabilityCalls = 0;

  @override
  Future<TherapistProfile> getTherapist({required final String therapistId}) =>
      _inner.getTherapist(therapistId: therapistId);

  @override
  Future<List<AvailabilitySlot>> listAvailability({
    required final String therapistId,
    required final DateTime date,
  }) {
    listAvailabilityCalls++;
    return _inner.listAvailability(therapistId: therapistId, date: date);
  }

  @override
  Future<List<TherapistProfile>> listTherapists({
    final String? query,
    final String? specialty,
    final String? language,
  }) => _inner.listTherapists(
    query: query,
    specialty: specialty,
    language: language,
  );
}

class _DelayedAvailabilityTherapistRepository implements TherapistRepository {
  _DelayedAvailabilityTherapistRepository(this._inner);

  final TherapistRepository _inner;
  static const Duration _delay = Duration(milliseconds: 100);

  @override
  Future<TherapistProfile> getTherapist({required final String therapistId}) =>
      _inner.getTherapist(therapistId: therapistId);

  @override
  Future<List<AvailabilitySlot>> listAvailability({
    required final String therapistId,
    required final DateTime date,
  }) async {
    await Future<void>.delayed(_delay);
    return _inner.listAvailability(therapistId: therapistId, date: date);
  }

  @override
  Future<List<TherapistProfile>> listTherapists({
    final String? query,
    final String? specialty,
    final String? language,
  }) => _inner.listTherapists(
    query: query,
    specialty: specialty,
    language: language,
  );
}

class _GatedAppointmentRepository implements AppointmentRepository {
  _GatedAppointmentRepository(this._inner);

  final AppointmentRepository _inner;
  final Completer<void> _createGate = Completer<void>();

  void releaseCreate() {
    if (!_createGate.isCompleted) {
      _createGate.complete();
    }
  }

  @override
  Future<Appointment> cancelAppointment({
    required final String appointmentId,
    required final String reason,
  }) => _inner.cancelAppointment(appointmentId: appointmentId, reason: reason);

  @override
  Future<Appointment> createAppointment({
    required final String therapistId,
    required final DateTime startAt,
    required final DateTime endAt,
  }) async {
    await _createGate.future;
    return _inner.createAppointment(
      therapistId: therapistId,
      startAt: startAt,
      endAt: endAt,
    );
  }

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() =>
      _inner.listAppointmentsForCurrentRole();
}

class _DelayedMessagingRepository implements TherapyMessagingRepository {
  _DelayedMessagingRepository(this._inner);

  final TherapyMessagingRepository _inner;
  static const Duration _delay = Duration(milliseconds: 100);

  @override
  Future<List<Conversation>> listConversations() => _inner.listConversations();

  @override
  Future<List<Message>> listMessages({
    required final String conversationId,
  }) async {
    await Future<void>.delayed(_delay);
    return _inner.listMessages(conversationId: conversationId);
  }

  @override
  Future<Message> retryMessage({required final String messageId}) =>
      _inner.retryMessage(messageId: messageId);

  @override
  Future<Message> sendMessage({
    required final String conversationId,
    required final String body,
  }) => _inner.sendMessage(conversationId: conversationId, body: body);
}

class _ImmediateTimerService implements TimerService {
  @override
  TimerDisposable periodic(
    final Duration interval,
    final void Function() onTick,
  ) {
    onTick();
    return _NoopTimerDisposable();
  }

  @override
  TimerDisposable runOnce(
    final Duration delay,
    final void Function() onComplete,
  ) {
    onComplete();
    return _NoopTimerDisposable();
  }
}

class _NoopTimerDisposable implements TimerDisposable {
  @override
  void dispose() {}
}
