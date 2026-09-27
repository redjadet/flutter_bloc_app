import XCTest

@testable import Runner

final class NativeSecurityShowcaseReplyPolicyTests: XCTestCase {
  func testOperationChecksPassedNullFlagsAreOk() {
    XCTAssertTrue(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified: nil,
        wrote: nil,
        readMatched: nil,
        deleted: nil
      )
    )
  }

  func testOperationChecksPassedTrueFlagsAreOk() {
    XCTAssertTrue(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified: true,
        wrote: true,
        readMatched: true,
        deleted: true
      )
    )
  }

  func testOperationChecksPassedRejectsFalseVerified() {
    XCTAssertFalse(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified: false,
        wrote: nil,
        readMatched: nil,
        deleted: nil
      )
    )
  }

  func testOperationChecksPassedRejectsFalseStorageFlags() {
    XCTAssertFalse(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified: nil,
        wrote: true,
        readMatched: false,
        deleted: true
      )
    )
  }

  func testCoerceOutcomeDowngradesSuccessWhenVerifiedFalse() {
    let outcome = NativeSecurityShowcaseReplyPolicy.coerceOutcome(
      status: NativeSecurityShowcaseReplyPolicy.statusSuccess,
      reasonCode: "ok",
      verified: false
    )
    XCTAssertEqual(outcome.status, NativeSecurityShowcaseReplyPolicy.statusFailed)
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseReplyPolicy.reasonPlatformError
    )
  }

  func testCoerceOutcomeKeepsSuccessWhenChecksPass() {
    let outcome = NativeSecurityShowcaseReplyPolicy.coerceOutcome(
      status: NativeSecurityShowcaseReplyPolicy.statusSuccess,
      reasonCode: "ok",
      verified: true,
      wrote: true,
      readMatched: true,
      deleted: true
    )
    XCTAssertEqual(outcome.status, NativeSecurityShowcaseReplyPolicy.statusSuccess)
    XCTAssertEqual(outcome.reasonCode, "ok")
  }

  func testCoerceOutcomeLeavesNonSuccessUnchanged() {
    let outcome = NativeSecurityShowcaseReplyPolicy.coerceOutcome(
      status: "denied",
      reasonCode: "biometric_canceled",
      verified: false
    )
    XCTAssertEqual(outcome.status, "denied")
    XCTAssertEqual(outcome.reasonCode, "biometric_canceled")
  }
}
