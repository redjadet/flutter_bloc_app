import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_upload_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_video_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_demo_home_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_detail_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_history_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_metadata_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_record_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/pages/case_study_review_page.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_supabase_auth_gate.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/bloc_provider_helpers.dart';
import 'package:go_router/go_router.dart';

FutureOr<String?> _redirectCaseStudyRecord(
  final BuildContext context,
  final GoRouterState state,
) async {
  final AuthRepository auth = getIt<AuthRepository>();
  final String? userId = auth.currentUser?.id;
  if (userId == null || userId.isEmpty) return null;

  final CaseStudyLocalRepository local = getIt<CaseStudyLocalRepository>();
  await local.ensureReady();
  final CaseStudyDraft? draft = await local.loadDraft(userId);
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
  final BuildContext context,
  final GoRouterState state,
) async {
  final AuthRepository auth = getIt<AuthRepository>();
  final String? userId = auth.currentUser?.id;
  if (userId == null || userId.isEmpty) return null;

  final CaseStudyLocalRepository local = getIt<CaseStudyLocalRepository>();
  await local.ensureReady();
  final CaseStudyDraft? draft = await local.loadDraft(userId);
  if (draft == null || !draft.hasMetadata) {
    return AppRoutes.caseStudyDemoNewPath;
  }
  if (!draft.isComplete) {
    return AppRoutes.caseStudyDemoRecordPath;
  }
  return null;
}

/// Shell + routes for the dentist case-study demo (auth gate + session cubit).
ShellRoute createCaseStudyDemoShellRoute() => ShellRoute(
  builder:
      (
        context,
        state,
        child,
      ) {
        final AuthRepository auth = getIt<AuthRepository>();
        final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
        return AppRouteAuthGate(
          policy: AppRoutePolicies.caseStudyDemo,
          getCurrentUser: () => auth.currentUser,
          authStateChanges: auth.authStateChanges,
          authPath: AppRoutes.authPath,
          child: CaseStudySupabaseAuthGate(
            isSupabaseInitialized: supaAuth.isConfigured,
            getCurrentUser: () => supaAuth.currentUser,
            authStateChanges: supaAuth.authStateChanges,
            fallbackPath: AppRoutes.counterPath,
            supabaseAuthPath: AppRoutes.supabaseAuthPath,
            redirectReturnPath: state.uri.toString(),
            child: BlocProviderHelpers.withAsyncInit<CaseStudySessionCubit>(
              create: () => CaseStudySessionCubit(
                authRepository: auth,
                localRepository: getIt<CaseStudyLocalRepository>(),
                videoRepository: getIt<CaseStudyVideoRepository>(),
                uploadRepository: getIt<CaseStudyUploadRepository>(),
                clipStore: getIt<CaseStudyClipFileStore>(),
                remoteDeleteRepository:
                    getIt<CaseStudyRemoteDeleteRepository>(),
                supabaseAuthRepository: supaAuth,
                remoteRepository: getIt<CaseStudyRemoteRepository>(),
              ),
              init: (cubit) => cubit.hydrate(),
              child: child,
            ),
          ),
        );
      },
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.caseStudyDemoPath,
      name: AppRoutes.caseStudyDemo,
      builder: (context, state) => const CaseStudyDemoHomePage(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoNewPath,
      name: AppRoutes.caseStudyDemoNew,
      builder: (context, state) => const CaseStudyMetadataPage(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoRecordPath,
      name: AppRoutes.caseStudyDemoRecord,
      redirect: _redirectCaseStudyRecord,
      builder: (context, state) => const CaseStudyRecordPage(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoReviewPath,
      name: AppRoutes.caseStudyDemoReview,
      redirect: _redirectCaseStudyReview,
      builder: (context, state) => const CaseStudyReviewPage(),
    ),
    GoRoute(
      path: AppRoutes.caseStudyDemoHistoryPath,
      name: AppRoutes.caseStudyDemoHistory,
      builder: (context, state) => const CaseStudyHistoryPage(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          name: AppRoutes.caseStudyDemoHistoryDetail,
          builder: (context, state) => CaseStudyHistoryDetailPage(
            recordId: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    ),
  ],
);
