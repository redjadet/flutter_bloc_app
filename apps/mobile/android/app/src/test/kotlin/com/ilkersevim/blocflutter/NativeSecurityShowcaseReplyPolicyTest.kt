package com.ilkersevim.blocflutter

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NativeSecurityShowcaseReplyPolicyTest {
  @Test
  fun operationChecksPassed_nullFlagsAreOk() {
    assertTrue(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified = null,
        wrote = null,
        readMatched = null,
        deleted = null,
      ),
    )
  }

  @Test
  fun operationChecksPassed_trueFlagsAreOk() {
    assertTrue(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified = true,
        wrote = true,
        readMatched = true,
        deleted = true,
      ),
    )
  }

  @Test
  fun operationChecksPassed_rejectsFalseVerified() {
    assertFalse(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified = false,
        wrote = null,
        readMatched = null,
        deleted = null,
      ),
    )
  }

  @Test
  fun operationChecksPassed_rejectsFalseStorageFlags() {
    assertFalse(
      NativeSecurityShowcaseReplyPolicy.operationChecksPassed(
        verified = null,
        wrote = true,
        readMatched = false,
        deleted = true,
      ),
    )
  }

  @Test
  fun coerceOutcome_downgradesSuccessWhenVerifiedFalse() {
    val (status, reason) =
      NativeSecurityShowcaseReplyPolicy.coerceOutcome(
        status = NativeSecurityShowcaseReplyPolicy.STATUS_SUCCESS,
        reasonCode = "ok",
        verified = false,
      )
    assertEquals(NativeSecurityShowcaseReplyPolicy.STATUS_FAILED, status)
    assertEquals(NativeSecurityShowcaseReplyPolicy.REASON_PLATFORM_ERROR, reason)
  }

  @Test
  fun coerceOutcome_keepsSuccessWhenChecksPass() {
    val (status, reason) =
      NativeSecurityShowcaseReplyPolicy.coerceOutcome(
        status = NativeSecurityShowcaseReplyPolicy.STATUS_SUCCESS,
        reasonCode = "ok",
        verified = true,
        wrote = true,
        readMatched = true,
        deleted = true,
      )
    assertEquals(NativeSecurityShowcaseReplyPolicy.STATUS_SUCCESS, status)
    assertEquals("ok", reason)
  }

  @Test
  fun coerceOutcome_leavesNonSuccessUnchanged() {
    val (status, reason) =
      NativeSecurityShowcaseReplyPolicy.coerceOutcome(
        status = "denied",
        reasonCode = "biometric_canceled",
        verified = false,
      )
    assertEquals("denied", status)
    assertEquals("biometric_canceled", reason)
  }
}
