//
//  NativeSecurityShowcaseReplyPolicy.swift
//
//  Pure reply-policy helpers for the native security MethodChannel.
//  Host handlers must not report `success` when any present check flag is
//  false — that would let a buggy crypto path paint "OK" in the Dart UI.
//  Extracted so XCTest can cover the contract without Secure Enclave /
//  biometric hardware.
//

import Foundation

enum NativeSecurityShowcaseReplyPolicy {
  static let statusSuccess = "success"
  static let statusFailed = "failed"
  static let reasonPlatformError = "platform_error"

  /// Success only when every present check flag is true (nil = not applicable).
  static func operationChecksPassed(
    verified: Bool?,
    wrote: Bool?,
    readMatched: Bool?,
    deleted: Bool?
  ) -> Bool {
    if verified == false {
      return false
    }
    if wrote == false || readMatched == false || deleted == false {
      return false
    }
    return true
  }

  /// Downgrades a claimed `success` to `failed` / `platform_error` when any
  /// present check flag is false. Non-success statuses pass through unchanged.
  static func coerceOutcome(
    status: String,
    reasonCode: String,
    verified: Bool? = nil,
    wrote: Bool? = nil,
    readMatched: Bool? = nil,
    deleted: Bool? = nil
  ) -> (status: String, reasonCode: String) {
    if status == statusSuccess &&
      !operationChecksPassed(
        verified: verified,
        wrote: wrote,
        readMatched: readMatched,
        deleted: deleted
      )
    {
      return (statusFailed, reasonPlatformError)
    }
    return (status, reasonCode)
  }
}
