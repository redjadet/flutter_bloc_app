//
//  NativeSecurityShowcaseHandler.swift
//
//  Handles `com.example.flutter_bloc_app/native_security_showcase`.
//  All key material stays inside the Secure Enclave / Keychain; only
//  status/reason codes, residency labels, and byte counts cross the
//  channel — never raw keys, signatures, ciphertext, or the sentinel value.
//

import Foundation
import CryptoKit
import LocalAuthentication
import Security
import Flutter

final class NativeSecurityShowcaseHandler {
  private let queue = DispatchQueue(label: "com.example.flutter_bloc_app.nativeSecurityShowcase", qos: .userInitiated)
  private var isBiometricPromptActive = false
  private let stateLock = NSLock()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "p256SignVerify":
      handleP256SignVerify(result: result)
    case "aesGcmRoundTrip":
      handleAesGcmRoundTrip(result: result)
    case "secureStorageLifecycle":
      handleSecureStorageLifecycle(result: result)
    case "biometricProtectedOperation":
      handleBiometricProtectedOperation(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - P-256 sign/verify

  private func handleP256SignVerify(result: @escaping FlutterResult) {
    guard SecureEnclave.isAvailable else {
      result(buildReply(status: Constants.statusUnavailable, reasonCode: Constants.reasonSecureEnclaveUnavailable))
      return
    }
    queue.async { [weak self] in
      guard let self else { return }
      let reply: [String: Any?]
      do {
        let key = try self.secureEnclaveSigningKey()
        let challenge = try Self.randomBytes(Constants.challengeByteLength)
        let signature = try key.signature(for: challenge)
        let verified = key.publicKey.isValidSignature(signature, for: challenge)
        reply = self.buildReply(
          status: Constants.statusSuccess,
          reasonCode: Constants.reasonOk,
          hardwareBacked: true,
          algorithm: Constants.algorithmP256,
          keyResidency: Constants.residencySecureEnclave,
          verified: verified,
          challengeByteCount: challenge.count
        )
      } catch {
        reply = self.buildReply(status: Constants.statusUnavailable, reasonCode: Constants.reasonSecureEnclaveUnavailable)
      }
      DispatchQueue.main.async { result(reply) }
    }
  }

  private func secureEnclaveSigningKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
    if let stored = KeychainStore.read(account: Constants.p256Account) {
      if let key = try? SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: stored) {
        return key
      }
    }
    let key = try SecureEnclave.P256.Signing.PrivateKey()
    try KeychainStore.upsert(
      account: Constants.p256Account,
      data: key.dataRepresentation,
      accessibility: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    )
    return key
  }

  // MARK: - AES-GCM round trip

  private func handleAesGcmRoundTrip(result: @escaping FlutterResult) {
    queue.async { [weak self] in
      guard let self else { return }
      let reply: [String: Any?]
      do {
        let key = try self.aesGcmDemoKey()
        let plaintext = Constants.demoPlaintext
        let aad = Constants.demoAad
        let sealed = try AES.GCM.seal(plaintext, using: key, authenticating: aad)
        let opened = try AES.GCM.open(sealed, using: key, authenticating: aad)
        reply = self.buildReply(
          status: Constants.statusSuccess,
          reasonCode: Constants.reasonOk,
          hardwareBacked: false,
          algorithm: Constants.algorithmAesGcm,
          keyResidency: Constants.residencyKeychain,
          verified: opened == plaintext,
          ciphertextByteCount: sealed.ciphertext.count,
          plaintextByteCount: plaintext.count,
          aadByteCount: aad.count
        )
      } catch {
        reply = self.buildReply(status: Constants.statusFailed, reasonCode: Constants.reasonPlatformError)
      }
      DispatchQueue.main.async { result(reply) }
    }
  }

  private func aesGcmDemoKey() throws -> SymmetricKey {
    if let data = KeychainStore.read(account: Constants.aesAccount) {
      return SymmetricKey(data: data)
    }
    let key = SymmetricKey(size: .bits256)
    let keyData = key.withUnsafeBytes { Data($0) }
    try KeychainStore.upsert(
      account: Constants.aesAccount,
      data: keyData,
      accessibility: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    )
    return key
  }

  // MARK: - Secure storage lifecycle

  private func handleSecureStorageLifecycle(result: @escaping FlutterResult) {
    queue.async { [weak self] in
      guard let self else { return }
      let reply: [String: Any?]
      do {
        let sentinelValue = try Self.randomBytes(Constants.sentinelByteLength)
        try KeychainStore.upsert(
          account: Constants.sentinelAccount,
          data: sentinelValue,
          accessibility: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )
        let wrote = KeychainStore.read(account: Constants.sentinelAccount) != nil
        let readBack = KeychainStore.read(account: Constants.sentinelAccount)
        let readMatched = readBack == sentinelValue
        let deleteStatus = KeychainStore.delete(account: Constants.sentinelAccount)
        let deleted = deleteStatus == errSecSuccess
        reply = self.buildReply(
          status: Constants.statusSuccess,
          reasonCode: Constants.reasonOk,
          keyResidency: Constants.residencyKeychain,
          wrote: wrote,
          readMatched: readMatched,
          deleted: deleted
        )
      } catch {
        reply = self.buildReply(status: Constants.statusFailed, reasonCode: Constants.reasonPlatformError)
      }
      DispatchQueue.main.async { result(reply) }
    }
  }

  // MARK: - Biometric-protected operation

  private func handleBiometricProtectedOperation(result: @escaping FlutterResult) {
    stateLock.lock()
    if isBiometricPromptActive {
      stateLock.unlock()
      result(buildReply(status: Constants.statusFailed, reasonCode: Constants.reasonConcurrentPrompt))
      return
    }
    isBiometricPromptActive = true
    stateLock.unlock()

    guard SecureEnclave.isAvailable else {
      finishBiometric(status: Constants.statusUnavailable, reasonCode: Constants.reasonSecureEnclaveUnavailable, result: result)
      return
    }

    let context = LAContext()
    context.localizedReason = Constants.biometricPromptReason

    var canEvaluateError: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &canEvaluateError) else {
      let (status, reasonCode) = mapAuthenticationError(canEvaluateError)
      finishBiometric(status: status, reasonCode: reasonCode, result: result)
      return
    }

    var controlError: Unmanaged<CFError>?
    guard let accessControl = SecAccessControlCreateWithFlags(
      nil,
      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
      [.privateKeyUsage, .biometryCurrentSet],
      &controlError
    ) else {
      finishBiometric(status: Constants.statusUnavailable, reasonCode: Constants.reasonBiometricUnsupported, result: result)
      return
    }

    queue.async { [weak self] in
      guard let self else { return }
      do {
        let key = try self.biometricProtectedSigningKey(
          accessControl: accessControl,
          authenticationContext: context
        )
        let challenge = try Self.randomBytes(Constants.challengeByteLength)
        // Signing blocks on the OS biometric prompt bound to `context`.
        let signature = try key.signature(for: challenge)
        let verified = key.publicKey.isValidSignature(signature, for: challenge)
        self.finishBiometric(
          status: Constants.statusSuccess,
          reasonCode: Constants.reasonOk,
          hardwareBacked: true,
          algorithm: Constants.algorithmP256,
          keyResidency: Constants.residencySecureEnclave,
          verified: verified,
          challengeByteCount: challenge.count,
          result: result
        )
      } catch {
        let (status, reasonCode) = self.mapAuthenticationError(error as NSError)
        self.finishBiometric(status: status, reasonCode: reasonCode, result: result)
      }
    }
  }

  private func finishBiometric(
    status: String,
    reasonCode: String,
    hardwareBacked: Bool? = nil,
    algorithm: String? = nil,
    keyResidency: String? = nil,
    verified: Bool? = nil,
    challengeByteCount: Int? = nil,
    result: @escaping FlutterResult
  ) {
    stateLock.lock()
    isBiometricPromptActive = false
    stateLock.unlock()
    let reply = buildReply(
      status: status,
      reasonCode: reasonCode,
      hardwareBacked: hardwareBacked,
      algorithm: algorithm,
      keyResidency: keyResidency,
      verified: verified,
      challengeByteCount: challengeByteCount
    )
    DispatchQueue.main.async { result(reply) }
  }

  /// Persists only the Secure Enclave key reference. Reusing that reference
  /// avoids creating a new permanent Secure Enclave key for every demo run.
  private func biometricProtectedSigningKey(
    accessControl: SecAccessControl,
    authenticationContext: LAContext
  ) throws -> SecureEnclave.P256.Signing.PrivateKey {
    if let stored = KeychainStore.read(account: Constants.biometricAccount) {
      do {
        return try SecureEnclave.P256.Signing.PrivateKey(
          dataRepresentation: stored,
          authenticationContext: authenticationContext
        )
      } catch {
        // A biometry-set change invalidates the old reference. Remove only the
        // opaque wrapper before replacing it with a key for the current set.
        KeychainStore.delete(account: Constants.biometricAccount)
      }
    }
    let key = try SecureEnclave.P256.Signing.PrivateKey(
      accessControl: accessControl,
      authenticationContext: authenticationContext
    )
    try KeychainStore.upsert(
      account: Constants.biometricAccount,
      data: key.dataRepresentation,
      accessibility: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    )
    return key
  }

  private func mapAuthenticationError(_ error: NSError?) -> (String, String) {
    guard let error, error.domain == LAError.errorDomain, let code = LAError.Code(rawValue: error.code) else {
      return (Constants.statusFailed, Constants.reasonPlatformError)
    }
    switch code {
    case .userCancel, .appCancel, .systemCancel:
      return (Constants.statusDenied, Constants.reasonBiometricCanceled)
    case .biometryLockout:
      return (Constants.statusDenied, Constants.reasonBiometricLockout)
    case .biometryNotEnrolled:
      return (Constants.statusUnavailable, Constants.reasonBiometricNotEnrolled)
    case .biometryNotAvailable, .passcodeNotSet:
      return (Constants.statusUnavailable, Constants.reasonBiometricUnsupported)
    default:
      return (Constants.statusFailed, Constants.reasonPlatformError)
    }
  }

  // MARK: - Helpers

  private static func randomBytes(_ length: Int) throws -> Data {
    var bytes = [UInt8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
    guard status == errSecSuccess else {
      throw KeychainError.osStatus(status)
    }
    return Data(bytes)
  }

  private func buildReply(
    status: String,
    reasonCode: String,
    hardwareBacked: Bool? = nil,
    algorithm: String? = nil,
    keyResidency: String? = nil,
    verified: Bool? = nil,
    challengeByteCount: Int? = nil,
    ciphertextByteCount: Int? = nil,
    plaintextByteCount: Int? = nil,
    aadByteCount: Int? = nil,
    wrote: Bool? = nil,
    readMatched: Bool? = nil,
    deleted: Bool? = nil
  ) -> [String: Any?] {
    var resolvedStatus = status
    var resolvedReason = reasonCode
    if status == Constants.statusSuccess &&
      !Self.operationChecksPassed(
        verified: verified,
        wrote: wrote,
        readMatched: readMatched,
        deleted: deleted
      )
    {
      resolvedStatus = Constants.statusFailed
      resolvedReason = Constants.reasonPlatformError
    }
    return [
      "schemaVersion": Constants.schemaVersion,
      "status": resolvedStatus,
      "reasonCode": resolvedReason,
      "platform": Constants.platform,
      "hardwareBacked": hardwareBacked,
      "algorithm": algorithm,
      "keyResidency": keyResidency,
      "verified": verified,
      "challengeByteCount": challengeByteCount,
      "ciphertextByteCount": ciphertextByteCount,
      "plaintextByteCount": plaintextByteCount,
      "aadByteCount": aadByteCount,
      "wrote": wrote,
      "readMatched": readMatched,
      "deleted": deleted,
    ]
  }

  /// Success only when every present check flag is true.
  private static func operationChecksPassed(
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

  fileprivate enum Constants {
    static let schemaVersion = 1
    static let platform = "ios"

    static let statusSuccess = "success"
    static let statusUnavailable = "unavailable"
    static let statusDenied = "denied"
    static let statusFailed = "failed"

    static let reasonOk = "ok"
    static let reasonSecureEnclaveUnavailable = "secure_enclave_unavailable"
    static let reasonBiometricNotEnrolled = "biometric_not_enrolled"
    static let reasonBiometricLockout = "biometric_lockout"
    static let reasonBiometricCanceled = "biometric_canceled"
    static let reasonBiometricUnsupported = "biometric_unsupported"
    static let reasonConcurrentPrompt = "concurrent_prompt"
    static let reasonPlatformError = "platform_error"

    static let algorithmP256 = "P256"
    static let algorithmAesGcm = "AES-GCM"
    static let residencySecureEnclave = "secure_enclave"
    static let residencyKeychain = "keychain"

    static let serviceName = "com.example.flutter_bloc_app.native_security_showcase"
    static let p256Account = "bloc_flutter_nsecurity_p256"
    static let aesAccount = "bloc_flutter_nsecurity_aes"
    static let sentinelAccount = "bloc_flutter_nsecurity_sentinel"
    static let biometricAccount = "bloc_flutter_nsecurity_biometric"

    static let challengeByteLength = 32
    static let sentinelByteLength = 32

    static let biometricPromptReason = "Authenticate to run the biometric-protected demo operation."

    static let demoPlaintext = Data("native-security-showcase-demo-plaintext".utf8)
    static let demoAad = Data("native-security-showcase-aad-v1".utf8)
  }
}

/// Minimal Keychain generic-password wrapper. Values stored here are
/// demo-only key material / sentinel bytes and are never surfaced to Dart.
private enum KeychainStore {
  static func upsert(account: String, data: Data, accessibility: CFString) throws {
    let baseQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: NativeSecurityShowcaseHandler.Constants.serviceName,
      kSecAttrAccount as String: account,
    ]
    let updateStatus = SecItemUpdate(baseQuery as CFDictionary, [kSecValueData as String: data] as CFDictionary)
    if updateStatus == errSecSuccess {
      return
    }
    guard updateStatus == errSecItemNotFound else {
      throw KeychainError.osStatus(updateStatus)
    }
    var addQuery = baseQuery
    addQuery[kSecValueData as String] = data
    addQuery[kSecAttrAccessible as String] = accessibility
    let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
    guard addStatus == errSecSuccess else {
      throw KeychainError.osStatus(addStatus)
    }
  }

  static func read(account: String) -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: NativeSecurityShowcaseHandler.Constants.serviceName,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess else { return nil }
    return result as? Data
  }

  @discardableResult
  static func delete(account: String) -> OSStatus {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: NativeSecurityShowcaseHandler.Constants.serviceName,
      kSecAttrAccount as String: account,
    ]
    return SecItemDelete(query as CFDictionary)
  }
}

private enum KeychainError: Error {
  case osStatus(OSStatus)
}
