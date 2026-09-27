//
//  NativeSecurityShowcaseBiometricErrorPolicy.swift
//
//  Pure LocalAuthentication error → status/reason mapping for the native
//  security MethodChannel. Extracted so XCTest can cover denied vs
//  unavailable vs failed without Secure Enclave / biometric hardware.
//

import Foundation
import LocalAuthentication

enum NativeSecurityShowcaseBiometricErrorPolicy {
  static let statusDenied = "denied"
  static let statusUnavailable = "unavailable"
  static let statusFailed = "failed"

  static let reasonBiometricLockout = "biometric_lockout"
  static let reasonBiometricCanceled = "biometric_canceled"
  static let reasonBiometricNotEnrolled = "biometric_not_enrolled"
  static let reasonBiometricUnsupported = "biometric_unsupported"
  static let reasonPlatformError = "platform_error"

  /// Maps an LAError (or unknown NSError) to the channel status/reason pair.
  static func mapAuthenticationError(
    _ error: NSError?
  ) -> (status: String, reasonCode: String) {
    guard let error,
          error.domain == LAError.errorDomain,
          let code = LAError.Code(rawValue: error.code)
    else {
      return (statusFailed, reasonPlatformError)
    }
    switch code {
    case .userCancel, .appCancel, .systemCancel:
      return (statusDenied, reasonBiometricCanceled)
    case .biometryLockout:
      return (statusDenied, reasonBiometricLockout)
    case .biometryNotEnrolled:
      return (statusUnavailable, reasonBiometricNotEnrolled)
    case .biometryNotAvailable, .passcodeNotSet:
      return (statusUnavailable, reasonBiometricUnsupported)
    default:
      return (statusFailed, reasonPlatformError)
    }
  }
}
