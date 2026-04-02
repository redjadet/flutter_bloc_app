// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_question_prompt.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_video_tile.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:intl/intl.dart';

class CaseStudyHistoryDetailPage extends StatefulWidget {
  const CaseStudyHistoryDetailPage({required this.recordId, super.key});

  final String recordId;

  @override
  State<CaseStudyHistoryDetailPage> createState() =>
      _CaseStudyHistoryDetailPageState();
}

class _CaseStudyHistoryDetailPageState
    extends State<CaseStudyHistoryDetailPage> {
  Future<CaseStudyRecord?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<CaseStudyRecord?> _load() async {
    final AuthRepository auth = getIt<AuthRepository>();
    final String? userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return null;

    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    if (supaAuth.isConfigured && supaAuth.currentUser != null) {
      final CaseStudyRemoteRepository remote =
          getIt<CaseStudyRemoteRepository>();
      final RemoteCaseStudyDetail? detail = await remote.getSubmittedCase(
        caseId: widget.recordId,
      );
      if (detail == null) return null;

      final Map<String, String> signedUrls = <String, String>{};
      for (final MapEntry<String, String> e
          in detail.remoteObjectKeysByQuestion.entries) {
        final String url = await remote.createSignedPlaybackUrl(
          objectKey: e.value,
          ttl: const Duration(hours: 24),
        );
        signedUrls[e.key] = url;
      }

      return CaseStudyRecord(
        id: detail.caseId,
        submittedAt: detail.submittedAtUtc,
        doctorName: detail.doctorName,
        caseType: detail.caseType,
        notes: detail.notes,
        answers: signedUrls,
      );
    }

    final CaseStudyLocalRepository local = getIt<CaseStudyLocalRepository>();
    await local.ensureReady();
    return local.getRecord(userId, widget.recordId);
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.caseStudyHistoryDetailTitle,
      body: FutureBuilder<CaseStudyRecord?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final CaseStudyRecord? r = snapshot.data;
          if (r == null) {
            return Center(child: Text(l10n.caseStudyErrorGeneric));
          }
          final DateFormat fmt = DateFormat.yMMMd().add_jm();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
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
          );
        },
      ),
    );
  }
}
