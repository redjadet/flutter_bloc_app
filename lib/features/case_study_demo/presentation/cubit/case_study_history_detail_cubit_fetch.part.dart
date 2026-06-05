part of 'case_study_history_detail_cubit.dart';

mixin _CaseStudyHistoryDetailCubitFetch on _CaseStudyHistoryDetailCubitBase {
  Future<_DetailLoadResult> _fetchDetail() async {
    final String? userId = authRepository.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return const _DetailLoadResult.unavailable();
    }

    if (_remoteAuth.isConfigured && _remoteAuth.currentUser != null) {
      final RemoteCaseStudyDetail? detail = await _remote.getSubmittedCase(
        caseId: recordId,
      );
      if (detail == null) {
        return const _DetailLoadResult.notFound();
      }

      final Map<String, String> signedUrls =
          await signCaseStudyPlaybackUrlsInBatches(
            remote: _remote,
            keysByQuestion: detail.remoteObjectKeysByQuestion,
            ttl: kCaseStudySignedPlaybackUrlTtl,
          );

      return _DetailLoadResult.ok(
        record: CaseStudyRecord(
          id: detail.caseId,
          submittedAt: detail.submittedAtUtc,
          doctorName: detail.doctorName,
          caseType: detail.caseType,
          notes: detail.notes,
          answers: signedUrls,
        ),
        usesExpiringCloudPlaybackUrls: true,
      );
    }

    await _local.ensureReady();
    final CaseStudyRecord? record = await _local.getRecord(userId, recordId);
    if (record == null) {
      return const _DetailLoadResult.notFound();
    }
    return _DetailLoadResult.ok(
      record: record,
      usesExpiringCloudPlaybackUrls: false,
    );
  }
}

class _DetailLoadResult {
  const _DetailLoadResult._({
    required this.unavailable,
    required this.notFound,
    this.record,
    this.usesExpiringCloudPlaybackUrls = false,
  });

  const _DetailLoadResult.unavailable()
    : this._(unavailable: true, notFound: false);

  const _DetailLoadResult.notFound()
    : this._(unavailable: false, notFound: true);

  const _DetailLoadResult.ok({
    required final CaseStudyRecord record,
    required final bool usesExpiringCloudPlaybackUrls,
  }) : this._(
         unavailable: false,
         notFound: false,
         record: record,
         usesExpiringCloudPlaybackUrls: usesExpiringCloudPlaybackUrls,
       );

  final bool unavailable;
  final bool notFound;
  final CaseStudyRecord? record;
  final bool usesExpiringCloudPlaybackUrls;
}
