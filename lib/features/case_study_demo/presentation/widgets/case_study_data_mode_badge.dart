import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/design_system/app_styles.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:mix/mix.dart';

enum CaseStudyDataMode { localOnly, supabase, unknown }

class CaseStudyDataModeBadge extends StatelessWidget {
  const CaseStudyDataModeBadge({required this.mode, super.key});

  final CaseStudyDataMode mode;

  static CaseStudyDataMode fromSupabaseAuth(
    final SupabaseAuthRepository auth,
  ) {
    if (!auth.isConfigured) return CaseStudyDataMode.localOnly;
    if (auth.currentUser != null) return CaseStudyDataMode.supabase;
    return CaseStudyDataMode.unknown;
  }

  @override
  Widget build(final BuildContext context) {
    if (mode == CaseStudyDataMode.unknown) return const SizedBox.shrink();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final String label = switch (mode) {
      CaseStudyDataMode.localOnly => l10n.caseStudyDataModeLocalOnly,
      CaseStudyDataMode.supabase => l10n.caseStudyDataModeSupabase,
      CaseStudyDataMode.unknown => '',
    };

    return Box(
      style: AppStyles.chip,
      child: Text(
        label,
        style: theme.textTheme.labelMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
