# Video Stack Comparison: Jitsi vs Agora vs Twilio

## Context

This repository includes a time-boxed online therapy demo. The current product
goal is to prove the end-to-end mobile flow:

`booking -> messaging -> pre-call -> join/failure/fallback`

The implemented demo is **simulation-first**. It does not currently embed a
live RTC SDK. That is intentional: the demo should be stable on iOS and Android
without spending the sprint on video credentials, native SDK issues, or
provider-specific compliance claims.

## Current recommendation

- **Default for this repo demo**: keep the simulation UI.
- **Optional spike**: Jitsi, only if the interview/demo specifically needs a
  live room proof and the spike passes quickly.
- **Out of current demo scope**: Agora and Twilio. They are credible production
  choices, but they add token minting, account setup, and SDK test overhead that
  is not necessary for this demo.

Do not block the online therapy demo on live video provider integration unless
the user explicitly changes the goal.

## What each option is

### Jitsi (Jitsi Meet)

- **Type**: Open-source video conferencing solution.
- **Integration style**: Usually via an embedded meeting UI (app joins a room by name/URL).
- **Hosting**: Can use public Jitsi infrastructure for quick demos, or self-host for production control.
- **Demo risk**: public rooms are quick but weak proof for access control;
  self-hosting is stronger but outside a short mobile demo.

### Agora

- **Type**: Commercial real-time communications (RTC) SDK provider.
- **Integration style**: Native SDKs / Flutter plugins; you build your own call UI and control the media pipeline.
- **Hosting**: Managed cloud service; credentials required (App ID / tokens).
- **Demo risk**: needs token/backend wiring for a credible secure-room story.

### Twilio Video

- **Type**: Commercial RTC platform (Twilio Programmable Video).
- **Integration style**: Native SDKs / plugins; you implement call flows and UI.
- **Hosting**: Managed cloud; credentials required (API keys, access tokens, TURN config handled by Twilio).
- **Demo risk**: strong production story, but not a low-friction short-demo
  dependency.

## Comparison Table (Demo-focused)

| Category | Simulation UI | Jitsi | Agora | Twilio Video |
| --- | --- | --- | --- | --- |
| **Time-to-demo** | Fastest | Fast for basic room | Medium/High | Medium/High |
| **Setup noise risk** | Low | Medium | Medium/High | Medium/High |
| **Credentials needed** | No | Maybe | Yes | Yes |
| **UI effort** | Medium, app-owned | Low with prebuilt UI | Higher | Higher |
| **Secure room proof** | Conceptual only | Weak unless token/self-hosted | Strong with backend tokens | Strong with backend tokens |
| **Production control** | Not real media | Good if self-hosted | Good | Good |
| **Best fit** | Current interview demo | Optional live-room spike | Product-grade custom RTC | Product-grade custom RTC |

## Security, privacy, and compliance notes (therapy context)

Regardless of provider, therapy apps usually require:

- **Strong access control** (who can join which room).
- **Token-based room admission** (server-minted access tokens; no guessable room IDs).
- **Data minimization** (avoid exposing PII in room names, logs, or analytics).
- **Audit trails** (who started/joined a call and when).
- **Vendor + hosting decisions** aligned to local requirements (e.g., KVKK/GDPR), data residency needs, and incident response.

Important: do not claim HIPAA/KVKK-compliant video unless the required controls
are implemented and documented end-to-end. For this repo, the honest claim is:
the UI shows the product flow and failure handling, while the production
controls are documented as roadmap work.

## Practical selection criteria

### Keep Simulation When

- The goal is a stable 5-10 minute mobile interview demo.
- The demo needs app-visible proof of booking, messaging, retry, audit, and
  fallback states more than real media transport.
- The team has not implemented backend-minted call tokens.

### Choose Jitsi when…

- You need a **working call UI quickly** to demonstrate the flow.
- You can accept a **prebuilt meeting UI** for the demo.
- You can keep the integration **stable across iOS + Android** without repo-wide refactors.
- You can avoid PII in room names and explain that this is not the production
  security model unless token/self-hosting work is done.

### Choose Agora/Twilio when…

- The product requires **deep RTC control** (custom UI/UX, advanced media controls, optimizations).
- You already have (or can quickly add) the **backend token minting** flow.
- You have time for **SDK-level testing**, edge cases, and production hardening.

## Demo “Spike” rule (recommended)

To avoid spending days on video integration during a short demo sprint:

- Allocate a fixed spike window (e.g., **≤ 90 minutes**) for Jitsi.
- **Go** only if:
  - iOS simulator **and** Android emulator/device builds succeed,
  - the join flow doesn’t crash,
  - permission denial is handled cleanly.
- Otherwise **No-Go** and ship with a clean **fallback simulation UI** (join states + failure modes).

No-Go is the default unless the spike proves value without destabilizing the
mobile demo.

## Next steps after the demo (production roadmap)

If the product proceeds beyond the demo:

- Add a backend service to mint **room/session tokens** and map them to appointments.
- Use unguessable room/session IDs; never put names, emails, or appointment
  details in room names.
- Decide on hosting/vendor based on:
  - compliance requirements,
  - operational constraints (self-host vs managed),
  - cost model,
  - UX control needs.
- Implement:
  - retries, network resilience,
  - call quality metrics,
  - structured audit logging,
  - incident/runbook documentation.

## Current repo decision

For the current online therapy demo, keep the simulation UI as the shipped
behavior. Treat live video integration as a separate, explicitly requested
spike after the demo flow is stable.
