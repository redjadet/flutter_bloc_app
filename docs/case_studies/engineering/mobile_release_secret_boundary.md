# Mobile release secret boundary

Security semantics remain owned by
[Security and secrets](../../security_and_secrets.md). This case study explains
the decision and its evidence without creating another security policy.

## Context

A release pipeline can turn one convenience environment variable into a
recoverable provider credential across every installed artifact. Anything
forwarded through Flutter `--dart-define` is client-visible. A wrong boundary
creates credential exposure and unauthorized backend cost beyond one feature.

## Ownership

Own configuration classification and every release/profile forwarding
entrypoint. In an interview, name only the config, guard, test, review, or
backend coordination personally owned; do not claim the whole delivery system.

## Options

1. Ship provider credentials directly through client defines.
2. Conceal them with `.env`, Remote Config, secure storage, or obfuscation.
3. Keep authority server-side and ship only public client configuration.

## Decision

Choose option 3. Release/profile helpers allow approved public configuration
and reject provider credentials or shared backend secrets. The trusted backend
owns reusable credentials and authorization.

## Rejected approach

Reject client-side concealment. Packaging or storage mechanisms can change
exposure cost; they cannot turn an APK/IPA into a trusted secret boundary.

## Trade-off

Release/profile builds fail closed, and direct provider-key paths cannot ship.
Backend deployment, token lifecycle, and availability become explicit
operational responsibilities. Debug-only legacy paths do not prove release
safety.

## Proof and outcome

| Evidence status | Boundary |
| --- | --- |
| Implemented behavior | Release/profile helpers apply a denylist while preserving approved public client configuration. This is repository behavior, not proof of deployment. |
| Repository proof | [`flutter_dart_defines_from_env.sh`](../../../tool/flutter_dart_defines_from_env.sh), [`Fastfile`](../../../fastlane/Fastfile), and [`flutter_dart_defines_from_env_test.py`](../../../tool/flutter_dart_defines_from_env_test.py) |
| Historical evidence | [Mobile release secret boundary](../../changes/2026-08-07_mobile_release_secret_boundary.md) |
| Planned / deferred | Backend secret deployment, rotation, production authorization, and production access remain outside this client repository's proof. |
| Contribution | Individual: personally owned classification, guard, test, review, or coordination. Team/system: release tooling, backend operations, CI, and review process. |

## Reflection

Convenient injection had blurred public configuration and server authority.
Executable rejection moved the rule from advice into a build boundary.

## New default

Classify every value as **public-client** or **server-only** before it enters a
build pipeline. Add new release entrypoints to the same enforced boundary.

## Revisit trigger

Revisit when a new configuration source, provider credential, release
entrypoint, or token model appears.
