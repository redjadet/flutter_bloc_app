# Online Therapy Demo

In-app demo surface for an online therapy product brief. It proves the core
client, therapist, and admin flows in a 5-10 minute walkthrough using a
deterministic fake backend.

This is a demo, not a compliance claim. It is built to show product thinking,
mobile UX, clean architecture, failure handling, and the path to a real
backend/video provider.

## How to open

- From the app: open the demo entry labelled **Online Therapy Demo**.
- Direct route: `/online-therapy-demo`.

Route map:

| Area | Route | Purpose |
| --- | --- | --- |
| Landing | `/online-therapy-demo` | Sign in, select role, open controls |
| Controls | `/online-therapy-demo/controls` | Network and failure injection |
| Client hub | `/online-therapy-demo/client` | Client navigation |
| Client therapists | `/online-therapy-demo/client/therapists` | Browse verified therapists |
| Client detail | `/online-therapy-demo/client/therapists/:therapistId` | Pick therapist and slot |
| Client booking | `/online-therapy-demo/client/booking/confirm` | Confirm selected slot |
| Client appointments | `/online-therapy-demo/client/appointments` | View/cancel appointments |
| Client messaging | `/online-therapy-demo/client/messaging` | Conversation and retry flow |
| Client call | `/online-therapy-demo/client/call` | Pre-call, join, fallback states |
| Therapist hub | `/online-therapy-demo/therapist` | Therapist navigation |
| Therapist appointments | `/online-therapy-demo/therapist/appointments` | Therapist appointment list |
| Therapist messaging | `/online-therapy-demo/therapist/messaging` | Same messaging surface |
| Therapist call | `/online-therapy-demo/therapist/call` | Same call surface |
| Admin hub | `/online-therapy-demo/admin` | Admin navigation |
| Admin verification | `/online-therapy-demo/admin/verification` | Approve pending therapists |
| Admin audit | `/online-therapy-demo/admin/audit` | Audit/event proof |

Auth note:

- Admin routes are **auth-gated** at the router layer (deep-link safe). If user is signed out, navigation redirects to `/auth` first.

## Demo script (fast)

1. Open `/online-therapy-demo`.
2. Keep the default email or type a demo email, then sign in.
3. Run the **Client** flow:
   - open therapists,
   - choose a verified therapist,
   - select a slot,
   - confirm booking,
   - open appointments,
   - open messaging,
   - open call.
4. Open **Controls** and switch mode to `messageFailure`; send a message, show
   `failed`, then retry and show `sent`.
5. Switch mode to `callFailure`; open the call flow and show the join failure
   fallback.
6. Switch role to **Therapist** and show the appointment/messaging surfaces.
7. Switch role to **Admin**, approve a pending therapist, then show the audit
   feed.

Use `normal` mode before the main walkthrough. Use `slow`, `offline`,
`messageFailure`, and `callFailure` only when deliberately proving failure UX.

## UI conventions

- **Time formatting**: appointment and slot times use device locale plus the
  user's 12/24h preference through `MaterialLocalizations` and
  `MediaQuery.alwaysUse24HourFormatOf`. Do not show raw ISO-8601 strings in
  demo UI.
- **Logged-out deep links**: role pages render a logged-out prompt and a single
  action back to the landing page.
- **Dynamic lists**: list builders snapshot Cubit state lists before
  `itemCount`/`itemBuilder` and guard stale indexes. `./bin/checklist` enforces
  this through `tool/check_live_state_list_indexing.sh`.
- **Controls access**: each role hub links back to Controls so failure modes are
  discoverable during a live walkthrough.

## Architecture (Clean + swappable backend)

| Layer | Path | Responsibility |
| --- | --- | --- |
| Routes | `lib/app/router/routes_online_therapy_demo.dart` | Multiscreen route tree |
| Scope | `lib/features/online_therapy_demo/presentation/online_therapy_demo_scope.dart` | Shared Cubit providers for the full route subtree |
| UI/Cubits | `lib/features/online_therapy_demo/presentation/` | Screens, reusable views, state transitions, error mapping |
| Domain | `lib/features/online_therapy_demo/domain/` | Entities and repository interfaces |
| Fake data | `lib/features/online_therapy_demo/data/fake/` | Deterministic REST-like fake API and repository adapters |
| DI | `lib/core/di/register_online_therapy_demo_services.dart` | Registers fake implementations behind domain interfaces |

Important routing invariant: demo Cubits live in `OnlineTherapyDemoScope`, the
builder for the demo `ShellRoute`. Child screens must read the shared Cubits
from this scope; they must not create new demo Cubits per screen.

## Failure injection (demo-friendly)

The demo is designed to *prove* failure handling in a deterministic way:

- **`normal`**: baseline success
- **`slow`**: controlled delay so loading states are visible
- **`offline`**: throws `StateError('Offline')` to exercise user-friendly error UIs
- **`messageFailure`**: first send becomes `failed`, retry becomes `sent`
- **`callFailure`**: video join becomes `failed` and shows fallback UI

Failure modes are stateful in the fake API and are intentionally deterministic.
They are for demo proof, widget tests, and agent validation; they are not a
replacement for real network chaos testing.

## Security / privacy notes (demo claims)

- **PII minimization**: UI shows masked email (no raw email/phone); message bodies are plain text demo content only.
- **RBAC proof**: fake API enforces role checks for admin-only operations (pending/approve therapist).
- **Logout cleanup (concept)**: demo treats logout as session/token reset.
- **Transport / storage (concept)**: production expectations are TLS + secure storage (Keychain/Keystore) + backend-side RBAC + audit logging.
- **No over-claim**: this demo does not claim production-grade compliance or E2E encryption; it shows boundaries and upgrade path.

## Video provider note

This demo currently ships **simulation-first** for stability and time-to-demo.
Real provider integration, such as Jitsi, Agora, or Twilio, is intentionally
outside the core demo loop unless it is stable and low-noise. See
[`video_stack_comparison.md`](video_stack_comparison.md).

## Validation

For online therapy changes, run the focused suite first:

```bash
flutter analyze lib/features/online_therapy_demo lib/app/router/routes_online_therapy_demo.dart lib/core/di/register_online_therapy_demo_services.dart test/features/online_therapy_demo
flutter test test/features/online_therapy_demo
npx markdownlint-cli2 docs/online_therapy_demo/README.md docs/online_therapy_demo/video_stack_comparison.md
```

Before calling broader work done, run the repo checklist:

```bash
./bin/checklist
```

For local iteration where coverage is not needed:

```bash
CHECKLIST_RUN_COVERAGE=0 ./bin/checklist
```

## Production roadmap

Replace the fake backend behind the existing repository interfaces:

1. Add authenticated API clients for auth, therapists, appointments, messaging,
   calls, admin verification, and audit events.
2. Move RBAC and audit enforcement server-side.
3. Add secure storage for session/token material.
4. Add backend-minted video room/session tokens tied to appointment IDs.
5. Add production observability: structured logs, audit retention, call-quality
   metrics, and incident runbooks.
