import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/audit_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_admin_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_auth_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_call_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/therapy_messaging_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/online_therapy_demo.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/online_therapy_demo_dependencies.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/online_therapy_demo_scope.dart';
import 'package:go_router/go_router.dart';

OnlineTherapyDemoDependencies _onlineTherapyDemoDependencies() =>
    OnlineTherapyDemoDependencies(
      auth: getIt<TherapyAuthRepository>(),
      networkModeController: getIt<OnlineTherapyFakeApi>(),
      therapists: getIt<TherapistRepository>(),
      appointments: getIt<AppointmentRepository>(),
      admin: getIt<TherapyAdminRepository>(),
      audit: getIt<AuditRepository>(),
      messaging: getIt<TherapyMessagingRepository>(),
      calls: getIt<TherapyCallRepository>(),
    );

RouteBase createOnlineTherapyDemoRoute() => ShellRoute(
  builder: (context, state, child) => OnlineTherapyDemoScope(
    deps: _onlineTherapyDemoDependencies(),
    child: child,
  ),
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onlineTherapyDemoPath,
      name: AppRoutes.onlineTherapyDemo,
      builder: (final context, final state) =>
          const OnlineTherapyDemoLandingPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoControlsPath,
      name: AppRoutes.onlineTherapyDemoControls,
      builder: (final context, final state) =>
          const OnlineTherapyDemoControlsPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoClientPath,
      name: AppRoutes.onlineTherapyDemoClient,
      builder: (final context, final state) =>
          const OnlineTherapyDemoClientHubPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoClientTherapistsPath,
      name: AppRoutes.onlineTherapyDemoClientTherapists,
      builder: (final context, final state) =>
          const OnlineTherapyDemoClientTherapistsPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoClientTherapistDetailPath,
      name: AppRoutes.onlineTherapyDemoClientTherapistDetail,
      builder: (final context, final state) {
        final therapistId = state.pathParameters['therapistId'] ?? '';
        return OnlineTherapyDemoClientTherapistDetailPage(
          therapistId: therapistId,
        );
      },
    ),
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
          const OnlineTherapyDemoClientAppointmentsPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoClientMessagingPath,
      name: AppRoutes.onlineTherapyDemoClientMessaging,
      builder: (final context, final state) =>
          const OnlineTherapyDemoMessagingPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoClientCallPath,
      name: AppRoutes.onlineTherapyDemoClientCall,
      builder: (final context, final state) =>
          const OnlineTherapyDemoCallPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoTherapistPath,
      name: AppRoutes.onlineTherapyDemoTherapist,
      builder: (final context, final state) =>
          const OnlineTherapyDemoTherapistHubPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoTherapistAppointmentsPath,
      name: AppRoutes.onlineTherapyDemoTherapistAppointments,
      builder: (final context, final state) =>
          const OnlineTherapyDemoTherapistAppointmentsPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoTherapistMessagingPath,
      name: AppRoutes.onlineTherapyDemoTherapistMessaging,
      builder: (final context, final state) =>
          const OnlineTherapyDemoMessagingPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoTherapistCallPath,
      name: AppRoutes.onlineTherapyDemoTherapistCall,
      builder: (final context, final state) =>
          const OnlineTherapyDemoCallPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoAdminPath,
      name: AppRoutes.onlineTherapyDemoAdmin,
      builder: (final context, final state) => AppRouteAuthGate(
        policy: AppRoutePolicies.onlineTherapyDemoAdmin,
        getCurrentUser: () => getIt<AuthRepository>().currentUser,
        authStateChanges: getIt<AuthRepository>().authStateChanges,
        authPath: AppRoutes.authPath,
        child: const OnlineTherapyDemoAdminHubPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoAdminVerificationPath,
      name: AppRoutes.onlineTherapyDemoAdminVerification,
      builder: (final context, final state) => AppRouteAuthGate(
        policy: AppRoutePolicies.onlineTherapyDemoAdminVerification,
        getCurrentUser: () => getIt<AuthRepository>().currentUser,
        authStateChanges: getIt<AuthRepository>().authStateChanges,
        authPath: AppRoutes.authPath,
        child: const OnlineTherapyDemoAdminVerificationPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoAdminAuditPath,
      name: AppRoutes.onlineTherapyDemoAdminAudit,
      builder: (final context, final state) => AppRouteAuthGate(
        policy: AppRoutePolicies.onlineTherapyDemoAdminAudit,
        getCurrentUser: () => getIt<AuthRepository>().currentUser,
        authStateChanges: getIt<AuthRepository>().authStateChanges,
        authPath: AppRoutes.authPath,
        child: const OnlineTherapyDemoAdminAuditPage(),
      ),
    ),
  ],
);

// eof
// end
//
