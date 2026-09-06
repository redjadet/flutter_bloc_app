//! Versioned AES-GCM envelope codec.
//!
//! Layout: `format-version (1) | nonce (12) | ciphertext | tag (16)`.

use crate::error::SecureCoreStatus;

pub const FORMAT_VERSION: u8 = 1;
pub const NONCE_LEN: usize = 12;
pub const TAG_LEN: usize = 16;
pub const HEADER_LEN: usize = 1 + NONCE_LEN;
pub const MIN_ENVELOPE_LEN: usize = HEADER_LEN + TAG_LEN;
pub const MAX_PLAINTEXT_LEN: usize = 64 * 1024;
pub const MAX_ENVELOPE_LEN: usize = HEADER_LEN + MAX_PLAINTEXT_LEN + TAG_LEN;
/// Fixed AAD identifying this demo envelope (not secret).
pub const DEMO_AAD: &[u8] = b"secure_core_demo_v1";

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ParsedEnvelope<'a> {
    pub nonce: &'a [u8],
    pub ciphertext_and_tag: &'a [u8],
}

pub fn validate_plaintext_len(len: usize) -> Result<(), SecureCoreStatus> {
    if len == 0 || len > MAX_PLAINTEXT_LEN {
        return Err(SecureCoreStatus::InvalidInput);
    }
    Ok(())
}

pub fn build_envelope(nonce: &[u8; NONCE_LEN], ciphertext_and_tag: &[u8]) -> Vec<u8> {
    let mut out = Vec::with_capacity(HEADER_LEN + ciphertext_and_tag.len());
    out.push(FORMAT_VERSION);
    out.extend_from_slice(nonce);
    out.extend_from_slice(ciphertext_and_tag);
    out
}

pub fn parse_envelope(bytes: &[u8]) -> Result<ParsedEnvelope<'_>, SecureCoreStatus> {
    if bytes.len() < MIN_ENVELOPE_LEN || bytes.len() > MAX_ENVELOPE_LEN {
        return Err(SecureCoreStatus::MalformedCiphertext);
    }
    let version = bytes[0];
    if version != FORMAT_VERSION {
        return Err(SecureCoreStatus::UnsupportedVersion);
    }
    let nonce = &bytes[1..HEADER_LEN];
    let ciphertext_and_tag = &bytes[HEADER_LEN..];
    if ciphertext_and_tag.len() < TAG_LEN {
        return Err(SecureCoreStatus::MalformedCiphertext);
    }
    Ok(ParsedEnvelope {
        nonce,
        ciphertext_and_tag,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_empty_and_oversized_plaintext() {
        assert_eq!(
            validate_plaintext_len(0),
            Err(SecureCoreStatus::InvalidInput)
        );
        assert_eq!(
            validate_plaintext_len(MAX_PLAINTEXT_LEN + 1),
            Err(SecureCoreStatus::InvalidInput)
        );
        assert!(validate_plaintext_len(1).is_ok());
        assert!(validate_plaintext_len(MAX_PLAINTEXT_LEN).is_ok());
    }

    #[test]
    fn rejects_short_and_bad_version_envelopes() {
        assert_eq!(
            parse_envelope(&[0u8; MIN_ENVELOPE_LEN - 1]),
            Err(SecureCoreStatus::MalformedCiphertext)
        );
        let mut bad = vec![0u8; MIN_ENVELOPE_LEN];
        bad[0] = 99;
        assert_eq!(
            parse_envelope(&bad),
            Err(SecureCoreStatus::UnsupportedVersion)
        );
        assert_eq!(
            parse_envelope(&vec![0u8; MAX_ENVELOPE_LEN + 1]),
            Err(SecureCoreStatus::MalformedCiphertext)
        );
    }
}
