//! Demo-only secure messaging core (AES-256-GCM) exposed via a C ABI.

mod abi;
mod crypto;
mod envelope;
mod error;
mod provider;

pub use abi::{
    secure_core_buffer_free, secure_core_decrypt, secure_core_encrypt, secure_core_health_check,
    secure_core_version, SecureCoreBuffer,
};
pub use error::SecureCoreStatus;
