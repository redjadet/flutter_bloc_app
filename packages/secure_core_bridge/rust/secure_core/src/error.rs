//! Structured status codes mirrored by `include/secure_core.h`.

#[repr(i32)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SecureCoreStatus {
    Ok = 0,
    InvalidInput = 1,
    MalformedCiphertext = 2,
    AuthenticationFailed = 3,
    UnsupportedVersion = 4,
    Unavailable = 5,
    Internal = 6,
}

impl From<SecureCoreStatus> for i32 {
    fn from(value: SecureCoreStatus) -> Self {
        value as i32
    }
}
