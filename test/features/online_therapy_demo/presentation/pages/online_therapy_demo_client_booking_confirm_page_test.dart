import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/pages/online_therapy_demo_client_booking_confirm_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('shows error card when booking state has errorMessage', (
    tester,
  ) async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);

    final sessionCubit = OnlineTherapyDemoSessionCubit(
      auth: auth,
      networkModeController: api,
    );
    final slot = _sampleSlot();
    final bookingCubit = _SeededClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
      initial: ClientBookingState(
        isBusy: false,
        therapists: const <TherapistProfile>[],
        availability: const <AvailabilitySlot>[],
        appointments: const <Appointment>[],
        pendingBookingSlot: slot,
        errorMessage: 'boom',
      ),
    );
    addTearDown(sessionCubit.close);
    addTearDown(bookingCubit.close);

    await tester.pumpWidget(
      _wrapPage(sessionCubit: sessionCubit, bookingCubit: bookingCubit),
    );
    await tester.pump();

    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Confirm booking'), findsOneWidget);
  });

  testWidgets('Confirm tap on booking failure shows error and stays on page', (
    tester,
  ) async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = _NoopTherapistRepository();
    final appointments = _ThrowingAppointmentRepository();

    final sessionCubit = OnlineTherapyDemoSessionCubit(
      auth: auth,
      networkModeController: api,
    );
    final bookingCubit = _SeededClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
      initial: ClientBookingState(
        isBusy: false,
        therapists: const <TherapistProfile>[],
        availability: const <AvailabilitySlot>[],
        appointments: const <Appointment>[],
        pendingBookingSlot: _sampleSlot(),
      ),
    );
    addTearDown(sessionCubit.close);
    addTearDown(bookingCubit.close);

    await tester.pumpWidget(
      _wrapPage(sessionCubit: sessionCubit, bookingCubit: bookingCubit),
    );
    await tester.pump();

    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.text('Confirm booking'), findsOneWidget);
    expect(find.text('appointments-marker'), findsNothing);
  });

  testWidgets('Confirm tap on success navigates to appointments', (
    tester,
  ) async {
    final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
    final auth = FakeTherapyAuthRepository(api: api);
    final therapists = FakeTherapistRepository(api: api);
    final appointments = FakeAppointmentRepository(api: api);
    await auth.login(email: 'demo@example.com', role: TherapyRole.client);

    final slot = await _firstAvailableSlot(therapists);
    final sessionCubit = OnlineTherapyDemoSessionCubit(
      auth: auth,
      networkModeController: api,
    );
    final bookingCubit = _SeededClientBookingCubit(
      therapists: therapists,
      appointments: appointments,
      initial: ClientBookingState(
        isBusy: false,
        therapists: const <TherapistProfile>[],
        availability: const <AvailabilitySlot>[],
        appointments: const <Appointment>[],
        pendingBookingSlot: slot,
      ),
    );
    addTearDown(sessionCubit.close);
    addTearDown(bookingCubit.close);

    await tester.pumpWidget(
      _routerApp(sessionCubit: sessionCubit, bookingCubit: bookingCubit),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('appointments-marker'), findsOneWidget);
    expect(find.text('Confirm booking'), findsNothing);
  });
}

Widget _wrapPage({
  required OnlineTherapyDemoSessionCubit sessionCubit,
  required ClientBookingCubit bookingCubit,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<OnlineTherapyDemoSessionCubit>.value(value: sessionCubit),
        BlocProvider<ClientBookingCubit>.value(value: bookingCubit),
      ],
      child: const OnlineTherapyDemoClientBookingConfirmPage(),
    ),
  );
}

Widget _routerApp({
  required OnlineTherapyDemoSessionCubit sessionCubit,
  required ClientBookingCubit bookingCubit,
}) {
  return MaterialApp.router(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: GoRouter(
      initialLocation: AppRoutes.onlineTherapyDemoClientBookingConfirmPath,
      routes: <RouteBase>[
        ShellRoute(
          builder: (final context, final state, final child) =>
              MultiBlocProvider(
                providers: <BlocProvider<dynamic>>[
                  BlocProvider<OnlineTherapyDemoSessionCubit>.value(
                    value: sessionCubit,
                  ),
                  BlocProvider<ClientBookingCubit>.value(value: bookingCubit),
                ],
                child: child,
              ),
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.onlineTherapyDemoClientBookingConfirmPath,
              name: AppRoutes.onlineTherapyDemoClientBookingConfirm,
              builder: (final context, final state) =>
                  const OnlineTherapyDemoClientBookingConfirmPage(),
            ),
            GoRoute(
              path: AppRoutes.onlineTherapyDemoClientAppointmentsPath,
              name: AppRoutes.onlineTherapyDemoClientAppointments,
              builder: (final context, final state) =>
                  const Scaffold(body: Text('appointments-marker')),
            ),
          ],
        ),
      ],
    ),
  );
}

AvailabilitySlot _sampleSlot() => AvailabilitySlot(
  id: 'slot-1',
  therapistId: 'therapist-1',
  startAt: DateTime.utc(2026, 4, 22, 10),
  endAt: DateTime.utc(2026, 4, 22, 11),
  status: AvailabilitySlotStatus.available,
);

Future<AvailabilitySlot> _firstAvailableSlot(
  final TherapistRepository therapists,
) async {
  final list = await therapists.listTherapists();
  final first = list.first;
  final slots = await therapists.listAvailability(
    therapistId: first.id,
    date: DateTime.utc(2026, 4, 22),
  );
  return slots.firstWhere(
    (final slot) => slot.status == AvailabilitySlotStatus.available,
  );
}

class _SeededClientBookingCubit extends ClientBookingCubit {
  _SeededClientBookingCubit({
    required super.therapists,
    required super.appointments,
    required ClientBookingState initial,
  }) {
    emit(initial);
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

class _NoopTherapistRepository implements TherapistRepository {
  @override
  Future<TherapistProfile> getTherapist({required String therapistId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<AvailabilitySlot>> listAvailability({
    required String therapistId,
    required DateTime date,
  }) async => <AvailabilitySlot>[];

  @override
  Future<List<TherapistProfile>> listTherapists({
    String? query,
    String? specialty,
    String? language,
  }) async => <TherapistProfile>[];
}

class _ThrowingAppointmentRepository implements AppointmentRepository {
  @override
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Appointment> createAppointment({
    required String therapistId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    throw StateError('boom');
  }

  @override
  Future<List<Appointment>> listAppointmentsForCurrentRole() async =>
      <Appointment>[];
}
