import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/data/case_study_clip_file_store.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_delete_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_data_mode_badge.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
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

  Future<bool> _confirmDelete(final BuildContext context) async {
    final l10n = context.l10n;
    final bool? confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (final dialogContext) => AlertDialog.adaptive(
        title: Text(l10n.caseStudyDeleteDialogTitle),
        content: Text(l10n.caseStudyDeleteDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteButtonLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteRecord({
    required final String recordId,
  }) async {
    final AuthRepository auth = getIt<AuthRepository>();
    final String? userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    final bool isRemote = supaAuth.isConfigured && supaAuth.currentUser != null;

    try {
      if (isRemote) {
        final CaseStudyRemoteDeleteRepository remoteDelete =
            getIt<CaseStudyRemoteDeleteRepository>();
        await remoteDelete.deleteCaseStudyRemote(caseId: recordId);
      } else {
        final CaseStudyLocalRepository local =
            getIt<CaseStudyLocalRepository>();
        await local.ensureReady();
        final List<CaseStudyRecord> records = await local.loadRecords(userId);
        final List<CaseStudyRecord> next = records
            .where((final r) => r.id != recordId)
            .toList();
        await local.saveRecords(userId, next);
        await getIt<CaseStudyClipFileStore>().deleteCaseFolder(recordId);
      }

      final Future<List<CaseStudyRecord>> nextFuture = _load();
      if (!mounted) return;
      setState(() {
        _future = nextFuture;
      });
      await nextFuture;
    } on Object catch (error) {
      if (error is HttpRequestFailure && error.statusCode == 401) {
        try {
          await getIt<SupabaseAuthRepository>().signOut();
        } on Object {
          // Best-effort only; still show the error message.
        }
      }
      if (!mounted) return;
      ErrorHandling.handleCubitError(context, error);
    }
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
              if (mounted) {
                setState(() {
                  _future = next;
                });
              }
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
                      alignment: AlignmentDirectional.centerStart,
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
                  trailing: IconButton(
                    tooltip: l10n.deleteButtonLabel,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final bool shouldDelete = await _confirmDelete(context);
                      if (!shouldDelete || !context.mounted) return;
                      await _deleteRecord(recordId: r.id);
                    },
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
