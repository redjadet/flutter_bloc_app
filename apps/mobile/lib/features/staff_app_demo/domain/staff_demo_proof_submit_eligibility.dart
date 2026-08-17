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
    required String? userId,
    required String siteId,
    required String? signaturePath,
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

  static String messageFor(StaffDemoProofSubmitBlockReason reason) =>
      switch (reason) {
        StaffDemoProofSubmitBlockReason.notSignedIn => 'Not signed in.',
        StaffDemoProofSubmitBlockReason.siteIdRequired =>
          'Site ID is required.',
        StaffDemoProofSubmitBlockReason.signatureRequired =>
          'Signature is required.',
      };
}
