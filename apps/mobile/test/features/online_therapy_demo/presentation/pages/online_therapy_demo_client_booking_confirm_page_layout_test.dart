import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/pages/online_therapy_demo_client_booking_confirm_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/responsive_action_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

import '../../../../helpers/layout_overflow_expectations.dart';

void main() {
  testWidgets(
    'booking confirm ResponsiveDualCtaRow stacks without overflow at 320dp',
    (tester) async {
      final capture = startLayoutOverflowCapture();
      addTearDown(capture.dispose);

      final previousPhysicalSize = tester.view.physicalSize;
      final previousDevicePixelRatio = tester.view.devicePixelRatio;
      addTearDown(() {
        tester.view.physicalSize = previousPhysicalSize;
        tester.view.devicePixelRatio = previousDevicePixelRatio;
      });
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;

      final api = OnlineTherapyFakeApi(timerService: _ImmediateTimerService());
      final auth = FakeTherapyAuthRepository(api: api);
      final therapists = FakeTherapistRepository(api: api);
      final appointments = FakeAppointmentRepository(api: api);

      final sessionCubit = OnlineTherapyDemoSessionCubit(
        auth: auth,
        networkModeController: api,
      );
      final slot = AvailabilitySlot(
        id: 'slot-1',
        therapistId: 'therapist-1',
        startAt: DateTime.utc(2026, 4, 22, 10),
        endAt: DateTime.utc(2026, 4, 22, 11),
        status: AvailabilitySlotStatus.available,
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
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<OnlineTherapyDemoSessionCubit>.value(
                value: sessionCubit,
              ),
              BlocProvider<ClientBookingCubit>.value(value: bookingCubit),
            ],
            child: const OnlineTherapyDemoClientBookingConfirmPage(),
          ),
        ),
      );
      await tester.pump();

      final Finder dualCta = find.byType(ResponsiveDualCtaRow);
      expect(dualCta, findsOneWidget);
      expect(
        find.descendant(of: dualCta, matching: find.byType(Column)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dualCta, matching: find.byType(Row)),
        findsNothing,
      );

      expectNoRenderOverflows(capture.errors);
    },
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
