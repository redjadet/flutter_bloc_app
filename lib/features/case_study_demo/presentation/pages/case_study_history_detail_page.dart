// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart'
    show
        CaseStudyRemoteRepository,
        RemoteCaseStudyDetail,
        kCaseStudySignedPlaybackUrlTtl;
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_question_prompt.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_video_tile.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:intl/intl.dart';

class _HistoryDetailLoad {
  const _HistoryDetailLoad({
    required this.record,
    required this.usesExpiringCloudPlaybackUrls,
  });

  final CaseStudyRecord record;
  final bool usesExpiringCloudPlaybackUrls;
}

enum _HistoryDetailFailureKind { notFound, unavailable }

class _HistoryDetailSnapshot {
  const _HistoryDetailSnapshot.ok(final _HistoryDetailLoad value)
    : load = value,
      failure = null;

  const _HistoryDetailSnapshot.fail(this.failure) : load = null;

  final _HistoryDetailLoad? load;
  final _HistoryDetailFailureKind? failure;

  bool get isSuccess => load != null;
}

/// Signs clip URLs in small parallel batches to reduce wall-clock latency.
Future<Map<String, String>> _signPlaybackUrlsInBatches({
  required final CaseStudyRemoteRepository remote,
  required final Map<String, String> keysByQuestion,
  required final Duration ttl,
  final int batchSize = 4,
}) async {
  final List<MapEntry<String, String>> entries = keysByQuestion.entries
      .where((final e) => e.value.isNotEmpty)
      .toList();
  final Map<String, String> out = <String, String>{};
  for (int i = 0; i < entries.length; i += batchSize) {
    final int end = i + batchSize > entries.length
        ? entries.length
        : i + batchSize;
    final List<MapEntry<String, String>> chunk = entries.sublist(i, end);
    final List<MapEntry<String, String>> signed =
        await Future.wait<MapEntry<String, String>>(
          chunk.map((e) async {
            final String url = await remote.createSignedPlaybackUrl(
              objectKey: e.value,
              ttl: ttl,
            );
            return MapEntry<String, String>(e.key, url);
          }),
        );
    for (final MapEntry<String, String> e in signed) {
      out[e.key] = e.value;
    }
  }
  return out;
}

class CaseStudyHistoryDetailPage extends StatefulWidget {
  const CaseStudyHistoryDetailPage({required this.recordId, super.key});

  final String recordId;

  @override
  State<CaseStudyHistoryDetailPage> createState() =>
      _CaseStudyHistoryDetailPageState();
}

class _CaseStudyHistoryDetailPageState
    extends State<CaseStudyHistoryDetailPage> {
  Future<_HistoryDetailSnapshot>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDetail();
  }

  Future<_HistoryDetailSnapshot> _loadDetail() async {
    final AuthRepository auth = getIt<AuthRepository>();
    final String? userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return const _HistoryDetailSnapshot.fail(
        _HistoryDetailFailureKind.unavailable,
      );
    }

    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    if (supaAuth.isConfigured && supaAuth.currentUser != null) {
      final CaseStudyRemoteRepository remote =
          getIt<CaseStudyRemoteRepository>();
      try {
        final RemoteCaseStudyDetail? detail = await remote.getSubmittedCase(
          caseId: widget.recordId,
        );
        if (detail == null) {
          return const _HistoryDetailSnapshot.fail(
            _HistoryDetailFailureKind.notFound,
          );
        }

        final Map<String, String> signedUrls = await _signPlaybackUrlsInBatches(
          remote: remote,
          keysByQuestion: detail.remoteObjectKeysByQuestion,
          ttl: kCaseStudySignedPlaybackUrlTtl,
        );

        return _HistoryDetailSnapshot.ok(
          _HistoryDetailLoad(
            record: CaseStudyRecord(
              id: detail.caseId,
              submittedAt: detail.submittedAtUtc,
              doctorName: detail.doctorName,
              caseType: detail.caseType,
              notes: detail.notes,
              answers: signedUrls,
            ),
            usesExpiringCloudPlaybackUrls: true,
          ),
        );
      } on Object {
        return const _HistoryDetailSnapshot.fail(
          _HistoryDetailFailureKind.unavailable,
        );
      }
    }

    try {
      final CaseStudyLocalRepository local = getIt<CaseStudyLocalRepository>();
      await local.ensureReady();
      final CaseStudyRecord? record = await local.getRecord(
        userId,
        widget.recordId,
      );
      if (record == null) {
        return const _HistoryDetailSnapshot.fail(
          _HistoryDetailFailureKind.notFound,
        );
      }
      return _HistoryDetailSnapshot.ok(
        _HistoryDetailLoad(
          record: record,
          usesExpiringCloudPlaybackUrls: false,
        ),
      );
    } on Object {
      return const _HistoryDetailSnapshot.fail(
        _HistoryDetailFailureKind.unavailable,
      );
    }
  }

  /// Reloads detail without swapping to a pending [Future] first (avoids blanking the screen).
  Future<void> _reload() async {
    final _HistoryDetailSnapshot next = await _loadDetail();
    if (!mounted) return;
    setState(() => _future = Future<_HistoryDetailSnapshot>.value(next));
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.caseStudyHistoryDetailTitle,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: l10n.caseStudyRefreshDetailTooltip,
          onPressed: () async {
            await _reload();
          },
        ),
      ],
      body: FutureBuilder<_HistoryDetailSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final _HistoryDetailSnapshot? data = snapshot.data;
          if (data == null || !data.isSuccess) {
            final _HistoryDetailFailureKind kind =
                data?.failure ?? _HistoryDetailFailureKind.unavailable;
            final String message = switch (kind) {
              _HistoryDetailFailureKind.notFound =>
                l10n.caseStudyHistoryDetailNotFound,
              _HistoryDetailFailureKind.unavailable =>
                l10n.caseStudyHistoryDetailUnavailable,
            };
            return Center(child: Text(message));
          }
          final _HistoryDetailLoad? load = data.load;
          if (load == null) {
            return Center(child: Text(l10n.caseStudyHistoryDetailUnavailable));
          }
          final CaseStudyRecord r = load.record;
          final DateFormat fmt = DateFormat.yMMMd().add_jm();
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (load.usesExpiringCloudPlaybackUrls)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 22,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.caseStudySignedUrlsRefreshHint,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ListTile(
                  title: Text(l10n.caseStudyDoctorNameLabel),
                  subtitle: Text(r.doctorName),
                ),
                ListTile(
                  title: Text(l10n.caseStudyCaseTypeLabel),
                  subtitle: Text(caseStudyCaseTypeTitle(l10n, r.caseType)),
                ),
                ListTile(
                  title: Text(l10n.caseStudySubmittedAt),
                  subtitle: Text(fmt.format(r.submittedAt.toLocal())),
                ),
                if (r.notes.isNotEmpty)
                  ListTile(
                    title: Text(l10n.caseStudyNotesLabel),
                    subtitle: Text(r.notes),
                  ),
                const Divider(),
                for (final CaseStudyQuestionId qid
                    in CaseStudyQuestions.orderedIds)
                  ExpansionTile(
                    title: Text(caseStudyQuestionPrompt(l10n, qid)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: switch (r.answers[qid]) {
                          final String path when path.isNotEmpty =>
                            CaseStudyVideoTile(
                              videoPath: path,
                              l10n: l10n,
                            ),
                          _ => Text(l10n.caseStudyVideoMissing),
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
