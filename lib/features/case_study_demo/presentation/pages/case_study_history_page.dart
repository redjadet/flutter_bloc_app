import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_data_mode_badge.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CaseStudyHistoryPage extends StatefulWidget {
  const CaseStudyHistoryPage({super.key});

  @override
  State<CaseStudyHistoryPage> createState() => _CaseStudyHistoryPageState();
}

class _CaseStudyHistoryPageState extends State<CaseStudyHistoryPage> {
  Future<List<CaseStudyRecord>>? _future;
  late final SupabaseAuthRepository _supaAuth;

  @override
  void initState() {
    super.initState();
    _supaAuth = getIt<SupabaseAuthRepository>();
    _future = _load();
  }

  Future<List<CaseStudyRecord>> _load() async {
    final AuthRepository auth = getIt<AuthRepository>();
    final String? userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return <CaseStudyRecord>[];
    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    if (supaAuth.isConfigured && supaAuth.currentUser != null) {
      final CaseStudyRemoteRepository remote =
          getIt<CaseStudyRemoteRepository>();
      final List<RemoteCaseStudySummary> summaries = await remote
          .listSubmittedCases();
      return summaries
          .map(
            (s) => CaseStudyRecord(
              id: s.caseId,
              submittedAt: s.submittedAtUtc,
              doctorName: s.doctorName,
              caseType: s.caseType,
              notes: s.notes,
              answers: const <String, String>{},
            ),
          )
          .toList();
    }

    final CaseStudyLocalRepository local = getIt<CaseStudyLocalRepository>();
    await local.ensureReady();
    return local.loadRecords(userId);
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final CaseStudyDataMode mode = CaseStudyDataModeBadge.fromSupabaseAuth(
      _supaAuth,
    );
    return CommonPageLayout(
      title: l10n.caseStudyHistoryTitle,
      body: FutureBuilder<List<CaseStudyRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<CaseStudyRecord> records =
              snapshot.data ?? <CaseStudyRecord>[];
          if (records.isEmpty) {
            return Center(child: Text(l10n.caseStudyHistoryEmpty));
          }
          final DateFormat fmt = DateFormat.yMMMd().add_jm();
          return RefreshIndicator(
            onRefresh: () async {
              final Future<List<CaseStudyRecord>> next = _load();
              setState(() => _future = next);
              await next;
            },
            child: ListView.separated(
              itemCount: records.length + 1,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CaseStudyDataModeBadge(mode: mode),
                    ),
                  );
                }
                final int recordIndex = i - 1;
                final CaseStudyRecord r = records[recordIndex];
                return ListTile(
                  title: Text(r.doctorName),
                  subtitle: Text(
                    '${caseStudyCaseTypeTitle(l10n, r.caseType)} · ${fmt.format(r.submittedAt.toLocal())}',
                  ),
                  onTap: () => context.pushNamed(
                    AppRoutes.caseStudyDemoHistoryDetail,
                    pathParameters: <String, String>{'id': r.id},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
