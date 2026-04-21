// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_data_mode_badge.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';

class CaseStudyDemoHomePage extends StatelessWidget {
  const CaseStudyDemoHomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    final CaseStudyDataMode mode = CaseStudyDataModeBadge.fromSupabaseAuth(
      supaAuth,
    );
    return CommonPageLayout(
      title: l10n.caseStudyDemoTitle,
      body: BlocBuilder<CaseStudySessionCubit, CaseStudySessionState>(
        builder: (context, state) {
          if (state.hydration != CaseStudyHydrationStatus.ready) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CaseStudyDataModeBadge(mode: mode),
                ),
              ),
              FilledButton(
                onPressed: () async {
                  await context.cubit<CaseStudySessionCubit>().startNewCase();
                  if (context.mounted) {
                    await context.pushNamed(AppRoutes.caseStudyDemoNew);
                  }
                },
                child: Text(l10n.caseStudyDemoNewCase),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () =>
                    context.pushNamed(AppRoutes.caseStudyDemoHistory),
                child: Text(l10n.caseStudyDemoHistory),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pushNamed(AppRoutes.settings),
                child: Text(l10n.caseStudyDemoSettings),
              ),
            ],
          );
        },
      ),
    );
  }
}
