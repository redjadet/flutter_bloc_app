#!/usr/bin/env python3
"""
Analyze integration_test traceAction() artifacts exported via tool/capture_perf_trace.sh.

Input: artifacts/perf/perf_report_data_*.json
Output: human-readable summary to stdout (optionally JSON).

This intentionally stays dependency-free (stdlib only) so it can run anywhere
Flutter runs in this repo.
"""

from __future__ import annotations

import argparse
import json
import math
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


@dataclass(frozen=True)
class SpanStat:
    name: str
    count: int
    total_us: int
    p50_us: int
    p90_us: int
    p99_us: int
    max_us: int

    def to_row(self) -> dict[str, Any]:
        def ms(us: int) -> float:
            return round(us / 1000.0, 3)

        return {
            "name": self.name,
            "count": self.count,
            "total_ms": ms(self.total_us),
            "p50_ms": ms(self.p50_us),
            "p90_ms": ms(self.p90_us),
            "p99_ms": ms(self.p99_us),
            "max_ms": ms(self.max_us),
        }


def percentile(sorted_us: list[int], p: float) -> int:
    if not sorted_us:
        return 0
    # Nearest-rank, 1-indexed.
    idx = max(0, min(len(sorted_us) - 1, math.ceil(p * len(sorted_us)) - 1))
    return sorted_us[idx]


def compute_stats(name: str, durs_us: list[int]) -> SpanStat:
    durs_us = sorted(durs_us)
    return SpanStat(
        name=name,
        count=len(durs_us),
        total_us=sum(durs_us),
        p50_us=percentile(durs_us, 0.50),
        p90_us=percentile(durs_us, 0.90),
        p99_us=percentile(durs_us, 0.99),
        max_us=durs_us[-1] if durs_us else 0,
    )


def iter_events(trace_events: Iterable[Any]) -> Iterable[dict[str, Any]]:
    for e in trace_events:
        if isinstance(e, dict):
            yield e


def collect_complete_spans(trace_events: list[dict[str, Any]]) -> dict[str, list[int]]:
    """Collect chrome-trace complete events (ph='X') with a dur field."""
    d: dict[str, list[int]] = defaultdict(list)
    for e in trace_events:
        if e.get("ph") != "X":
            continue
        name = e.get("name")
        dur = e.get("dur")
        if isinstance(name, str) and isinstance(dur, (int, float)):
            d[name].append(int(dur))
    return d


def collect_async_spans(trace_events: list[dict[str, Any]]) -> dict[str, list[int]]:
    """Collect async spans based on b/e (and B/E) with shared id."""
    starts: dict[tuple[str, str], int] = {}
    d: dict[str, list[int]] = defaultdict(list)
    for e in trace_events:
        ph = e.get("ph")
        if ph not in ("b", "e", "B", "E"):
            continue
        name = e.get("name")
        eid = e.get("id")
        ts = e.get("ts")
        if not isinstance(name, str) or not isinstance(eid, str) or not isinstance(ts, int):
            continue
        key = (name, eid)
        if ph in ("b", "B"):
            starts[key] = ts
        else:
            start = starts.pop(key, None)
            if start is not None and ts >= start:
                d[name].append(ts - start)
    return d


def top_stats(
    spans: dict[str, list[int]],
    *,
    min_count: int,
    min_max_us: int,
    limit: int,
) -> list[SpanStat]:
    stats = []
    for name, durs in spans.items():
        if len(durs) < min_count:
            continue
        st = compute_stats(name, durs)
        if st.max_us < min_max_us:
            continue
        stats.append(st)
    stats.sort(key=lambda s: (s.max_us, s.p99_us, s.total_us), reverse=True)
    return stats[:limit]

def _collect_frame_durations_us(
    *,
    complete: dict[str, list[int]],
    asyncs: dict[str, list[int]],
) -> list[int]:
    # In Flutter timeline traces, "Frame" is typically an async span, but we
    # defensively merge both representations.
    return [*asyncs.get("Frame", []), *complete.get("Frame", [])]


