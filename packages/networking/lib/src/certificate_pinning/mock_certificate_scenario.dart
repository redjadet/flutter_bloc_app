/// Deterministic mock pinning outcomes for demos and tests.
enum MockCertificateScenario {
  validPrimaryPin,
  validBackupPin,
  invalidPin,
  missingPin,
  unsupportedHost,
  expiredCertificate,
  malformedCertificate,
  timeout,
  networkUnavailable,
  allPinsRejected,
}
