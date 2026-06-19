/// Domain-only submit eligibility for staff demo proof capture.
enum StaffDemoProofSubmitBlockReason {
  notSignedIn,
  siteIdRequired,
  signatureRequired,
}

abstract final class StaffDemoProofSubmitEligibility {
  const StaffDemoProofSubmitEligibility._();

  /// Returns a block reason when draft inputs cannot be submitted yet.
  static StaffDemoProofSubmitBlockReason? validateDraft({
    required final String? userId,
    required final String siteId,
    required final String? signaturePath,
  }) {
    if (userId == null || userId.trim().isEmpty) {
      return StaffDemoProofSubmitBlockReason.notSignedIn;
    }
    if (siteId.trim().isEmpty) {
      return StaffDemoProofSubmitBlockReason.siteIdRequired;
    }
    if (signaturePath == null || signaturePath.trim().isEmpty) {
      return StaffDemoProofSubmitBlockReason.signatureRequired;
    }
    return null;
  }

  static String messageFor(final StaffDemoProofSubmitBlockReason reason) =>
      switch (reason) {
        StaffDemoProofSubmitBlockReason.notSignedIn => 'Not signed in.',
        StaffDemoProofSubmitBlockReason.siteIdRequired =>
          'Site ID is required.',
        StaffDemoProofSubmitBlockReason.signatureRequired =>
          'Signature is required.',
      };
}
