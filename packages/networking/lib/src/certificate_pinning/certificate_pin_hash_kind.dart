/// Which material is hashed for `sha256/...` pins.
enum CertificatePinHashKind {
  /// SHA-256 over SubjectPublicKeyInfo DER (preferred; survives leaf renewal).
  spki,

  /// SHA-256 over the full leaf certificate DER (legacy / migration).
  leafCertificate,
}
