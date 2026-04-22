import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/pages/online_therapy_demo_client_appointments_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('appointments page tolerates list shrinking during rebuild', (
    tester,
  ) async {
    final originalOnError = FlutterError.onError;
    final errors = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      errors.add(details);
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });

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
    final appointment = await appointments.createAppointment(
      therapistId: slot.therapistId,
      startAt: slot.startAt,
      endAt: slot.endAt,
    );

    final sessionCubit = OnlineTherapyDemoSessionCubit(auth: auth, api: api);
    final bookingCubit = _TestClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
    );
    addTearDown(sessionCubit.close);
    addTearDown(bookingCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<OnlineTherapyDemoSessionCubit>.value(
              value: sessionCubit,
            ),
            BlocProvider<ClientBookingCubit>.value(value: bookingCubit),
          ],
          child: const OnlineTherapyDemoClientAppointmentsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    bookingCubit.replaceAppointments(<Appointment>[appointment]);
    await tester.pump();
    expect(find.text('Cancel'), findsOneWidget);

    bookingCubit.replaceAppointments(<Appointment>[]);
    await tester.pumpAndSettle();

    expect(errors.where((details) => details.exception is RangeError), isEmpty);
  });
}

class _TestClientBookingCubit extends ClientBookingCubit {
  _TestClientBookingCubit({
    required super.therapists,
    required super.appointments,
  });

  void replaceAppointments(final List<Appointment> appointments) {
    emit(state.copyWith(appointments: appointments, isBusy: false));
  }
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
