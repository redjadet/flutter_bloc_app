//! C ABI adapter. Panic-safe; never returns Rust panic across FFI.

use std::panic::{catch_unwind, AssertUnwindSafe};
use std::ptr;
use std::slice;
use zeroize::Zeroize;

use crate::crypto::{self, VERSION};
use crate::envelope::{MAX_ENVELOPE_LEN, MAX_PLAINTEXT_LEN};
use crate::error::SecureCoreStatus;

#[repr(C)]
pub struct SecureCoreBuffer {
    pub data: *mut u8,
    pub len: usize,
    pub status: i32,
}

impl SecureCoreBuffer {
    fn from_status(status: SecureCoreStatus) -> Self {
        Self {
            data: ptr::null_mut(),
            len: 0,
            status: status.into(),
        }
    }

    fn from_bytes(bytes: Vec<u8>) -> Self {
        let mut boxed = bytes.into_boxed_slice();
        let len = boxed.len();
        let data = boxed.as_mut_ptr();
        std::mem::forget(boxed);
        Self {
            data,
            len,
            status: SecureCoreStatus::Ok.into(),
        }
    }
}

fn run_bytes(op: impl FnOnce() -> Result<Vec<u8>, SecureCoreStatus>) -> SecureCoreBuffer {
    match catch_unwind(AssertUnwindSafe(op)) {
        Ok(Ok(bytes)) => SecureCoreBuffer::from_bytes(bytes),
        Ok(Err(status)) => SecureCoreBuffer::from_status(status),
        Err(_) => SecureCoreBuffer::from_status(SecureCoreStatus::Internal),
    }
}

fn run_unit(op: impl FnOnce() -> Result<(), SecureCoreStatus>) -> i32 {
    match catch_unwind(AssertUnwindSafe(op)) {
        Ok(Ok(())) => SecureCoreStatus::Ok.into(),
        Ok(Err(status)) => status.into(),
        Err(_) => SecureCoreStatus::Internal.into(),
    }
}

fn read_input<'a>(
    ptr: *const u8,
    len: usize,
    max_len: usize,
    length_error: SecureCoreStatus,
) -> Result<&'a [u8], SecureCoreStatus> {
    if ptr.is_null() {
        return Err(SecureCoreStatus::InvalidInput);
    }
    if len == 0 || len > max_len {
        return Err(length_error);
    }
    // SAFETY: caller guarantees ptr is valid for len bytes when non-null.
    Ok(unsafe { slice::from_raw_parts(ptr, len) })
}

#[no_mangle]
pub extern "C" fn secure_core_encrypt(
    plaintext: *const u8,
    plaintext_len: usize,
) -> SecureCoreBuffer {
    run_bytes(|| {
        let input = read_input(
            plaintext,
            plaintext_len,
            MAX_PLAINTEXT_LEN,
            SecureCoreStatus::InvalidInput,
        )?;
        crypto::encrypt(input)
    })
}

#[no_mangle]
pub extern "C" fn secure_core_decrypt(
    ciphertext: *const u8,
    ciphertext_len: usize,
) -> SecureCoreBuffer {
    run_bytes(|| {
        let input = read_input(
            ciphertext,
            ciphertext_len,
            MAX_ENVELOPE_LEN,
            SecureCoreStatus::MalformedCiphertext,
        )?;
        crypto::decrypt(input)
    })
}

#[no_mangle]
pub extern "C" fn secure_core_health_check() -> i32 {
    run_unit(crypto::health_check)
}

#[no_mangle]
pub extern "C" fn secure_core_version() -> SecureCoreBuffer {
    run_bytes(|| Ok(VERSION.as_bytes().to_vec()))
}

#[no_mangle]
pub extern "C" fn secure_core_buffer_free(buffer: SecureCoreBuffer) {
    let _ = catch_unwind(AssertUnwindSafe(|| {
        if buffer.data.is_null() || buffer.len == 0 {
            return;
        }
        // SAFETY: buffer was allocated by from_bytes and ownership returns here.
        unsafe {
            let mut boxed = Box::from_raw(ptr::slice_from_raw_parts_mut(buffer.data, buffer.len));
            boxed.as_mut().zeroize();
        }
    }));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn null_pointer_rejected() {
        let result = secure_core_encrypt(ptr::null(), 4);
        assert_eq!(result.status, SecureCoreStatus::InvalidInput as i32);
        secure_core_buffer_free(result);
    }

    #[test]
    fn abi_round_trip_and_free() {
        let plaintext = b"abi-round-trip";
        let encrypted = secure_core_encrypt(plaintext.as_ptr(), plaintext.len());
        assert_eq!(encrypted.status, SecureCoreStatus::Ok as i32);
        assert!(!encrypted.data.is_null());
        let decrypted = secure_core_decrypt(encrypted.data, encrypted.len);
        assert_eq!(decrypted.status, SecureCoreStatus::Ok as i32);
        let recovered = unsafe { slice::from_raw_parts(decrypted.data, decrypted.len) }.to_vec();
        assert_eq!(recovered, plaintext);
        secure_core_buffer_free(encrypted);
        secure_core_buffer_free(decrypted);
    }

    #[test]
    fn health_and_version_ok() {
        assert_eq!(secure_core_health_check(), SecureCoreStatus::Ok as i32);
        let version = secure_core_version();
        assert_eq!(version.status, SecureCoreStatus::Ok as i32);
        assert!(version.len > 0);
        secure_core_buffer_free(version);
    }

    #[test]
    fn oversized_lengths_are_rejected_before_reading_memory() {
        let byte = 1u8;
        let encrypted = secure_core_encrypt(&byte, MAX_PLAINTEXT_LEN + 1);
        assert_eq!(encrypted.status, SecureCoreStatus::InvalidInput as i32);
        let decrypted = secure_core_decrypt(&byte, MAX_ENVELOPE_LEN + 1);
        assert_eq!(
            decrypted.status,
            SecureCoreStatus::MalformedCiphertext as i32
        );
    }

    #[test]
    fn panic_is_mapped_to_internal_status() {
        assert_eq!(
            run_unit(|| panic!("test panic")),
            SecureCoreStatus::Internal as i32
        );
    }
}
