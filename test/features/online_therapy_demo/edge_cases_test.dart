import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logged-in role switch refreshes the fake API user', () async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final admin = FakeTherapyAdminRepository(api: api);
    final cubit = OnlineTherapyDemoSessionCubit(auth: auth, api: api);
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
    },
  );

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
