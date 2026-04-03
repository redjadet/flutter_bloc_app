/// Deletes remote case study data (DB + Storage objects) for a case id.
///
/// This is separate from local deletion, and must be safe to call multiple times
/// (idempotent on the backend).
abstract class CaseStudyRemoteDeleteRepository {
  Future<void> deleteCaseStudyRemote({required final String caseId});
}
