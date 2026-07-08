import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_clip_file_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCaseStudyClipFileStore implements CaseStudyClipFileStore {
  @override
  Future<String> persistClipToStaging({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
    required final int commitToken,
  }) async => throw UnimplementedError();

  @override
  String finalClipFilePathFromStaging(final String stagingPath) {
    final String out = stagingPath.replaceFirst('.staging.', '.final.');
    return out == stagingPath ? stagingPath : out;
  }

  @override
  String promoteStagingToFinalSync({
    required final String stagingPath,
    required final String finalPath,
  }) => throw UnimplementedError();

  @override
  Future<String> persistClip({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteFileIfExists(final String? path) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteCaseFolder(final String caseId) async =>
      throw UnimplementedError();

  @override
  Future<List<int>> readClipBytes(final String path) async =>
      throw UnimplementedError();
}

void main() {
  group('CaseStudyClipFileStore.finalClipFilePathFromStaging', () {
    test('derives a per-pick unique final path (forces UI to refresh)', () {
      final CaseStudyClipFileStore store = _FakeCaseStudyClipFileStore();

      final String staging1 = '/docs/case_study_clips/case-1/q3.staging.1.mp4';
      final String staging2 = '/docs/case_study_clips/case-1/q3.staging.2.mp4';

      final String final1 = store.finalClipFilePathFromStaging(staging1);
      final String final2 = store.finalClipFilePathFromStaging(staging2);

      expect(final1, endsWith('q3.final.1.mp4'));
      expect(final2, endsWith('q3.final.2.mp4'));
      expect(final1, isNot(equals(final2)));
    });

    test('is a no-op when given an unexpected path shape', () {
      final CaseStudyClipFileStore store = _FakeCaseStudyClipFileStore();
      const String raw = '/docs/case_study_clips/case-1/q3.mp4';
      expect(store.finalClipFilePathFromStaging(raw), raw);
    });
  });
}
