#ifndef SECURE_CORE_H_
#define SECURE_CORE_H_

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum SecureCoreStatus {
  SECURE_CORE_STATUS_OK = 0,
  SECURE_CORE_STATUS_INVALID_INPUT = 1,
  SECURE_CORE_STATUS_MALFORMED_CIPHERTEXT = 2,
  SECURE_CORE_STATUS_AUTHENTICATION_FAILED = 3,
  SECURE_CORE_STATUS_UNSUPPORTED_VERSION = 4,
  SECURE_CORE_STATUS_UNAVAILABLE = 5,
  SECURE_CORE_STATUS_INTERNAL = 6
};

typedef struct SecureCoreBuffer {
  uint8_t *data;
  size_t len;
  int32_t status;
} SecureCoreBuffer;

SecureCoreBuffer secure_core_encrypt(const uint8_t *plaintext, size_t plaintext_len);

SecureCoreBuffer secure_core_decrypt(const uint8_t *ciphertext, size_t ciphertext_len);

int32_t secure_core_health_check(void);

SecureCoreBuffer secure_core_version(void);

void secure_core_buffer_free(SecureCoreBuffer buffer);

#ifdef __cplusplus
}
#endif

#endif /* SECURE_CORE_H_ */
