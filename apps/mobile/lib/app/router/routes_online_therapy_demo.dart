import 'package:auth/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
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

RouteBase createOnlineTherapyDemoRoute(OnlineTherapyDemoRouteFactory factory) =>
    factory.createRoute();

class const OnlineTherapyDemoRouteFactory({
  required final AuthRepository appAuthRepository,
  required final TherapyAuthRepository therapyAuthRepository,
  required final OnlineTherapyFakeApi networkModeController,
  required final TherapistRepository therapists,
  required final AppointmentRepository appointments,
  required final TherapyAdminRepository admin,
  required final AuditRepository audit,
  required final TherapyMessagingRepository messaging,
  required final TherapyCallRepository calls,
}) {
  OnlineTherapyDemoDependencies get _deps => OnlineTherapyDemoDependencies(
    auth: therapyAuthRepository,
    networkModeController: networkModeController,
    therapists: therapists,
    appointments: appointments,
    admin: admin,
    audit: audit,
    messaging: messaging,
    calls: calls,
  );

  Widget _buildProtectedAdmin({
    required AppRoutePolicy policy,
    required Widget child,
  }) {
    return AppRouteAuthGate(
      policy: policy,
      getCurrentUser: () => appAuthRepository.currentUser,
      authStateChanges: appAuthRepository.authStateChanges,
      authPath: AppRoutes.authPath,
      child: child,
    );
  }

  RouteBase createRoute() => ShellRoute(
    builder: (context, state, child) => OnlineTherapyDemoScope(
      deps: _deps,
      child: child,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.onlineTherapyDemoPath,
        name: AppRoutes.onlineTherapyDemo,
        builder: (context, state) => const OnlineTherapyDemoLandingPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoControlsPath,
        name: AppRoutes.onlineTherapyDemoControls,
        builder: (context, state) => const OnlineTherapyDemoControlsPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoClientPath,
        name: AppRoutes.onlineTherapyDemoClient,
        builder: (context, state) => const OnlineTherapyDemoClientHubPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoClientTherapistsPath,
        name: AppRoutes.onlineTherapyDemoClientTherapists,
        builder: (context, state) =>
            const OnlineTherapyDemoClientTherapistsPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoClientTherapistDetailPath,
        name: AppRoutes.onlineTherapyDemoClientTherapistDetail,
        builder: (context, state) {
          final therapistId = state.pathParameters['therapistId'] ?? '';
          return OnlineTherapyDemoClientTherapistDetailPage(
            therapistId: therapistId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoClientBookingConfirmPath,
        name: AppRoutes.onlineTherapyDemoClientBookingConfirm,
        builder: (context, state) =>
            const OnlineTherapyDemoClientBookingConfirmPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoClientAppointmentsPath,
        name: AppRoutes.onlineTherapyDemoClientAppointments,
        builder: (context, state) =>
            const OnlineTherapyDemoClientAppointmentsPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoClientMessagingPath,
        name: AppRoutes.onlineTherapyDemoClientMessaging,
        builder: (context, state) => const OnlineTherapyDemoMessagingPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoClientCallPath,
        name: AppRoutes.onlineTherapyDemoClientCall,
        builder: (context, state) => const OnlineTherapyDemoCallPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoTherapistPath,
        name: AppRoutes.onlineTherapyDemoTherapist,
        builder: (context, state) => const OnlineTherapyDemoTherapistHubPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoTherapistAppointmentsPath,
        name: AppRoutes.onlineTherapyDemoTherapistAppointments,
        builder: (context, state) =>
            const OnlineTherapyDemoTherapistAppointmentsPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoTherapistMessagingPath,
        name: AppRoutes.onlineTherapyDemoTherapistMessaging,
        builder: (context, state) => const OnlineTherapyDemoMessagingPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoTherapistCallPath,
        name: AppRoutes.onlineTherapyDemoTherapistCall,
        builder: (context, state) => const OnlineTherapyDemoCallPage(),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoAdminPath,
        name: AppRoutes.onlineTherapyDemoAdmin,
        builder: (context, state) => _buildProtectedAdmin(
          policy: AppRoutePolicies.onlineTherapyDemoAdmin,
          child: const OnlineTherapyDemoAdminHubPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoAdminVerificationPath,
        name: AppRoutes.onlineTherapyDemoAdminVerification,
        builder: (context, state) => _buildProtectedAdmin(
          policy: AppRoutePolicies.onlineTherapyDemoAdminVerification,
          child: const OnlineTherapyDemoAdminVerificationPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onlineTherapyDemoAdminAuditPath,
        name: AppRoutes.onlineTherapyDemoAdminAudit,
        builder: (context, state) => _buildProtectedAdmin(
          policy: AppRoutePolicies.onlineTherapyDemoAdminAudit,
          child: const OnlineTherapyDemoAdminAuditPage(),
        ),
      ),
    ],
  );
}

// eof
// end
//
