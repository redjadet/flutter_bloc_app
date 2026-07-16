package com.ilkersevim.blocflutter

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.SecureRandom
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec

/**
 * Handles `com.example.flutter_bloc_app/native_security_showcase` on Android.
 *
 * All key material stays inside the Android Keystore; only status/reason
 * codes, residency labels, and byte counts cross the channel — never raw
 * keys, signatures, ciphertext, or the AES-GCM sentinel value.
 */
class NativeSecurityShowcaseHandler(
  private val activity: FragmentActivity,
) : MethodChannel.MethodCallHandler {

  private val executor: ExecutorService = Executors.newSingleThreadExecutor()
  private val mainHandler = Handler(Looper.getMainLooper())

  @Volatile
  private var isBiometricPromptActive = false

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "p256SignVerify" -> handleP256SignVerify(result)
      "aesGcmRoundTrip" -> handleAesGcmRoundTrip(result)
      "secureStorageLifecycle" -> handleSecureStorageLifecycle(result)
      "biometricProtectedOperation" -> handleBiometricProtectedOperation(result)
      else -> result.notImplemented()
    }
  }

  fun dispose() {
    isBiometricPromptActive = false
    executor.shutdown()
  }

  // region P-256 sign/verify

  private fun handleP256SignVerify(result: MethodChannel.Result) {
    if (!isKeystoreSupported()) {
      postResult(result, buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_KEYSTORE_UNAVAILABLE))
      return
    }
    executor.execute {
      val reply = try {
        val entry = ensureEcKeyEntry(P256_ALIAS, requireUserAuth = false)
        val challenge = randomBytes(CHALLENGE_BYTE_LENGTH)
        val signatureBytes = signChallenge(entry.privateKey, challenge)
        val verified = verifyChallenge(entry.certificate.publicKey, challenge, signatureBytes)
        buildReply(
          status = STATUS_SUCCESS,
          reasonCode = REASON_OK,
          algorithm = ALGORITHM_P256,
          keyResidency = RESIDENCY_ANDROID_KEYSTORE,
          hardwareBacked = isHardwareBackedPrivateKey(entry.privateKey),
          verified = verified,
          challengeByteCount = challenge.size,
        )
      } catch (error: Exception) {
        buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_KEYSTORE_UNAVAILABLE)
      }
      postResult(result, reply)
    }
  }

  // endregion

  // region AES-GCM round trip

  private fun handleAesGcmRoundTrip(result: MethodChannel.Result) {
    if (!isKeystoreSupported()) {
      postResult(result, buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_KEYSTORE_UNAVAILABLE))
      return
    }
    executor.execute {
      val reply = try {
        val secretKey = ensureAesKey(AES_ALIAS, requireUserAuth = false)
        val plaintext = DEMO_PLAINTEXT
        val aad = DEMO_AAD

        val encryptCipher = Cipher.getInstance(AES_GCM_TRANSFORMATION)
        encryptCipher.init(Cipher.ENCRYPT_MODE, secretKey)
        encryptCipher.updateAAD(aad)
        val iv = encryptCipher.iv
        val ciphertext = encryptCipher.doFinal(plaintext)

        val decryptCipher = Cipher.getInstance(AES_GCM_TRANSFORMATION)
        decryptCipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv))
        decryptCipher.updateAAD(aad)
        val decrypted = decryptCipher.doFinal(ciphertext)

        buildReply(
          status = STATUS_SUCCESS,
          reasonCode = REASON_OK,
          algorithm = ALGORITHM_AES_GCM,
          keyResidency = RESIDENCY_ANDROID_KEYSTORE,
          hardwareBacked = isHardwareBackedSecretKey(secretKey),
          verified = decrypted.contentEquals(plaintext),
          ciphertextByteCount = ciphertext.size,
          plaintextByteCount = plaintext.size,
          aadByteCount = aad.size,
        )
      } catch (error: Exception) {
        buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_KEYSTORE_UNAVAILABLE)
      }
      postResult(result, reply)
    }
  }

  // endregion

  // region Secure storage lifecycle

  private fun handleSecureStorageLifecycle(result: MethodChannel.Result) {
    if (!isKeystoreSupported()) {
      postResult(result, buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_KEYSTORE_UNAVAILABLE))
      return
    }
    executor.execute {
      val reply = try {
        val secretKey = ensureAesKey(SENTINEL_ALIAS, requireUserAuth = false)
        val sentinelValue = randomBytes(SENTINEL_BYTE_LENGTH)
        val prefs = activity.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val encryptCipher = Cipher.getInstance(AES_GCM_TRANSFORMATION)
        encryptCipher.init(Cipher.ENCRYPT_MODE, secretKey)
        val iv = encryptCipher.iv
        val ciphertext = encryptCipher.doFinal(sentinelValue)
        val blob =
          Base64.encodeToString(iv, Base64.NO_WRAP) + ":" + Base64.encodeToString(ciphertext, Base64.NO_WRAP)
        val wrote = prefs.edit().putString(SENTINEL_PREF_KEY, blob).commit()

        var readMatched = false
        val storedBlob = prefs.getString(SENTINEL_PREF_KEY, null)
        val parts = storedBlob?.split(":")
        if (parts != null && parts.size == 2) {
          val storedIv = Base64.decode(parts[0], Base64.NO_WRAP)
          val storedCiphertext = Base64.decode(parts[1], Base64.NO_WRAP)
          val decryptCipher = Cipher.getInstance(AES_GCM_TRANSFORMATION)
          decryptCipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(GCM_TAG_LENGTH_BITS, storedIv))
          val decrypted = decryptCipher.doFinal(storedCiphertext)
          readMatched = decrypted.contentEquals(sentinelValue)
        }

        val deleted = prefs.edit().remove(SENTINEL_PREF_KEY).commit() &&
          !prefs.contains(SENTINEL_PREF_KEY)

        buildReply(
          status = STATUS_SUCCESS,
          reasonCode = REASON_OK,
          algorithm = ALGORITHM_AES_GCM,
          keyResidency = RESIDENCY_ANDROID_KEYSTORE,
          hardwareBacked = isHardwareBackedSecretKey(secretKey),
          wrote = wrote,
          readMatched = readMatched,
          deleted = deleted,
        )
      } catch (error: Exception) {
        buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_KEYSTORE_UNAVAILABLE)
      }
      postResult(result, reply)
    }
  }

  // endregion

  // region Biometric-protected operation

  private fun handleBiometricProtectedOperation(result: MethodChannel.Result) {
    if (isBiometricPromptActive) {
      result.success(buildReply(status = STATUS_FAILED, reasonCode = REASON_CONCURRENT_PROMPT))
      return
    }
    if (!isKeystoreSupported()) {
      result.success(buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_BIOMETRIC_UNSUPPORTED))
      return
    }

    when (BiometricManager.from(activity).canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
      BiometricManager.BIOMETRIC_SUCCESS -> Unit
      BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> {
        result.success(buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_BIOMETRIC_NOT_ENROLLED))
        return
      }
      else -> {
        result.success(buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_BIOMETRIC_UNSUPPORTED))
        return
      }
    }

    val privateKeyEntry = try {
      ensureEcKeyEntry(BIOMETRIC_ALIAS, requireUserAuth = true)
    } catch (error: Exception) {
      result.success(buildReply(status = STATUS_UNAVAILABLE, reasonCode = REASON_KEYSTORE_UNAVAILABLE))
      return
    }

    val signature = try {
      Signature.getInstance(SIGNATURE_ALGORITHM).apply { initSign(privateKeyEntry.privateKey) }
    } catch (error: Exception) {
      result.success(buildReply(status = STATUS_FAILED, reasonCode = REASON_PLATFORM_ERROR))
      return
    }

    val challenge = randomBytes(CHALLENGE_BYTE_LENGTH)
    isBiometricPromptActive = true

    val promptInfo = BiometricPrompt.PromptInfo.Builder()
      .setTitle(BIOMETRIC_PROMPT_TITLE)
      .setSubtitle(BIOMETRIC_PROMPT_SUBTITLE)
      .setNegativeButtonText(BIOMETRIC_PROMPT_NEGATIVE_BUTTON)
      .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
      .build()

    val callback = object : BiometricPrompt.AuthenticationCallback() {
      override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
        isBiometricPromptActive = false
        val reply = try {
          val authorizedSignature = authResult.cryptoObject?.signature
            ?: throw IllegalStateException("Missing authorized signature crypto object")
          authorizedSignature.update(challenge)
          val signatureBytes = authorizedSignature.sign()
          val verified = verifyChallenge(privateKeyEntry.certificate.publicKey, challenge, signatureBytes)
          buildReply(
            status = STATUS_SUCCESS,
            reasonCode = REASON_OK,
            algorithm = ALGORITHM_P256,
            keyResidency = RESIDENCY_ANDROID_KEYSTORE,
            hardwareBacked = isHardwareBackedPrivateKey(privateKeyEntry.privateKey),
            verified = verified,
            challengeByteCount = challenge.size,
          )
        } catch (error: Exception) {
          buildReply(status = STATUS_FAILED, reasonCode = REASON_PLATFORM_ERROR)
        }
        postResult(result, reply)
      }

      override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
        isBiometricPromptActive = false
        postResult(
          result,
          buildReply(status = mapBiometricErrorStatus(errorCode), reasonCode = mapBiometricErrorReason(errorCode)),
        )
      }

      override fun onAuthenticationFailed() {
        // Single mismatched biometric read; the prompt stays open for another attempt.
      }
    }

    mainHandler.post {
      BiometricPrompt(activity, ContextCompat.getMainExecutor(activity), callback)
        .authenticate(promptInfo, BiometricPrompt.CryptoObject(signature))
    }
  }

  private fun mapBiometricErrorStatus(errorCode: Int): String = when (errorCode) {
    BiometricPrompt.ERROR_LOCKOUT, BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> STATUS_DENIED
    BiometricPrompt.ERROR_USER_CANCELED,
    BiometricPrompt.ERROR_CANCELED,
    BiometricPrompt.ERROR_NEGATIVE_BUTTON,
    -> STATUS_DENIED
    BiometricPrompt.ERROR_NO_BIOMETRICS -> STATUS_UNAVAILABLE
    BiometricPrompt.ERROR_HW_NOT_PRESENT,
    BiometricPrompt.ERROR_HW_UNAVAILABLE,
    BiometricPrompt.ERROR_UNABLE_TO_PROCESS,
    BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL,
    -> STATUS_UNAVAILABLE
    else -> STATUS_FAILED
  }

  private fun mapBiometricErrorReason(errorCode: Int): String = when (errorCode) {
    BiometricPrompt.ERROR_LOCKOUT, BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> REASON_BIOMETRIC_LOCKOUT
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

  // endregion

  // region Keystore helpers

  private fun isKeystoreSupported(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M

  private fun ensureEcKeyEntry(alias: String, requireUserAuth: Boolean): KeyStore.PrivateKeyEntry {
    val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    if (!keyStore.containsAlias(alias)) {
      val keyPairGenerator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, ANDROID_KEYSTORE)
      val builder = KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY)
        .setDigests(KeyProperties.DIGEST_SHA256)
        .setAlgorithmParameterSpec(ECGenParameterSpec(EC_CURVE_NAME))
      applyUserAuthentication(builder, requireUserAuth)
      keyPairGenerator.initialize(builder.build())
      keyPairGenerator.generateKeyPair()
    }
    return keyStore.getEntry(alias, null) as KeyStore.PrivateKeyEntry
  }

  private fun ensureAesKey(alias: String, requireUserAuth: Boolean): SecretKey {
    val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    if (!keyStore.containsAlias(alias)) {
      val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
      val builder = KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
        .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
        .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
        .setKeySize(256)
      applyUserAuthentication(builder, requireUserAuth)
      keyGenerator.init(builder.build())
      keyGenerator.generateKey()
    }
    return keyStore.getKey(alias, null) as SecretKey
  }

  private fun applyUserAuthentication(builder: KeyGenParameterSpec.Builder, requireUserAuth: Boolean) {
    if (!requireUserAuth) {
      return
    }
    builder.setUserAuthenticationRequired(true)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      builder.setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG)
    } else {
      @Suppress("DEPRECATION")
      builder.setUserAuthenticationValidityDurationSeconds(-1)
    }
  }

  private fun isHardwareBackedPrivateKey(privateKey: PrivateKey): Boolean = try {
    val factory = KeyFactory.getInstance(privateKey.algorithm, ANDROID_KEYSTORE)
    val keyInfo = factory.getKeySpec(privateKey, KeyInfo::class.java) as KeyInfo
    keyInfo.isInsideSecureHardware
  } catch (error: Exception) {
    false
  }

  private fun isHardwareBackedSecretKey(secretKey: SecretKey): Boolean = try {
    val factory = SecretKeyFactory.getInstance(secretKey.algorithm, ANDROID_KEYSTORE)
    val keyInfo = factory.getKeySpec(secretKey, KeyInfo::class.java) as KeyInfo
    keyInfo.isInsideSecureHardware
  } catch (error: Exception) {
    false
  }

  private fun signChallenge(privateKey: PrivateKey, challenge: ByteArray): ByteArray =
    Signature.getInstance(SIGNATURE_ALGORITHM).run {
      initSign(privateKey)
      update(challenge)
      sign()
    }

  private fun verifyChallenge(
    publicKey: java.security.PublicKey,
    challenge: ByteArray,
    signatureBytes: ByteArray,
  ): Boolean = Signature.getInstance(SIGNATURE_ALGORITHM).run {
    initVerify(publicKey)
    update(challenge)
    verify(signatureBytes)
  }

  private fun randomBytes(length: Int): ByteArray = ByteArray(length).also { SecureRandom().nextBytes(it) }

  // endregion

  private fun postResult(result: MethodChannel.Result, reply: Map<String, Any?>) {
    mainHandler.post { result.success(reply) }
  }

  private fun buildReply(
    status: String,
    reasonCode: String,
    hardwareBacked: Boolean? = null,
    algorithm: String? = null,
    keyResidency: String? = null,
    verified: Boolean? = null,
    challengeByteCount: Int? = null,
    ciphertextByteCount: Int? = null,
    plaintextByteCount: Int? = null,
    aadByteCount: Int? = null,
    wrote: Boolean? = null,
    readMatched: Boolean? = null,
    deleted: Boolean? = null,
  ): Map<String, Any?> {
    var resolvedStatus = status
    var resolvedReason = reasonCode
    if (status == STATUS_SUCCESS &&
      !operationChecksPassed(verified, wrote, readMatched, deleted)
    ) {
      resolvedStatus = STATUS_FAILED
      resolvedReason = REASON_PLATFORM_ERROR
    }
    return mapOf(
      "schemaVersion" to SCHEMA_VERSION,
      "status" to resolvedStatus,
      "reasonCode" to resolvedReason,
      "platform" to PLATFORM,
      "hardwareBacked" to hardwareBacked,
      "algorithm" to algorithm,
      "keyResidency" to keyResidency,
      "verified" to verified,
      "challengeByteCount" to challengeByteCount,
      "ciphertextByteCount" to ciphertextByteCount,
      "plaintextByteCount" to plaintextByteCount,
      "aadByteCount" to aadByteCount,
      "wrote" to wrote,
      "readMatched" to readMatched,
      "deleted" to deleted,
    )
  }

  /** Success only when every present check flag is true. */
  private fun operationChecksPassed(
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

  companion object {
    private const val ANDROID_KEYSTORE = "AndroidKeyStore"
    private const val P256_ALIAS = "bloc_flutter_nsecurity_p256"
    private const val AES_ALIAS = "bloc_flutter_nsecurity_aes"
    private const val SENTINEL_ALIAS = "bloc_flutter_nsecurity_sentinel"
    private const val BIOMETRIC_ALIAS = "bloc_flutter_nsecurity_biometric"
    private const val EC_CURVE_NAME = "secp256r1"
    private const val SIGNATURE_ALGORITHM = "SHA256withECDSA"
    private const val AES_GCM_TRANSFORMATION = "AES/GCM/NoPadding"
    private const val GCM_TAG_LENGTH_BITS = 128
    private const val CHALLENGE_BYTE_LENGTH = 32
    private const val SENTINEL_BYTE_LENGTH = 32
    private const val PREFS_NAME = "bloc_flutter_nsecurity_prefs"
    private const val SENTINEL_PREF_KEY = "sentinel_blob"
    private const val SCHEMA_VERSION = 1
    private const val PLATFORM = "android"

    private const val STATUS_SUCCESS = "success"
    private const val STATUS_UNAVAILABLE = "unavailable"
    private const val STATUS_DENIED = "denied"
    private const val STATUS_FAILED = "failed"

    private const val REASON_OK = "ok"
    private const val REASON_KEYSTORE_UNAVAILABLE = "keystore_unavailable"
    private const val REASON_BIOMETRIC_NOT_ENROLLED = "biometric_not_enrolled"
    private const val REASON_BIOMETRIC_LOCKOUT = "biometric_lockout"
    private const val REASON_BIOMETRIC_CANCELED = "biometric_canceled"
    private const val REASON_BIOMETRIC_UNSUPPORTED = "biometric_unsupported"
    private const val REASON_CONCURRENT_PROMPT = "concurrent_prompt"
    private const val REASON_PLATFORM_ERROR = "platform_error"

    private const val ALGORITHM_P256 = "P256"
    private const val ALGORITHM_AES_GCM = "AES-GCM"
    private const val RESIDENCY_ANDROID_KEYSTORE = "android_keystore"

    private const val BIOMETRIC_PROMPT_TITLE = "Native security showcase"
    private const val BIOMETRIC_PROMPT_SUBTITLE = "Authenticate to run the biometric-protected demo operation."
    private const val BIOMETRIC_PROMPT_NEGATIVE_BUTTON = "Cancel"

    private val DEMO_PLAINTEXT = "native-security-showcase-demo-plaintext".toByteArray(Charsets.UTF_8)
    private val DEMO_AAD = "native-security-showcase-aad-v1".toByteArray(Charsets.UTF_8)
  }
}
