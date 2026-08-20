import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
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
import 'package:material_ui/material_ui.dart';

/// Shell + routes for the dentist case-study demo (auth gate + session cubit).
ShellRoute createCaseStudyDemoShellRoute(CaseStudyDemoRouteFactory factory) =>
    factory.createShellRoute();

class CaseStudyDemoRouteFactory({
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
  FutureOr<String?> _redirectCaseStudyRecord(
    BuildContext context,
    GoRouterState state,
  ) async {
    final String? userId = authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) return null;

    await localRepository.ensureReady();
    final CaseStudyDraft? draft = await localRepository.loadDraft(userId);
    if (draft == null || !draft.hasMetadata) {
      return AppRoutes.caseStudyDemoNewPath;
    }
    switch (draft.phase) {
      case CaseStudyDraftPhase.metadata:
        return AppRoutes.caseStudyDemoNewPath;
      case CaseStudyDraftPhase.recording:
        return null;
      case CaseStudyDraftPhase.reviewing:
        if (draft.isComplete) {
          return AppRoutes.caseStudyDemoReviewPath;
        }
        return null;
    }
  }

  FutureOr<String?> _redirectCaseStudyReview(
    BuildContext context,
    GoRouterState state,
  ) async {
    final String? userId = authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) return null;

    await localRepository.ensureReady();
    final CaseStudyDraft? draft = await localRepository.loadDraft(userId);
    if (draft == null || !draft.hasMetadata) {
      return AppRoutes.caseStudyDemoNewPath;
    }
    if (!draft.isComplete) {
      return AppRoutes.caseStudyDemoRecordPath;
    }
    return null;
  }

  Widget _buildShell(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return AppRouteAuthGate(
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
        child: BlocProviderHelpers.withAsyncInit<CaseStudySessionCubit>(
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
          child: child,
        ),
      ),
    );
  }

  ShellRoute createShellRoute() => ShellRoute(
    builder: (context, state, child) => _buildShell(context, state, child),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.caseStudyDemoPath,
        name: AppRoutes.caseStudyDemo,
        pageBuilder: (context, state) => NoTransitionPage(
          child: CaseStudyDemoHomePage(remoteAuth: remoteAuth),
        ),
      ),
      GoRoute(
        path: AppRoutes.caseStudyDemoNewPath,
        name: AppRoutes.caseStudyDemoNew,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CaseStudyMetadataPage()),
      ),
      GoRoute(
        path: AppRoutes.caseStudyDemoRecordPath,
        name: AppRoutes.caseStudyDemoRecord,
        redirect: _redirectCaseStudyRecord,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CaseStudyRecordPage()),
      ),
      GoRoute(
        path: AppRoutes.caseStudyDemoReviewPath,
        name: AppRoutes.caseStudyDemoReview,
        redirect: _redirectCaseStudyReview,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: CaseStudyReviewPage()),
      ),
      GoRoute(
        path: AppRoutes.caseStudyDemoHistoryPath,
        name: AppRoutes.caseStudyDemoHistory,
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProviderHelpers.withAsyncInit<CaseStudyHistoryCubit>(
            create: () => CaseStudyHistoryCubit(
              authRepository: authRepository,
              localRepository: localRepository,
              remoteRepository: remoteRepository,
              remoteDeleteRepository: remoteDeleteRepository,
              clipStore: clipStore,
              remoteBackendAuth: remoteAuth,
            ),
            init: (cubit) => cubit.load(),
            child: const CaseStudyHistoryPage(),
          ),
        ),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            name: AppRoutes.caseStudyDemoHistoryDetail,
            pageBuilder: (context, state) {
              final String recordId = state.pathParameters['id'] ?? '';
              return NoTransitionPage(
                child:
                    BlocProviderHelpers.withAsyncInit<
                      CaseStudyHistoryDetailCubit
                    >(
                      create: () => CaseStudyHistoryDetailCubit(
                        recordId: recordId,
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
              );
            },
          ),
        ],
      ),
    ],
  );
}
