import LocalAuthentication
import XCTest

@testable import Runner

final class NativeSecurityShowcaseBiometricErrorPolicyTests: XCTestCase {
  func testUserCancelIsDeniedCanceled() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(
      NSError(domain: LAError.errorDomain, code: LAError.userCancel.rawValue)
    )
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusDenied
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonBiometricCanceled
    )
  }

  func testAppCancelIsDeniedCanceled() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(
      NSError(domain: LAError.errorDomain, code: LAError.appCancel.rawValue)
    )
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusDenied
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonBiometricCanceled
    )
  }

  func testBiometryLockoutIsDeniedLockout() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(
      NSError(domain: LAError.errorDomain, code: LAError.biometryLockout.rawValue)
    )
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusDenied
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonBiometricLockout
    )
  }

  func testBiometryNotEnrolledIsUnavailable() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(
      NSError(
        domain: LAError.errorDomain,
        code: LAError.biometryNotEnrolled.rawValue
      )
    )
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusUnavailable
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonBiometricNotEnrolled
    )
  }

  func testBiometryNotAvailableIsUnavailableUnsupported() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(
      NSError(
        domain: LAError.errorDomain,
        code: LAError.biometryNotAvailable.rawValue
      )
    )
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusUnavailable
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonBiometricUnsupported
    )
  }

  func testPasscodeNotSetIsUnavailableUnsupported() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(
      NSError(domain: LAError.errorDomain, code: LAError.passcodeNotSet.rawValue)
    )
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusUnavailable
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonBiometricUnsupported
    )
  }

  func testNilErrorIsFailedPlatformError() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(nil)
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusFailed
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonPlatformError
    )
  }

  func testForeignDomainIsFailedPlatformError() {
    let outcome = NativeSecurityShowcaseBiometricErrorPolicy.mapAuthenticationError(
      NSError(domain: "com.example.other", code: 1)
    )
    XCTAssertEqual(
      outcome.status,
      NativeSecurityShowcaseBiometricErrorPolicy.statusFailed
    )
    XCTAssertEqual(
      outcome.reasonCode,
      NativeSecurityShowcaseBiometricErrorPolicy.reasonPlatformError
    )
  }
}
