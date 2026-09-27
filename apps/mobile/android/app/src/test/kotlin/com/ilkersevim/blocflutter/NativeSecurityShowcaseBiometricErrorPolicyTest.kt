package com.ilkersevim.blocflutter

import androidx.biometric.BiometricPrompt
import org.junit.Assert.assertEquals
import org.junit.Test

class NativeSecurityShowcaseBiometricErrorPolicyTest {
  @Test
  fun mapOutcome_userCancelIsDeniedCanceled() {
    val (status, reason) =
      NativeSecurityShowcaseBiometricErrorPolicy.mapOutcome(
        BiometricPrompt.ERROR_USER_CANCELED,
      )
    assertEquals(NativeSecurityShowcaseBiometricErrorPolicy.STATUS_DENIED, status)
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.REASON_BIOMETRIC_CANCELED,
      reason,
    )
  }

  @Test
  fun mapOutcome_negativeButtonIsDeniedCanceled() {
    val (status, reason) =
      NativeSecurityShowcaseBiometricErrorPolicy.mapOutcome(
        BiometricPrompt.ERROR_NEGATIVE_BUTTON,
      )
    assertEquals(NativeSecurityShowcaseBiometricErrorPolicy.STATUS_DENIED, status)
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.REASON_BIOMETRIC_CANCELED,
      reason,
    )
  }

  @Test
  fun mapOutcome_lockoutIsDeniedLockout() {
    val (status, reason) =
      NativeSecurityShowcaseBiometricErrorPolicy.mapOutcome(
        BiometricPrompt.ERROR_LOCKOUT,
      )
    assertEquals(NativeSecurityShowcaseBiometricErrorPolicy.STATUS_DENIED, status)
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.REASON_BIOMETRIC_LOCKOUT,
      reason,
    )
  }

  @Test
  fun mapOutcome_permanentLockoutIsDeniedLockout() {
    val (status, reason) =
      NativeSecurityShowcaseBiometricErrorPolicy.mapOutcome(
        BiometricPrompt.ERROR_LOCKOUT_PERMANENT,
      )
    assertEquals(NativeSecurityShowcaseBiometricErrorPolicy.STATUS_DENIED, status)
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.REASON_BIOMETRIC_LOCKOUT,
      reason,
    )
  }

  @Test
  fun mapOutcome_noBiometricsIsUnavailableNotEnrolled() {
    val (status, reason) =
      NativeSecurityShowcaseBiometricErrorPolicy.mapOutcome(
        BiometricPrompt.ERROR_NO_BIOMETRICS,
      )
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.STATUS_UNAVAILABLE,
      status,
    )
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.REASON_BIOMETRIC_NOT_ENROLLED,
      reason,
    )
  }

  @Test
  fun mapOutcome_hwUnavailableIsUnavailableUnsupported() {
    val (status, reason) =
      NativeSecurityShowcaseBiometricErrorPolicy.mapOutcome(
        BiometricPrompt.ERROR_HW_UNAVAILABLE,
      )
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.STATUS_UNAVAILABLE,
      status,
    )
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.REASON_BIOMETRIC_UNSUPPORTED,
      reason,
    )
  }

  @Test
  fun mapOutcome_unknownCodeIsFailedPlatformError() {
    val (status, reason) =
      NativeSecurityShowcaseBiometricErrorPolicy.mapOutcome(errorCode = 9999)
    assertEquals(NativeSecurityShowcaseBiometricErrorPolicy.STATUS_FAILED, status)
    assertEquals(
      NativeSecurityShowcaseBiometricErrorPolicy.REASON_PLATFORM_ERROR,
      reason,
    )
  }
}
