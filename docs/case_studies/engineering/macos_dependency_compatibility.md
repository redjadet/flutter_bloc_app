# macOS dependency compatibility

## Context

SwiftPM cannot build a plugin version without a usable `Package.swift`.
Registered plugin modules can then fail macOS compilation even when the rest of
the dependency graph supports SwiftPM. A broad workaround would increase
maintenance or remove working features.

## Ownership

Own the macOS runner integration seam and pinned dependency evidence. Do not
claim ownership of Flutter SDK or third-party plugin source. In an interview,
separate the fallback personally designed or verified from platform and package
maintainer work.

## Options

1. Patch Flutter SDK or pub-cache sources.
2. Disable SwiftPM for the entire dependency graph.
3. Remove features backed by incompatible plugins.
4. Route only plugins without usable SwiftPM manifests through CocoaPods.

## Decision

Choose option 4. The macOS Podfile checks each native plugin. SwiftPM-compatible
plugins stay on the modern path; only incompatible plugins enter the CocoaPods
fallback and runner embed phase.

## Rejected approach

Reject Flutter SDK/package-cache patches, global SwiftPM disablement, and
feature removal. Those choices widen blast radius to solve a per-plugin gap.

## Trade-off

macOS carries two dependency mechanisms and a Pod lock. The extra integration
surface is accepted because the fallback is narrow, visible, and removable.

## Proof and outcome

| Evidence status | Boundary |
| --- | --- |
| Implemented behavior | Current Podfile selects fallback pods per plugin; current Pod lock records `desktop_webview_auth` and `flutter_tts`. This is tree state, not a fresh macOS build result. |
| Repository proof | [`Podfile`](../../../apps/other_platforms/macos/Podfile), [`Podfile.lock`](../../../apps/other_platforms/macos/Podfile.lock), and pinned [`pubspec.lock`](../../../pubspec.lock) |
| Historical evidence | `git show 7156ffcd` records the module-resolution failure and narrow repair. |
| Planned / deferred | No claim that every future version of these plugins needs CocoaPods or that macOS was rebuilt in this documentation change. |
| Contribution | Individual: personally owned runner fallback or verification. Team/system: Flutter generation, plugin manifests, CocoaPods/SwiftPM behavior, and shared build review. |

## Reflection

Platform compatibility is not binary at application level. Dependency
capabilities differ per plugin, so the integration decision must preserve the
working majority while isolating exceptions.

## New default

Isolate incompatible dependencies. Preserve SwiftPM for compatible plugins and
use the smallest removable fallback for the rest.

## Revisit trigger

Remove or narrow the fallback when pinned plugins gain usable manifests or
Flutter's generated macOS integration owns the hybrid graph correctly.
