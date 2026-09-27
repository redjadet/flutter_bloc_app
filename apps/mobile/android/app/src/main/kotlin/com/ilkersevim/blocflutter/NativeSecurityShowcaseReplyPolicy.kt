package com.ilkersevim.blocflutter

/**
 * Pure reply-policy helpers for the native security MethodChannel.
 *
 * Host handlers must not report `success` when any present check flag is
 * false — that would let a buggy crypto path paint "OK" in the Dart UI.
 * Extracted so Android unit tests can cover the contract without Keystore /
 * biometric hardware.
 */
internal object NativeSecurityShowcaseReplyPolicy {
  const val STATUS_SUCCESS = "success"
  const val STATUS_FAILED = "failed"
  const val REASON_PLATFORM_ERROR = "platform_error"

  /** Success only when every present check flag is true (null = not applicable). */
  fun operationChecksPassed(
    verified: Boolean?,
    wrote: Boolean?,
    readMatched: Boolean?,
    deleted: Boolean?,
  ): Boolean {
    if (verified == false) {
      return false
    }
    if (wrote == false || readMatched == false || deleted == false) {
      return false
    }
    return true
  }

  /**
   * Downgrades a claimed `success` to `failed` / `platform_error` when any
   * present check flag is false. Non-success statuses pass through unchanged.
   */
  fun coerceOutcome(
    status: String,
    reasonCode: String,
    verified: Boolean? = null,
    wrote: Boolean? = null,
    readMatched: Boolean? = null,
    deleted: Boolean? = null,
  ): Pair<String, String> {
    if (status == STATUS_SUCCESS &&
      !operationChecksPassed(verified, wrote, readMatched, deleted)
    ) {
      return STATUS_FAILED to REASON_PLATFORM_ERROR
    }
    return status to reasonCode
  }
}
