# Certificate pinning

## Purpose

Demonstrate and optionally enforce **TLS certificate pin validation** for the
app’s Dio HTTP client. Pinning reduces MITM risk when an attacker controls a
trusted CA or intermediate. It does **not** replace authentication, secure
token storage, reverse-engineering protections, or device integrity checks.

**Default mode is `disabled`** for all flavors. Enable explicitly.

## Architecture

Owned by `packages/networking` (`lib/src/certificate_pinning/`):

| Type | Role |
| --- | --- |
| `CertificatePinningConfig` | Immutable mode, hosts, pins, hash kind, timeout, verbose flag |
| `CertificatePinValidator` | Abstraction used by networking + demo |
| `RealCertificatePinValidator` | SHA-256 of **SPKI** by default (`sha256/` + Base64); optional leaf DER |
| `CertificateSpkiExtractor` | Parses leaf X.509 DER → SubjectPublicKeyInfo TLV |
| `MockCertificatePinValidator` | Deterministic scenarios (no live cert required) |
| `DisabledCertificatePinValidator` | Always succeeds; Dio adapter not applied |
| `applyCertificatePinning` | Sets Dio `IOHttpClientAdapter.validateCertificate` when mode is `real` (IO only; web stub no-ops) |

App wiring:

- Config factory: `apps/mobile/lib/app/config/certificate_pinning_config_factory.dart`
- DI: `register_http_services.dart` registers config, logger, validator, applies pinning to main `Dio`
- Demo: `features/certificate_pinning_demo/` (gated from prod/release)

```text
Request → Dio → platform TLS trust → leaf DER → validateCertificate
  → extract SPKI (default) → SHA-256 → RealCertificatePinValidator
  → continue or DioException.badCertificate
```

Demo probes (when mode is `disabled` / mock) call the mock validator **locally**
and do not enable the Dio adapter.

## Real versus mock

| Mode | Dio adapter | Demo probe |
| --- | --- | --- |
| `disabled` (default) | Off | Local mock validator |
| `mockSuccess` / `mockFailure` | Off | Mock validator |
| `real` | On (IO) | Dio GET to probe URL if set, else synthetic validate |

Override:

```bash
--dart-define=CERT_PINNING_MODE=disabled|mockSuccess|mockFailure|real
--dart-define=CERT_PINNING_HASH_KIND=spki|leaf
--dart-define=CERT_PINNING_HOSTS=api.example.com
--dart-define=CERT_PINNING_PINS=api.example.com=sha256/PRIMARY|sha256/BACKUP
--dart-define=CERT_PINNING_PROBE_URL=https://api.example.com/health
--dart-define=CERT_PINNING_VERBOSE=true
```

`CERT_PINNING_HASH_KIND` defaults to **`spki`**. Use `leaf` only while
migrating pins computed over full leaf certificate DER.

Hosts are normalized to lowercase. **Web builds reject `mode=real`** at
startup (`StateError` / `UnsupportedError`) — keep `disabled` on web.

Production **release** builds reject mock modes at startup (`StateError`).
`real` without hosts/pins also fails fast. Demo probes in `real` mode require
`CERT_PINNING_PROBE_URL`.

## How to run the demo

1. Launch a non-prod debug/profile build (`main_dev.dart`).
2. Open **Example** → **Certificate pinning demo**, or Counter overflow menu.
3. Pick a mock scenario → **Trigger secure probe**.
4. Inspect safe status text and developer log lines (no raw pins/certs).

Route `/certificate-pinning-demo` redirects to counter when
`kReleaseMode || Flavor.prod`.

## How to add a host

1. Add host to `CERT_PINNING_HOSTS`.
2. Add one or more **SPKI** pins under `CERT_PINNING_PINS` for that host.
3. Set `CERT_PINNING_MODE=real`.
4. Ship app with **old + new** pins before rotating the server key/cert.

## Generate a SHA-256 SPKI pin (default)

```bash
# From a live host
openssl s_client -connect api.example.com:443 -servername api.example.com </dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl base64

# Or from a PEM/DER cert on disk
openssl x509 -in leaf.pem -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl base64
```

Format as `sha256/<output>`.

**Why SPKI:** Pinning the public key (SubjectPublicKeyInfo) survives leaf
certificate renewal when the key pair is unchanged. Leaf DER pins break on
every new cert even if the key is reused.

## Generate a SHA-256 leaf pin (legacy)

```bash
openssl s_client -connect api.example.com:443 -servername api.example.com </dev/null 2>/dev/null \
  | openssl x509 -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl base64
```

Use with `--dart-define=CERT_PINNING_HASH_KIND=leaf`. Prefer migrating to SPKI.

## Certificate rotation

1. Release app with **old and new** pins for the host.
2. Rotate the server certificate (and key if needed).
3. Confirm clients accept the new pin (telemetry / support).
4. Later release: remove the old pin.

When only the leaf cert renews and the **same public key** is kept, SPKI pins
do not need updating. Leaf-hash pins still must rotate.

## Failure handling

Pin failures become `DioExceptionType.badCertificate` on the wire. The retry
interceptor does **not** treat `badCertificate` as transient. Demo maps domain
failures to safe l10n strings (no hashes, PEMs, or stack traces in UI).

## Android

No `network_security_config.xml` pinning. **App-level Dio validation is
authoritative.** Do not duplicate pins in Network Security Config (dual policy
risk).

## iOS

Default ATS (HTTPS) is preserved. No insecure ATS exceptions. Leaf access for
pinning uses Dio’s IO adapter after system trust.

## Security limitations

Certificate pinning:

- reduces MITM risk when CAs are compromised or proxies forge trust
- does **not** prevent reverse engineering
- does **not** fully protect compromised/rooted devices
- does **not** replace secure token storage
- does **not** replace server-side authentication
- does **not** protect embedded secrets

Web builds cannot enforce Dio pinning (`dart:io` adapter unavailable). Enabling
`CERT_PINNING_MODE=real` on web fails closed at bootstrap / apply time.

## Rollback

Set `CERT_PINNING_MODE=disabled` (or omit the define) and ship. Do not silently
fall back from `real` to `disabled` inside the app when validation fails.

## Incident recovery

1. Confirm outage is pin-related (new key/cert without updated pins).
2. Ship emergency build with updated pins (primary + backup) or temporarily
   `disabled` only if product accepts the MITM trade-off.
3. After recovery, restore `real` with correct multi-pin set.
4. Document root cause and rotation checklist follow-up.
