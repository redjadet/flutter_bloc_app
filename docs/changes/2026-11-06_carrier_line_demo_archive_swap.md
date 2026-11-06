# Carrier line demo + ADR-0005 Archive swap

**Date:** 2026-11-06  
**ADR:** [0005](../adr/0005-interview-showcase-scope.md) Decision 7  
**PR checklist:** acknowledge Archive replacement when opening the PR.

## Catalog change

| Action | Module | Tier |
| --- | --- | --- |
| Retire (Archive swap) | `weather_demo` | Archive → retired for swap; route kept historical |
| Add | `carrier_line_demo` | Depth |

Updated tags live in [`feature_overview.md`](../feature_overview.md).

## Why weather

Weather is already Archive with no sync/offline narrative tied to the Senior
Mobile carrier surface. Retiring it frees a catalog slot without touching Spine
or high-value Depth demos. Code and `/weather-demo` remain for screenshots and
history; no new investment.

## Carrier line P0 honesty

Synthetic local activity, simulated connection, fixture status cards. No VoIP
stubs, no interactive push UI, no Dio, no sync claims. Shared
`FcmMessagingService` is composed for P1 push UI only.
