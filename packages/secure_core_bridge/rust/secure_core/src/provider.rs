//! Key operations seam. Demo provider keeps one process-ephemeral AES-256 key.

use aes_gcm::aead::{Aead, Payload};
use aes_gcm::{Aes256Gcm, KeyInit};
use zeroize::{Zeroize, ZeroizeOnDrop};

use crate::error::SecureCoreStatus;

pub const KEY_LEN: usize = 32;

pub trait KeyOperationsProvider: Send + Sync {
    fn seal(
        &self,
        nonce: &[u8; 12],
        plaintext: &[u8],
        aad: &[u8],
    ) -> Result<Vec<u8>, SecureCoreStatus>;

    fn open(
        &self,
        nonce: &[u8; 12],
        ciphertext_and_tag: &[u8],
        aad: &[u8],
    ) -> Result<Vec<u8>, SecureCoreStatus>;
}

#[derive(Zeroize, ZeroizeOnDrop)]
pub struct ProcessEphemeralKeyProvider {
    key: [u8; KEY_LEN],
}

impl ProcessEphemeralKeyProvider {
    pub fn new_random() -> Result<Self, SecureCoreStatus> {
        Self::new_with_random_source(|key| {
            getrandom::fill(key).map_err(|_| SecureCoreStatus::Unavailable)
        })
    }

    fn new_with_random_source(
        fill: impl FnOnce(&mut [u8]) -> Result<(), SecureCoreStatus>,
    ) -> Result<Self, SecureCoreStatus> {
        let mut key = [0u8; KEY_LEN];
        fill(&mut key)?;
        Ok(Self { key })
    }

    #[cfg(test)]
    pub fn from_key(key: [u8; KEY_LEN]) -> Self {
        Self { key }
    }

    fn cipher(&self) -> Result<Aes256Gcm, SecureCoreStatus> {
        Aes256Gcm::new_from_slice(&self.key).map_err(|_| SecureCoreStatus::Internal)
    }
}

impl KeyOperationsProvider for ProcessEphemeralKeyProvider {
    fn seal(
        &self,
        nonce: &[u8; 12],
        plaintext: &[u8],
        aad: &[u8],
    ) -> Result<Vec<u8>, SecureCoreStatus> {
        self.cipher()?
            .encrypt(
                nonce.into(),
                Payload {
                    msg: plaintext,
                    aad,
                },
            )
            .map_err(|_| SecureCoreStatus::Internal)
    }

    fn open(
        &self,
        nonce: &[u8; 12],
        ciphertext_and_tag: &[u8],
        aad: &[u8],
    ) -> Result<Vec<u8>, SecureCoreStatus> {
        self.cipher()?
            .decrypt(
                nonce.into(),
                Payload {
                    msg: ciphertext_and_tag,
                    aad,
                },
            )
            .map_err(|_| SecureCoreStatus::AuthenticationFailed)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn random_source_failure_is_unavailable() {
        let result = ProcessEphemeralKeyProvider::new_with_random_source(|_| {
            Err(SecureCoreStatus::Unavailable)
        });
        assert!(matches!(result, Err(SecureCoreStatus::Unavailable)));
    }
}
