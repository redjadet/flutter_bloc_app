import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/firestore_staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_timeclock_local_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/admin/staff_demo_admin_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/content/staff_demo_content_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_admin_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_content_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_dashboard_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_forms_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_messages_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_proof_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_shell_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_timeclock_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/proof/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/sites/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/timeclock/staff_demo_timeclock_cubit.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:go_router/go_router.dart';

/// Shell + routes for the staff app demo (auth gate + session cubit).
ShellRoute createStaffAppDemoShellRoute() => ShellRoute(
  builder: (context, state, child) {
    final AuthRepository auth = getIt<AuthRepository>();
    return AppRouteAuthGate(
      policy: AppRoutePolicies.staffAppDemo,
      getCurrentUser: () => auth.currentUser,
      authStateChanges: auth.authStateChanges,
      authPath: AppRoutes.authPath,
      child: BlocProviderHelpers.withAsyncInit<StaffDemoSessionCubit>(
        create: () => StaffDemoSessionCubit(
          authRepository: auth,
          profileRepository: getIt(),
          pushTokenRepository: getIt(),
        ),
        init: (cubit) => cubit.hydrate(),
        child: BlocProviderHelpers.withAsyncInit<StaffDemoSitesCubit>(
          create: () =>
              StaffDemoSitesCubit(repository: getIt<StaffDemoSiteRepository>()),
          init: (cubit) => cubit.load(),
          child: StaffAppDemoShellPage(child: child),
        ),
      ),
    );
  },
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.staffAppDemoPath,
      name: AppRoutes.staffAppDemo,
      redirect: (context, state) => AppRoutes.staffAppDemoDashboardPath,
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoDashboardPath,
      name: AppRoutes.staffAppDemoDashboard,
      builder: (context, state) => const StaffAppDemoDashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoTimeclockPath,
      name: AppRoutes.staffAppDemoTimeclock,
      builder: (context, state) =>
          BlocProviderHelpers.withAsyncInit<StaffDemoTimeclockCubit>(
            create: () => StaffDemoTimeclockCubit(
              authRepository: getIt<AuthRepository>(),
              repository: getIt<StaffDemoTimeclockRepository>(),
              localRepository: getIt<StaffDemoTimeclockLocalRepository>(),
            ),
            init: (cubit) => cubit.load(),
            child: const StaffAppDemoTimeclockPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoMessagesPath,
      name: AppRoutes.staffAppDemoMessages,
      builder: (context, state) =>
          BlocProviderHelpers.withAsyncInit<StaffDemoMessagesCubit>(
            create: () => StaffDemoMessagesCubit(
              authRepository: getIt<AuthRepository>(),
              inboxRepository: getIt<FirestoreStaffDemoInboxRepository>(),
              messagingRepository:
                  getIt<FirestoreStaffDemoMessagingRepository>(),
            ),
            init: (cubit) => cubit.initialize(),
            child: const StaffAppDemoMessagesPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoContentPath,
      name: AppRoutes.staffAppDemoContent,
      builder: (context, state) =>
          BlocProviderHelpers.withAsyncInit<StaffDemoContentCubit>(
            create: () => StaffDemoContentCubit(repository: getIt()),
            init: (cubit) => cubit.load(),
            child: const StaffAppDemoContentPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoFormsPath,
      name: AppRoutes.staffAppDemoForms,
      builder: (context, state) =>
          BlocProviderHelpers.withAsyncInit<StaffDemoFormsCubit>(
            create: () => StaffDemoFormsCubit(
              authRepository: getIt<AuthRepository>(),
              repository: getIt(),
            ),
            init: (_) async {},
            child: const StaffAppDemoFormsPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoProofPath,
      name: AppRoutes.staffAppDemoProof,
      builder: (context, state) =>
          BlocProviderHelpers.withAsyncInit<StaffDemoProofCubit>(
            create: () => StaffDemoProofCubit(
              authRepository: getIt<AuthRepository>(),
              repository: getIt(),
              fileStore: getIt(),
            ),
            init: (_) async {},
            child: const StaffAppDemoProofPage(),
          ),
    ),
    GoRoute(
      path: AppRoutes.staffAppDemoAdminPath,
      name: AppRoutes.staffAppDemoAdmin,
      builder: (context, state) =>
          BlocProviderHelpers.withAsyncInit<StaffDemoAdminCubit>(
            create: () => StaffDemoAdminCubit(
              timeEntriesRepository:
                  getIt<FirestoreStaffDemoTimeEntriesRepository>(),
            ),
            init: (cubit) => cubit.load(),
            child: const StaffAppDemoAdminPage(),
          ),
    ),
  ],
);
