import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_proof_submit_eligibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StaffDemoProofSubmitEligibility.validateDraft', () {
    test('blocks when user is missing', () {
      expect(
        StaffDemoProofSubmitEligibility.validateDraft(
          userId: null,
          siteId: 'site-1',
          signaturePath: '/tmp/sig.png',
        ),
        StaffDemoProofSubmitBlockReason.notSignedIn,
      );
    });

    test('blocks when user id is blank', () {
      expect(
        StaffDemoProofSubmitEligibility.validateDraft(
          userId: '   ',
          siteId: 'site-1',
          signaturePath: '/tmp/sig.png',
        ),
        StaffDemoProofSubmitBlockReason.notSignedIn,
      );
    });

    test('blocks when site id is blank', () {
      expect(
        StaffDemoProofSubmitEligibility.validateDraft(
          userId: 'user-1',
          siteId: '   ',
          signaturePath: '/tmp/sig.png',
        ),
        StaffDemoProofSubmitBlockReason.siteIdRequired,
      );
    });

    test('blocks when signature path is missing', () {
      expect(
        StaffDemoProofSubmitEligibility.validateDraft(
          userId: 'user-1',
          siteId: 'site-1',
          signaturePath: null,
        ),
        StaffDemoProofSubmitBlockReason.signatureRequired,
      );
    });

    test('blocks when signature path is blank', () {
      expect(
        StaffDemoProofSubmitEligibility.validateDraft(
          userId: 'user-1',
          siteId: 'site-1',
          signaturePath: '   ',
        ),
        StaffDemoProofSubmitBlockReason.signatureRequired,
      );
    });

    test('returns null when draft is eligible', () {
      expect(
        StaffDemoProofSubmitEligibility.validateDraft(
          userId: 'user-1',
          siteId: 'site-1',
          signaturePath: '/tmp/sig.png',
        ),
        isNull,
      );
    });
  });
}
