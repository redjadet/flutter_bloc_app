#ifndef NATIVE_SHOWCASE_H_
#define NATIVE_SHOWCASE_H_

#include <stdint.h>

#if defined(_WIN32)
#define NATIVE_SHOWCASE_EXPORT __declspec(dllexport)
#elif defined(__APPLE__)
#define NATIVE_SHOWCASE_EXPORT __attribute__((visibility("default"), used))
#else
#define NATIVE_SHOWCASE_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

NATIVE_SHOWCASE_EXPORT const char* native_showcase_greeting(void);

NATIVE_SHOWCASE_EXPORT int32_t native_showcase_add(
    int32_t left,
    int32_t right);

#ifdef __cplusplus
}
#endif

#endif  // NATIVE_SHOWCASE_H_
