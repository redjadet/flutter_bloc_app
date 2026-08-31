import 'package:auth/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
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

class const StaffAppDemoRouteFactory({
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
  ) => AppRouteAuthGate(
    policy: AppRoutePolicies.staffAppDemo,
    getCurrentUser: () => authRepository.currentUser,
    authStateChanges: authRepository.authStateChanges,
    authPath: AppRoutes.authPath,
    child: StaffAppDemoShellPage(child: child)
        .routeScoped(
          create: () => StaffDemoSitesCubit(repository: siteRepository),
          init: (cubit) => cubit.load(),
        )
        .routeScoped(
          create: () => StaffDemoSessionCubit(
            authRepository: authRepository,
            profileRepository: profileRepository,
            pushTokenRepository: pushTokenRepository,
          ),
          init: (cubit) => cubit.hydrate(),
        ),
  );

  ShellRoute createShellRoute() => ShellRoute(
    builder: _buildShell,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.staffAppDemoPath,
        name: AppRoutes.staffAppDemo,
        redirect: (_, _) => AppRoutes.staffAppDemoDashboardPath,
      ),
      RouteScopedPage.route(
        path: AppRoutes.staffAppDemoDashboardPath,
        name: AppRoutes.staffAppDemoDashboard,
        builder: (_, _) => const StaffAppDemoDashboardPage(),
      ),
      RouteScopedPage.routeWithCubit<StaffDemoTimeclockCubit>(
        path: AppRoutes.staffAppDemoTimeclockPath,
        name: AppRoutes.staffAppDemoTimeclock,
        create: (_, _) => StaffDemoTimeclockCubit(
          authRepository: authRepository,
          repository: timeclockRepository,
          localRepository: timeclockLocalStore,
        ),
        init: (cubit) => cubit.load(),
        child: const StaffAppDemoTimeclockPage(),
      ),
      RouteScopedPage.routeWithCubit<StaffDemoMessagesCubit>(
        path: AppRoutes.staffAppDemoMessagesPath,
        name: AppRoutes.staffAppDemoMessages,
        create: (_, _) => StaffDemoMessagesCubit(
          authRepository: authRepository,
          inboxRepository: inboxRepository,
          messagingRepository: messagingRepository,
          profileRepository: profileRepository,
        ),
        init: (cubit) => cubit.initialize(),
        child: const StaffAppDemoMessagesPage(),
      ),
      RouteScopedPage.routeWithCubit<StaffDemoContentCubit>(
        path: AppRoutes.staffAppDemoContentPath,
        name: AppRoutes.staffAppDemoContent,
        create: (_, _) => StaffDemoContentCubit(repository: contentRepository),
        init: (cubit) => cubit.load(),
        child: const StaffAppDemoContentPage(),
      ),
      RouteScopedPage.routeWithCubit<StaffDemoFormsCubit>(
        path: AppRoutes.staffAppDemoFormsPath,
        name: AppRoutes.staffAppDemoForms,
        create: (_, _) => StaffDemoFormsCubit(
          authRepository: authRepository,
          repository: formsRepository,
        ),
        child: const StaffAppDemoFormsPage(),
      ),
      RouteScopedPage.routeWithCubit<StaffDemoProofCubit>(
        path: AppRoutes.staffAppDemoProofPath,
        name: AppRoutes.staffAppDemoProof,
        create: (_, _) => StaffDemoProofCubit(
          authRepository: authRepository,
          repository: eventProofRepository,
          fileStore: proofFileStore,
          photoPicker: photoPicker,
        ),
        child: const StaffAppDemoProofPage(),
      ),
      RouteScopedPage.routeWithCubit<StaffDemoAdminCubit>(
        path: AppRoutes.staffAppDemoAdminPath,
        name: AppRoutes.staffAppDemoAdmin,
        create: (_, _) => StaffDemoAdminCubit(
          timeEntriesRepository: timeEntriesRepository,
        ),
        init: (cubit) => cubit.load(),
        child: const StaffAppDemoAdminPage(),
      ),
    ],
  );
}
