/// Runtime certificate pinning mode.
///
/// Default for all flavors is [disabled]. Enable explicitly via configuration.
enum CertificatePinningMode {
  /// No pin checks; Dio adapter not applied.
  disabled,

  /// Use [MockCertificatePinValidator] with success-oriented default scenario.
  mockSuccess,

  /// Use [MockCertificatePinValidator] with failure-oriented default scenario.
  mockFailure,

  /// Use [RealCertificatePinValidator] + Dio leaf-cert checks.
  real,
}
