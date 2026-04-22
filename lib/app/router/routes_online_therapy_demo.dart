import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/online_therapy_demo.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/online_therapy_demo_scope.dart';
import 'package:go_router/go_router.dart';

RouteBase createOnlineTherapyDemoRoute() => ShellRoute(
  builder: (context, state, child) => OnlineTherapyDemoScope(child: child),
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
      builder: (final context, final state) =>
          const OnlineTherapyDemoAdminHubPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoAdminVerificationPath,
      name: AppRoutes.onlineTherapyDemoAdminVerification,
      builder: (final context, final state) =>
          const OnlineTherapyDemoAdminVerificationPage(),
    ),
    GoRoute(
      path: AppRoutes.onlineTherapyDemoAdminAuditPath,
      name: AppRoutes.onlineTherapyDemoAdminAudit,
      builder: (final context, final state) =>
          const OnlineTherapyDemoAdminAuditPage(),
    ),
  ],
);

// eof
// end
//
