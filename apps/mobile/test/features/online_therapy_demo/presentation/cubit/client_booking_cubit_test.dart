import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('ClientBookingCubit success paths', () {
    late OnlineTherapyFakeApi api;
    late FakeTherapyAuthRepository auth;
    late FakeTherapyAdminRepository admin;
    late ClientBookingCubit cubit;

    setUp(() {
      api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      auth = FakeTherapyAuthRepository(api: api);
      admin = FakeTherapyAdminRepository(api: api);
      cubit = ClientBookingCubit(
        therapists: FakeTherapistRepository(api: api),
        appointments: FakeAppointmentRepository(api: api),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    Future<void> loginAsClientWithTwoTherapists() async {
      await auth.login(email: 'admin@example.com', role: TherapyRole.admin);
      await admin.approveTherapist(therapistId: 't_2');
      await auth.login(email: 'demo@example.com', role: TherapyRole.client);
    }

    test('loadTherapists populates list and availability', () async {
      await loginAsClientWithTwoTherapists();

      await cubit.loadTherapists();

      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.therapists, hasLength(2));
      expect(cubit.state.availability, isNotEmpty);
    });

    test('createAppointmentFromSlot books selected slot', () async {
      await loginAsClientWithTwoTherapists();
      await cubit.loadTherapists();
      final slot = cubit.state.availability.first;

      final booked = await cubit.createAppointmentFromSlot(slot);

      expect(booked, isTrue);
      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.appointments, isNotEmpty);
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
