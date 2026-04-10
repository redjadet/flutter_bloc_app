import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_role.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_admin_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_dashboard_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_messages_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
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

class _MockStaffDemoSiteRepository extends Mock
    implements StaffDemoSiteRepository {}

class _MockTimeEntriesRepository extends Mock
    implements FirestoreStaffDemoTimeEntriesRepository {}

class _RefreshingMessagesCubit extends StaffDemoMessagesCubit {
  _RefreshingMessagesCubit({
    required super.authRepository,
    required super.inboxRepository,
    required super.messagingRepository,
  });

  int initializeCount = 0;

  @override
  Future<void> initialize() async {
    initializeCount += 1;
  }
}

class _RefreshingAdminCubit extends StaffDemoAdminCubit {
  _RefreshingAdminCubit({required super.timeEntriesRepository});

  int loadCount = 0;

  @override
  Future<void> load() async {
    loadCount += 1;
  }
}

Widget _wrapWithProviders({
  required final Widget child,
  required final StaffDemoSessionCubit sessionCubit,
  StaffDemoMessagesCubit? messagesCubit,
  StaffDemoSitesCubit? sitesCubit,
}) {
  // Important: provide cubits above `MaterialApp` so dialogs (Navigator overlay)
  // can read them.
  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<StaffDemoSessionCubit>.value(value: sessionCubit),
      if (messagesCubit != null)
        BlocProvider<StaffDemoMessagesCubit>.value(value: messagesCubit),
      if (sitesCubit != null)
        BlocProvider<StaffDemoSitesCubit>.value(value: sitesCubit),
    ],
    child: MaterialApp(home: child),
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

        final sitesRepository = _MockStaffDemoSiteRepository();
        when(
          () => sitesRepository.listSites(),
        ).thenAnswer((_) async => const <StaffDemoSite>[]);
        final sitesCubit = StaffDemoSitesCubit(repository: sitesRepository);
        addTearDown(sitesCubit.close);
        sitesCubit.emit(
          StaffDemoSitesState(
            status: StaffDemoSitesStatus.ready,
            sites: <StaffDemoSite>[
              StaffDemoSite(
                siteId: 's1',
                name: 'Warehouse',
                centerLat: 0.0,
                centerLng: 0.0,
                radiusMeters: 100.0,
              ),
            ],
          ),
        );

        await tester.pumpWidget(
          _wrapWithProviders(
            sessionCubit: sessionCubit,
            messagesCubit: messagesCubit,
            sitesCubit: sitesCubit,
            child: const StaffAppDemoMessagesPage(),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Send shift assignment'));
        await tester.pumpAndSettle();

        expect(find.text('Assign to staff'), findsOneWidget);
        expect(
          find.byKey(const Key('staffDemo.shiftAssignment.recipientUserId')),
          findsNothing,
        );
        expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));

        final Finder staffPicker = find.byWidgetPredicate(
          (widget) =>
              widget is DropdownButtonFormField<String> &&
              widget.decoration.labelText == 'Assign to staff',
        );
        expect(staffPicker, findsOneWidget);

        final FilledButton sendButtonBefore = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Send'),
        );
        expect(sendButtonBefore.onPressed, isNull);

        await tester.tap(staffPicker);
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

    testWidgets('messages page pull to refresh reinitializes the cubit', (
      tester,
    ) async {
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

      final messagesCubit = _RefreshingMessagesCubit(
        authRepository: _MockAuthRepository(),
        inboxRepository: _MockInboxRepository(),
        messagingRepository: _MockMessagingRepository(),
      );
      addTearDown(messagesCubit.close);
      messagesCubit.emit(
        const StaffDemoMessagesState(
          status: StaffDemoMessagesStatus.ready,
          items: <StaffDemoInboxItem>[
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

      expect(messagesCubit.initializeCount, 0);

      await tester.fling(find.byType(ListView), const Offset(0, 320), 1000);
      await tester.pumpAndSettle();

      expect(messagesCubit.initializeCount, 1);
    });

    testWidgets('admin page pull to refresh reloads the entries list', (
      tester,
    ) async {
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
            displayName: 'Manager One',
            email: 'manager@example.com',
            role: StaffDemoRole.manager,
            phoneE164: null,
            isActive: true,
          ),
        ),
      );

      final adminCubit = _RefreshingAdminCubit(
        timeEntriesRepository: _MockTimeEntriesRepository(),
      );
      addTearDown(adminCubit.close);
      adminCubit.emit(
        const StaffDemoAdminState(status: StaffDemoAdminStatus.ready),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<StaffDemoSessionCubit>.value(value: sessionCubit),
            BlocProvider<StaffDemoAdminCubit>.value(value: adminCubit),
          ],
          child: const MaterialApp(home: StaffAppDemoAdminPage()),
        ),
      );
      await tester.pump();

      expect(adminCubit.loadCount, 0);

      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(adminCubit.loadCount, 1);
    });
  });
}
