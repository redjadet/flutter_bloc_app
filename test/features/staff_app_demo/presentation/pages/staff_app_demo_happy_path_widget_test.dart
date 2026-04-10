import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_dashboard_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_messages_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStaffDemoProfileRepository extends Mock
    implements StaffDemoProfileRepository {}

class _MockStaffDemoPushTokenRepository extends Mock
    implements StaffDemoPushTokenRepository {}

class _MockInboxRepository extends Mock
    implements FirestoreStaffDemoInboxRepository {}

class _MockMessagingRepository extends Mock
    implements FirestoreStaffDemoMessagingRepository {}

Widget _wrapWithProviders({
  required final Widget child,
  required final StaffDemoSessionCubit sessionCubit,
  StaffDemoMessagesCubit? messagesCubit,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<StaffDemoSessionCubit>.value(value: sessionCubit),
        if (messagesCubit != null)
          BlocProvider<StaffDemoMessagesCubit>.value(value: messagesCubit),
      ],
      child: child,
    ),
  );
}

void main() {
  group('Staff app demo happy path widgets', () {
    testWidgets(
      'messages compose dialog shows staff dropdown and disables send until selection',
      (tester) async {
        final profileRepository = _MockStaffDemoProfileRepository();
        when(
          () => profileRepository.loadProfile(userId: any(named: 'userId')),
        ).thenAnswer((_) async => null);
        when(() => profileRepository.listAssignableStaff()).thenAnswer(
          (_) async => const <StaffDemoProfile>[
            StaffDemoProfile(
              userId: 'e1',
              displayName: 'Employee One',
              email: 'employee1@example.com',
              role: StaffDemoRole.employee,
              phoneE164: null,
              isActive: true,
            ),
          ],
        );

        getIt.registerSingleton<StaffDemoProfileRepository>(profileRepository);
        addTearDown(() async {
          await getIt.reset();
        });

        final sessionCubit = StaffDemoSessionCubit(
          authRepository: _MockAuthRepository(),
          profileRepository: profileRepository,
          pushTokenRepository: _MockStaffDemoPushTokenRepository(),
        );
        addTearDown(sessionCubit.close);
        sessionCubit.emit(
          StaffDemoSessionState(
            status: StaffDemoSessionStatus.ready,
            profile: StaffDemoProfile(
              userId: 'm1',
              displayName: 'Manager One',
              email: 'manager@example.com',
              role: StaffDemoRole.manager,
              phoneE164: null,
              isActive: true,
            ),
          ),
        );

        final messagesCubit = StaffDemoMessagesCubit(
          authRepository: _MockAuthRepository(),
          inboxRepository: _MockInboxRepository(),
          messagingRepository: _MockMessagingRepository(),
        );
        addTearDown(messagesCubit.close);
        messagesCubit.emit(
          const StaffDemoMessagesState(status: StaffDemoMessagesStatus.ready),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            sessionCubit: sessionCubit,
            messagesCubit: messagesCubit,
            child: const StaffAppDemoMessagesPage(),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Send shift assignment'));
        await tester.pumpAndSettle();

        expect(find.text('Assign to staff'), findsOneWidget);
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

        final FilledButton sendButtonBefore = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Send'),
        );
        expect(sendButtonBefore.onPressed, isNull);

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Employee One').last);
        await tester.pumpAndSettle();

        final FilledButton sendButtonAfter = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Send'),
        );
        expect(sendButtonAfter.onPressed, isNotNull);
      },
    );

    testWidgets('dashboard renders when session is ready', (tester) async {
      final sessionCubit = StaffDemoSessionCubit(
        authRepository: _MockAuthRepository(),
        profileRepository: _MockStaffDemoProfileRepository(),
        pushTokenRepository: _MockStaffDemoPushTokenRepository(),
      );
      addTearDown(sessionCubit.close);

      sessionCubit.emit(
        StaffDemoSessionState(
          status: StaffDemoSessionStatus.ready,
          profile: StaffDemoProfile(
            userId: 'u1',
            displayName: 'Employee One',
            email: 'employee@example.com',
            role: StaffDemoRole.employee,
            phoneE164: null,
            isActive: true,
          ),
        ),
      );

      await tester.pumpWidget(
        _wrapWithProviders(
          sessionCubit: sessionCubit,
          child: const StaffAppDemoDashboardPage(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Hello, Employee One'), findsOneWidget);
      expect(
        find.textContaining('Accounting flow starts with Timeclock'),
        findsOneWidget,
      );
    });

    testWidgets(
      'dashboard shows missing profile error when profile is absent',
      (tester) async {
        final sessionCubit = StaffDemoSessionCubit(
          authRepository: _MockAuthRepository(),
          profileRepository: _MockStaffDemoProfileRepository(),
          pushTokenRepository: _MockStaffDemoPushTokenRepository(),
        );
        addTearDown(sessionCubit.close);

        sessionCubit.emit(
          const StaffDemoSessionState(
            status: StaffDemoSessionStatus.missingProfile,
          ),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            sessionCubit: sessionCubit,
            child: const StaffAppDemoDashboardPage(),
          ),
        );
        await tester.pump();

        expect(
          find.textContaining('No staff demo profile found for this user.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Seed staffDemoProfiles/{uid} in Firestore.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'dashboard shows inactive profile error when profile is inactive',
      (tester) async {
        final sessionCubit = StaffDemoSessionCubit(
          authRepository: _MockAuthRepository(),
          profileRepository: _MockStaffDemoProfileRepository(),
          pushTokenRepository: _MockStaffDemoPushTokenRepository(),
        );
        addTearDown(sessionCubit.close);

        sessionCubit.emit(
          const StaffDemoSessionState(
            status: StaffDemoSessionStatus.inactive,
            profile: StaffDemoProfile(
              userId: 'u1',
              displayName: 'Employee One',
              email: 'employee@example.com',
              role: StaffDemoRole.employee,
              phoneE164: null,
              isActive: false,
            ),
          ),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            sessionCubit: sessionCubit,
            child: const StaffAppDemoDashboardPage(),
          ),
        );
        await tester.pump();

        expect(
          find.text('This staff demo profile is inactive.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('messages page confirm button calls cubit -> repository', (
      tester,
    ) async {
      final authRepository = _MockAuthRepository();
      final inboxRepository = _MockInboxRepository();
      final messagingRepository = _MockMessagingRepository();

      when(
        () => messagingRepository.confirmShiftAssignment(
          messageId: any(named: 'messageId'),
          shiftId: any(named: 'shiftId'),
        ),
      ).thenAnswer((_) async {});

      final sessionCubit = StaffDemoSessionCubit(
        authRepository: authRepository,
        profileRepository: _MockStaffDemoProfileRepository(),
        pushTokenRepository: _MockStaffDemoPushTokenRepository(),
      );
      addTearDown(sessionCubit.close);
      sessionCubit.emit(
        StaffDemoSessionState(
          status: StaffDemoSessionStatus.ready,
          profile: StaffDemoProfile(
            userId: 'u1',
            displayName: 'Employee One',
            email: 'employee@example.com',
            role: StaffDemoRole.employee,
            phoneE164: null,
            isActive: true,
          ),
        ),
      );

      final messagesCubit = StaffDemoMessagesCubit(
        authRepository: authRepository,
        inboxRepository: inboxRepository,
        messagingRepository: messagingRepository,
      );
      addTearDown(messagesCubit.close);
      messagesCubit.emit(
        StaffDemoMessagesState(
          status: StaffDemoMessagesStatus.ready,
          items: const <StaffDemoInboxItem>[
            StaffDemoInboxItem(
              messageId: 'm1',
              body: 'Your shift starts at 10:00.',
              type: 'shift_assignment',
              shiftId: 's1',
              confirmedAtMs: null,
              shiftStatus: 'assigned',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _wrapWithProviders(
          sessionCubit: sessionCubit,
          messagesCubit: messagesCubit,
          child: const StaffAppDemoMessagesPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      verify(
        () => messagingRepository.confirmShiftAssignment(
          messageId: 'm1',
          shiftId: 's1',
        ),
      ).called(1);
    });
  });
}
