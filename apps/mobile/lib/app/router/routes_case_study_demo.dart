import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_history_detail_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_demo_home_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_detail_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_metadata_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_record_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_review_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_supabase_auth_gate.dart';
import 'package:go_router/go_router.dart';

/// Shell + routes for the dentist case-study demo (auth gate + session cubit).
ShellRoute createCaseStudyDemoShellRoute(CaseStudyDemoRouteFactory factory) =>
    factory.createShellRoute();

class const CaseStudyDemoRouteFactory({
  required final AuthRepository authRepository,
  required final CaseStudyLocalRepository localRepository,
  required final CaseStudyRemoteDeleteRepository remoteDeleteRepository,
  required final CaseStudyRemoteRepository remoteRepository,
  required final CaseStudyUploadRepository uploadRepository,
  required final CaseStudyVideoRepository videoRepository,
  required final CaseStudyClipFileStore clipStore,
  required final RemoteBackendAuthPort remoteAuth,
  required final TimerService timerService,
}) {
  FutureOr<String?> _redirectForDraft(
    String? Function(CaseStudyDraft draft) decide,
  ) async {
    final userId = authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) return null;

    await localRepository.ensureReady();
    final draft = await localRepository.loadDraft(userId);
    if (draft == null || !draft.hasMetadata) {
      return AppRoutes.caseStudyDemoNewPath;
    }
    return decide(draft);
  }

  FutureOr<String?> _redirectCaseStudyRecord(
    BuildContext context,
    GoRouterState state,
  ) => _redirectForDraft(
    (draft) => switch (draft.phase) {
      CaseStudyDraftPhase.metadata => AppRoutes.caseStudyDemoNewPath,
      CaseStudyDraftPhase.recording => null,
      CaseStudyDraftPhase.reviewing =>
        draft.isComplete ? AppRoutes.caseStudyDemoReviewPath : null,
    },
  );

  FutureOr<String?> _redirectCaseStudyReview(
    BuildContext context,
    GoRouterState state,
  ) => _redirectForDraft(
    (draft) => draft.isComplete ? null : AppRoutes.caseStudyDemoRecordPath,
  );

  Widget _buildShell(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => AppRouteAuthGate(
    policy: AppRoutePolicies.caseStudyDemo,
    getCurrentUser: () => authRepository.currentUser,
    authStateChanges: authRepository.authStateChanges,
    authPath: AppRoutes.authPath,
    child: CaseStudySupabaseAuthGate(
      isSupabaseInitialized: remoteAuth.isConfigured,
      getCurrentUser: () => remoteAuth.currentUser,
      authStateChanges: remoteAuth.authStateChanges,
      fallbackPath: AppRoutes.authPath,
      supabaseAuthPath: AppRoutes.supabaseAuthPath,
      redirectReturnPath: state.uri.toString(),
      child: child.routeScoped(
        create: () => CaseStudySessionCubit(
          authRepository: authRepository,
          localRepository: localRepository,
          videoRepository: videoRepository,
          uploadRepository: uploadRepository,
          clipStore: clipStore,
          remoteDeleteRepository: remoteDeleteRepository,
          remoteBackendAuth: remoteAuth,
          remoteRepository: remoteRepository,
          timerService: timerService,
        ),
        init: (cubit) => cubit.hydrate(),
      ),
    ),
  );

  CaseStudyHistoryCubit _createHistoryCubit() => CaseStudyHistoryCubit(
    authRepository: authRepository,
    localRepository: localRepository,
    remoteRepository: remoteRepository,
    remoteDeleteRepository: remoteDeleteRepository,
    clipStore: clipStore,
    remoteBackendAuth: remoteAuth,
  );

  ShellRoute createShellRoute() => ShellRoute(
    builder: _buildShell,
    routes: <RouteBase>[
      RouteScopedPage.route(
        path: AppRoutes.caseStudyDemoPath,
        name: AppRoutes.caseStudyDemo,
        builder: (_, _) => CaseStudyDemoHomePage(remoteAuth: remoteAuth),
      ),
      RouteScopedPage.route(
        path: AppRoutes.caseStudyDemoNewPath,
        name: AppRoutes.caseStudyDemoNew,
        builder: (_, _) => const CaseStudyMetadataPage(),
      ),
      RouteScopedPage.route(
        path: AppRoutes.caseStudyDemoRecordPath,
        name: AppRoutes.caseStudyDemoRecord,
        redirect: _redirectCaseStudyRecord,
        builder: (_, _) => const CaseStudyRecordPage(),
      ),
      RouteScopedPage.route(
        path: AppRoutes.caseStudyDemoReviewPath,
        name: AppRoutes.caseStudyDemoReview,
        redirect: _redirectCaseStudyReview,
        builder: (_, _) => const CaseStudyReviewPage(),
      ),
      RouteScopedPage.routeWithCubit<CaseStudyHistoryCubit>(
        path: AppRoutes.caseStudyDemoHistoryPath,
        name: AppRoutes.caseStudyDemoHistory,
        create: (_, _) => _createHistoryCubit(),
        init: (cubit) => cubit.load(),
        child: const CaseStudyHistoryPage(),
        routes: <RouteBase>[
          RouteScopedPage.routeWithCubit<CaseStudyHistoryDetailCubit>(
            path: ':id',
            name: AppRoutes.caseStudyDemoHistoryDetail,
            create: (_, state) => CaseStudyHistoryDetailCubit(
              recordId: state.pathParameters['id'] ?? '',
              authRepository: authRepository,
              localRepository: localRepository,
              remoteRepository: remoteRepository,
              remoteDeleteRepository: remoteDeleteRepository,
              clipStore: clipStore,
              remoteBackendAuth: remoteAuth,
            ),
            init: (cubit) => cubit.load(),
            child: const CaseStudyHistoryDetailPage(),
          ),
        ],
      ),
    ],
  );
}