def _count_over_budget(durs_us: list[int], *, budget_us: int) -> int:
    return sum(1 for d in durs_us if d > budget_us)


def frame_metrics(
    *,
    complete: dict[str, list[int]],
    asyncs: dict[str, list[int]],
) -> dict[str, Any]:
    durs_us = _collect_frame_durations_us(complete=complete, asyncs=asyncs)
    st = compute_stats("Frame", durs_us) if durs_us else None
    return {
        "count": len(durs_us),
        "p90_ms": round(percentile(sorted(durs_us), 0.90) / 1000.0, 3) if durs_us else None,
        "p99_ms": round(percentile(sorted(durs_us), 0.99) / 1000.0, 3) if durs_us else None,
        "max_ms": round((st.max_us if st else 0) / 1000.0, 3) if durs_us else None,
        "over_8_3ms": _count_over_budget(durs_us, budget_us=8_333) if durs_us else 0,
        "over_16_7ms": _count_over_budget(durs_us, budget_us=16_667) if durs_us else 0,
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("path", type=Path, help="perf_report_data_*.json path")
    ap.add_argument("--trace", default=None, help="trace key to analyze (default: all)")
    ap.add_argument("--limit", type=int, default=25)
    ap.add_argument("--min-count", type=int, default=5)
    ap.add_argument("--min-max-ms", type=float, default=2.0)
    ap.add_argument("--json", action="store_true", help="emit JSON instead of text")
    args = ap.parse_args()

    raw = json.loads(args.path.read_text(encoding="utf-8"))
    trace_keys = [args.trace] if args.trace else [k for k in raw.keys() if k.endswith("_trace")]

    out: dict[str, Any] = {"file": str(args.path), "traces": {}}

    for k in trace_keys:
        trace = raw.get(k)
        if not isinstance(trace, dict):
            continue
        events = list(iter_events(trace.get("traceEvents", [])))
        complete = collect_complete_spans(events)
        asyncs = collect_async_spans(events)

        min_max_us = int(args.min_max_ms * 1000)
        top_complete = top_stats(complete, min_count=args.min_count, min_max_us=min_max_us, limit=args.limit)
        top_async = top_stats(asyncs, min_count=args.min_count, min_max_us=min_max_us, limit=args.limit)

        out["traces"][k] = {
            "timeExtentMicros": trace.get("timeExtentMicros"),
            "eventCount": len(events),
            "frame": frame_metrics(complete=complete, asyncs=asyncs),
            "top_complete": [s.to_row() for s in top_complete],
            "top_async": [s.to_row() for s in top_async],
        }

    if args.json:
        print(json.dumps(out, indent=2, sort_keys=True))
        return 0

    print(f"perf trace: {args.path}")
    for k, summary in out["traces"].items():
        print()
        print(f"== {k} ==")
        print(f"- events: {summary['eventCount']}")
        print(f"- timeExtentMicros: {summary['timeExtentMicros']}")
        frame = summary.get("frame") or {}
        if frame.get("count", 0):
            print()
            print("Frame budget (async 'Frame' span)")
            print(
                "  - "
                f"count={frame['count']} "
                f"p90={frame['p90_ms']}ms p99={frame['p99_ms']}ms max={frame['max_ms']}ms "
                f">8.3ms={frame['over_8_3ms']} >16.7ms={frame['over_16_7ms']}"
            )
        else:
            print()
            print("Frame budget (async 'Frame' span)")
            print("  (no 'Frame' spans found)")

        def show(title: str, rows: list[dict[str, Any]]) -> None:
            print()
            print(title)
            if not rows:
                print("  (none)")
                return
            for r in rows:
                print(
                    f"  - {r['name']}: "
                    f"count={r['count']} "
                    f"p50={r['p50_ms']}ms p90={r['p90_ms']}ms p99={r['p99_ms']}ms max={r['max_ms']}ms "
                    f"total={r['total_ms']}ms"
                )

        show("Top complete spans (ph='X')", summary["top_complete"])
        show("Top async spans (b/e ids)", summary["top_async"])

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

