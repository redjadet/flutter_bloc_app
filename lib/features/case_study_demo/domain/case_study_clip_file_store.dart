/// Persists picked case-study video clips under app documents.
abstract class CaseStudyClipFileStore {
  Future<String> persistClipToStaging({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
    required final int commitToken,
  });

  String finalClipFilePathFromStaging(final String stagingPath);

  String promoteStagingToFinalSync({
    required final String stagingPath,
    required final String finalPath,
  });

  Future<String> persistClip({
    required final String sourcePath,
    required final String caseId,
    required final String questionId,
  });

  Future<void> deleteFileIfExists(final String? path);

  Future<void> deleteCaseFolder(final String caseId);
}
