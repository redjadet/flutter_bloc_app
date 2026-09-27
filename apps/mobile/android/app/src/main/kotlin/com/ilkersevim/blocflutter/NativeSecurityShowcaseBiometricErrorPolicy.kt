package com.ilkersevim.blocflutter

import androidx.biometric.BiometricPrompt

/**
 * Pure biometric-prompt error → status/reason mapping for the native security
 * MethodChannel.
 *
 * Extracted so Android unit tests can cover denied vs unavailable vs failed
 * without launching a biometric prompt or Keystore hardware.
 */
internal object NativeSecurityShowcaseBiometricErrorPolicy {
  const val STATUS_DENIED = "denied"
  const val STATUS_UNAVAILABLE = "unavailable"
  const val STATUS_FAILED = "failed"

  const val REASON_BIOMETRIC_LOCKOUT = "biometric_lockout"
  const val REASON_BIOMETRIC_CANCELED = "biometric_canceled"
  const val REASON_BIOMETRIC_NOT_ENROLLED = "biometric_not_enrolled"
  const val REASON_BIOMETRIC_UNSUPPORTED = "biometric_unsupported"
  const val REASON_PLATFORM_ERROR = "platform_error"

  fun mapStatus(errorCode: Int): String = when (errorCode) {
    BiometricPrompt.ERROR_LOCKOUT,
    BiometricPrompt.ERROR_LOCKOUT_PERMANENT,
    BiometricPrompt.ERROR_USER_CANCELED,
    BiometricPrompt.ERROR_CANCELED,
    BiometricPrompt.ERROR_NEGATIVE_BUTTON,
    -> STATUS_DENIED
    BiometricPrompt.ERROR_NO_BIOMETRICS,
    BiometricPrompt.ERROR_HW_NOT_PRESENT,
    BiometricPrompt.ERROR_HW_UNAVAILABLE,
    BiometricPrompt.ERROR_UNABLE_TO_PROCESS,
    BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL,
    -> STATUS_UNAVAILABLE
    else -> STATUS_FAILED
  }

  fun mapReason(errorCode: Int): String = when (errorCode) {
    BiometricPrompt.ERROR_LOCKOUT,
    BiometricPrompt.ERROR_LOCKOUT_PERMANENT,
    -> REASON_BIOMETRIC_LOCKOUT
    BiometricPrompt.ERROR_USER_CANCELED,
    BiometricPrompt.ERROR_CANCELED,
    BiometricPrompt.ERROR_NEGATIVE_BUTTON,
    -> REASON_BIOMETRIC_CANCELED
    BiometricPrompt.ERROR_NO_BIOMETRICS -> REASON_BIOMETRIC_NOT_ENROLLED
    BiometricPrompt.ERROR_HW_NOT_PRESENT,
    BiometricPrompt.ERROR_HW_UNAVAILABLE,
    BiometricPrompt.ERROR_UNABLE_TO_PROCESS,
    BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL,
    -> REASON_BIOMETRIC_UNSUPPORTED
    else -> REASON_PLATFORM_ERROR
  }

  /** Combined mapping used by the MethodChannel biometric callback. */
  fun mapOutcome(errorCode: Int): Pair<String, String> =
    mapStatus(errorCode) to mapReason(errorCode)
}
