import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessagingCubit success paths', () {
    late OnlineTherapyFakeApi api;
    late FakeTherapyAuthRepository auth;
    late FakeTherapistRepository therapists;
    late FakeAppointmentRepository appointments;
    late MessagingCubit cubit;

    setUp(() {
      api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      auth = FakeTherapyAuthRepository(api: api);
      therapists = FakeTherapistRepository(api: api);
      appointments = FakeAppointmentRepository(api: api);
      cubit = MessagingCubit(
        messaging: FakeTherapyMessagingRepository(api: api),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    Future<void> seedClientConversation() async {
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
    }

    test('refresh loads conversations after booking', () async {
      await seedClientConversation();

      await cubit.refresh();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.conversations, isNotEmpty);
      expect(cubit.state.selectedConversationId, isNotNull);
      expect(cubit.state.messages, isEmpty);
    });

    test('send appends message and clears draft', () async {
      await seedClientConversation();
      await cubit.refresh();
      final beforeCount = cubit.state.messages.length;

      cubit.setDraft('hello from client');
      await cubit.send();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.draft, isEmpty);
      expect(cubit.state.messages.length, greaterThan(beforeCount));
      expect(cubit.state.messages.last.body, 'hello from client');
    });
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
