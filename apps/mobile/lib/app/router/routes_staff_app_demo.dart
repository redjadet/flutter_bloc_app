import 'package:auth/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_event_proof_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_forms_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_inbox_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_messaging_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_file_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_photo_picker.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_site_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entries_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_local_store.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_admin_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_content_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_forms_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_messages_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_proof_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_sites_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_timeclock_cubit.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_admin_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_content_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_dashboard_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_forms_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_messages_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_proof_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_shell_page.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/pages/staff_app_demo_timeclock_page.dart';
import 'package:go_router/go_router.dart';

/// Shell + routes for the staff app demo (auth gate + session cubit).
ShellRoute createStaffAppDemoShellRoute(StaffAppDemoRouteFactory factory) =>
    factory.createShellRoute();

class StaffAppDemoRouteFactory({
  required final AuthRepository authRepository,
  required final StaffDemoProfileRepository profileRepository,
  required final StaffDemoPushTokenRepository pushTokenRepository,
  required final StaffDemoSiteRepository siteRepository,
  required final StaffDemoTimeclockRepository timeclockRepository,
  required final StaffDemoTimeclockLocalStore timeclockLocalStore,
  required final StaffDemoInboxRepository inboxRepository,
  required final StaffDemoMessagingRepository messagingRepository,
  required final StaffDemoContentRepository contentRepository,
  required final StaffDemoFormsRepository formsRepository,
  required final StaffDemoEventProofRepository eventProofRepository,
  required final StaffDemoProofFileStore proofFileStore,
  required final StaffDemoProofPhotoPicker photoPicker,
  required final StaffDemoTimeEntriesRepository timeEntriesRepository,
}) {
  Widget _buildShell(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return AppRouteAuthGate(
      policy: AppRoutePolicies.staffAppDemo,
      getCurrentUser: () => authRepository.currentUser,
      authStateChanges: authRepository.authStateChanges,
      authPath: AppRoutes.authPath,
      child: BlocProviderHelpers.withAsyncInit<StaffDemoSessionCubit>(
        create: () => StaffDemoSessionCubit(
          authRepository: authRepository,
          profileRepository: profileRepository,
          pushTokenRepository: pushTokenRepository,
        ),
        init: (cubit) => cubit.hydrate(),
        child: BlocProviderHelpers.withAsyncInit<StaffDemoSitesCubit>(
          create: () => StaffDemoSitesCubit(repository: siteRepository),
          init: (cubit) => cubit.load(),
          child: StaffAppDemoShellPage(child: child),
        ),
      ),
    );
  }

  ShellRoute createShellRoute() => ShellRoute(
    builder: (context, state, child) => _buildShell(context, state, child),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.staffAppDemoPath,
        name: AppRoutes.staffAppDemo,
        redirect: (context, state) => AppRoutes.staffAppDemoDashboardPath,
      ),
      GoRoute(
        path: AppRoutes.staffAppDemoDashboardPath,
        name: AppRoutes.staffAppDemoDashboard,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: StaffAppDemoDashboardPage()),
      ),
      GoRoute(
        path: AppRoutes.staffAppDemoTimeclockPath,
        name: AppRoutes.staffAppDemoTimeclock,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProviderHelpers.withAsyncInit<StaffDemoTimeclockCubit>(
            create: () => StaffDemoTimeclockCubit(
              authRepository: authRepository,
              repository: timeclockRepository,
              localRepository: timeclockLocalStore,
            ),
            init: (cubit) => cubit.load(),
            child: const StaffAppDemoTimeclockPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffAppDemoMessagesPath,
        name: AppRoutes.staffAppDemoMessages,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProviderHelpers.withAsyncInit<StaffDemoMessagesCubit>(
            create: () => StaffDemoMessagesCubit(
              authRepository: authRepository,
              inboxRepository: inboxRepository,
              messagingRepository: messagingRepository,
              profileRepository: profileRepository,
            ),
            init: (cubit) => cubit.initialize(),
            child: const StaffAppDemoMessagesPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffAppDemoContentPath,
        name: AppRoutes.staffAppDemoContent,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProviderHelpers.withAsyncInit<StaffDemoContentCubit>(
            create: () => StaffDemoContentCubit(repository: contentRepository),
            init: (cubit) => cubit.load(),
            child: const StaffAppDemoContentPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffAppDemoFormsPath,
        name: AppRoutes.staffAppDemoForms,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProviderHelpers.withAsyncInit<StaffDemoFormsCubit>(
            create: () => StaffDemoFormsCubit(
              authRepository: authRepository,
              repository: formsRepository,
            ),
            init: (_) async {},
            child: const StaffAppDemoFormsPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffAppDemoProofPath,
        name: AppRoutes.staffAppDemoProof,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProviderHelpers.withAsyncInit<StaffDemoProofCubit>(
            create: () => StaffDemoProofCubit(
              authRepository: authRepository,
              repository: eventProofRepository,
              fileStore: proofFileStore,
              photoPicker: photoPicker,
            ),
            init: (_) async {},
            child: const StaffAppDemoProofPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffAppDemoAdminPath,
        name: AppRoutes.staffAppDemoAdmin,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProviderHelpers.withAsyncInit<StaffDemoAdminCubit>(
            create: () => StaffDemoAdminCubit(
              timeEntriesRepository: timeEntriesRepository,
            ),
            init: (cubit) => cubit.load(),
            child: const StaffAppDemoAdminPage(),
          ),
        ),
      ),
    ],
  );
}
