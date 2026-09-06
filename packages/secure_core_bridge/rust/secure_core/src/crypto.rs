//! AES-256-GCM seal/open using the provider seam.

use std::sync::OnceLock;

use crate::envelope::{
    build_envelope, parse_envelope, validate_plaintext_len, DEMO_AAD, NONCE_LEN,
};
use crate::error::SecureCoreStatus;
use crate::provider::{KeyOperationsProvider, ProcessEphemeralKeyProvider};

static PROVIDER: OnceLock<ProcessEphemeralKeyProvider> = OnceLock::new();

fn provider() -> Result<&'static ProcessEphemeralKeyProvider, SecureCoreStatus> {
    if let Some(existing) = PROVIDER.get() {
        return Ok(existing);
    }
    let created = ProcessEphemeralKeyProvider::new_random()?;
    let _ = PROVIDER.set(created);
    PROVIDER.get().ok_or(SecureCoreStatus::Internal)
}

pub fn encrypt(plaintext: &[u8]) -> Result<Vec<u8>, SecureCoreStatus> {
    encrypt_with_provider(plaintext, provider()?, |nonce| {
        getrandom::fill(nonce).map_err(|_| SecureCoreStatus::Unavailable)
    })
}

fn encrypt_with_provider(
    plaintext: &[u8],
    provider: &impl KeyOperationsProvider,
    fill_nonce: impl FnOnce(&mut [u8]) -> Result<(), SecureCoreStatus>,
) -> Result<Vec<u8>, SecureCoreStatus> {
    validate_plaintext_len(plaintext.len())?;
    let mut nonce = [0u8; NONCE_LEN];
    fill_nonce(&mut nonce)?;
    let ciphertext_and_tag = provider.seal(&nonce, plaintext, DEMO_AAD)?;
    Ok(build_envelope(&nonce, &ciphertext_and_tag))
}

pub fn decrypt(envelope: &[u8]) -> Result<Vec<u8>, SecureCoreStatus> {
    decrypt_with_provider(envelope, provider()?)
}

fn decrypt_with_provider(
    envelope: &[u8],
    provider: &impl KeyOperationsProvider,
) -> Result<Vec<u8>, SecureCoreStatus> {
    let parsed = parse_envelope(envelope)?;
    let mut nonce = [0u8; NONCE_LEN];
    nonce.copy_from_slice(parsed.nonce);
    provider.open(&nonce, parsed.ciphertext_and_tag, DEMO_AAD)
}

/// Runtime self-test: encrypt then decrypt a fixed UTF-8 string.
pub fn health_check() -> Result<(), SecureCoreStatus> {
    const PROBE: &[u8] = b"secure_core_health_v1";
    let envelope = encrypt(PROBE)?;
    let recovered = decrypt(&envelope)?;
    if recovered.as_slice() == PROBE {
        Ok(())
    } else {
        Err(SecureCoreStatus::Internal)
    }
}

pub const VERSION: &str = "0.1.0";

#[cfg(test)]
mod tests {
    use super::*;
    use crate::envelope::{FORMAT_VERSION, HEADER_LEN, MAX_PLAINTEXT_LEN, TAG_LEN};

    #[test]
    fn round_trip_preserves_utf8() {
        let plaintext = "merhaba 🔐 secure core".as_bytes();
        let envelope = encrypt(plaintext).expect("encrypt");
        let recovered = decrypt(&envelope).expect("decrypt");
        assert_eq!(recovered, plaintext);
    }

    #[test]
    fn rejects_empty_and_oversized() {
        assert_eq!(encrypt(b""), Err(SecureCoreStatus::InvalidInput));
        let oversized = vec![b'a'; MAX_PLAINTEXT_LEN + 1];
        assert_eq!(encrypt(&oversized), Err(SecureCoreStatus::InvalidInput));
    }

    #[test]
    fn bit_flip_fails_authentication() {
        let envelope = encrypt(b"payload").expect("encrypt");
        let mut corrupted = envelope.clone();
        let flip_at = HEADER_LEN;
        corrupted[flip_at] ^= 0x01;
        assert_eq!(
            decrypt(&corrupted),
            Err(SecureCoreStatus::AuthenticationFailed)
        );
        let mut tag_flip = envelope.clone();
        let last = tag_flip.len() - 1;
        tag_flip[last] ^= 0x01;
        assert_eq!(
            decrypt(&tag_flip),
            Err(SecureCoreStatus::AuthenticationFailed)
        );
        let mut nonce_flip = envelope;
        nonce_flip[1] ^= 0x01;
        assert_eq!(
            decrypt(&nonce_flip),
            Err(SecureCoreStatus::AuthenticationFailed)
        );
    }

    #[test]
    fn truncated_envelope_rejected() {
        let envelope = encrypt(b"abc").expect("encrypt");
        let truncated = &envelope[..HEADER_LEN + TAG_LEN - 1];
        assert_eq!(
            decrypt(truncated),
            Err(SecureCoreStatus::MalformedCiphertext)
        );
    }

    #[test]
    fn unsupported_version_rejected() {
        let mut envelope = encrypt(b"abc").expect("encrypt");
        envelope[0] = FORMAT_VERSION + 1;
        assert_eq!(
            decrypt(&envelope),
            Err(SecureCoreStatus::UnsupportedVersion)
        );
    }

    #[test]
    fn health_check_passes() {
        health_check().expect("health");
    }

    #[test]
    fn version_non_empty() {
        assert!(!VERSION.is_empty());
    }

    #[test]
    fn nonce_source_failure_is_unavailable() {
        let provider = ProcessEphemeralKeyProvider::from_key([7u8; 32]);
        let result = encrypt_with_provider(b"payload", &provider, |_| {
            Err(SecureCoreStatus::Unavailable)
        });
        assert_eq!(result, Err(SecureCoreStatus::Unavailable));
    }
}
