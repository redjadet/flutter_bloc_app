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
import statistics
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Literal


GateOutcome = Literal["pass", "fail", "report_only"]


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


@dataclass(frozen=True)
class PerfBudgets:
    min_measured_frames: int
    p90_ms_max: float
    p99_ms_max: float
    over_16_7ms_ratio_max: float
    p90_regression_vs_median_max: float
    variance_report_only_threshold: float

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> PerfBudgets:
        return cls(
            min_measured_frames=int(data["min_measured_frames"]),
            p90_ms_max=float(data["p90_ms_max"]),
            p99_ms_max=float(data["p99_ms_max"]),
            over_16_7ms_ratio_max=float(data["over_16_7ms_ratio_max"]),
            p90_regression_vs_median_max=float(data["p90_regression_vs_median_max"]),
            variance_report_only_threshold=float(data["variance_report_only_threshold"]),
        )


@dataclass(frozen=True)
class BudgetViolation:
    check: str
    message: str


@dataclass(frozen=True)
class FrameBudgetGateResult:
    outcome: GateOutcome
    violations: tuple[BudgetViolation, ...]
    frame: dict[str, Any]
    baseline_relative_spread: float | None = None
    p90_regression_ratio: float | None = None


def default_budgets_path() -> Path:
    return Path(__file__).resolve().parent / "perf_budgets.json"


def load_perf_budgets(path: Path | None = None) -> PerfBudgets:
    budgets_path = path or default_budgets_path()
    raw = json.loads(budgets_path.read_text(encoding="utf-8"))
    return PerfBudgets.from_dict(raw)


def baseline_relative_spread(values: list[float]) -> float:
    """Relative spread of baseline p90 samples: (max - min) / median."""
    if len(values) < 2:
        return 0.0
    median = statistics.median(values)
    if median <= 0:
        return 0.0
    return (max(values) - min(values)) / median


def p90_regression_ratio(current_p90_ms: float, baseline_median_p90_ms: float) -> float:
    if baseline_median_p90_ms <= 0:
        return 0.0
    return (current_p90_ms - baseline_median_p90_ms) / baseline_median_p90_ms


def evaluate_frame_budget_gate(
    frame: dict[str, Any],
    budgets: PerfBudgets,
    *,
    baseline_p90_ms: list[float] | None = None,
) -> FrameBudgetGateResult:
    """Evaluate frame budgets with pass/fail/report-only outcomes.

  Report-only when a 3-run baseline has relative spread above
  ``variance_report_only_threshold``; gate claim is withheld.
    """
    spread: float | None = None
    regression: float | None = None

    if baseline_p90_ms is not None and len(baseline_p90_ms) >= 3:
        spread = baseline_relative_spread(baseline_p90_ms)
        if spread > budgets.variance_report_only_threshold:
            return FrameBudgetGateResult(
                outcome="report_only",
                violations=(),
                frame=frame,
                baseline_relative_spread=spread,
            )

    violations: list[BudgetViolation] = []
    count = int(frame.get("count") or 0)
    p90_ms = frame.get("p90_ms")
    p99_ms = frame.get("p99_ms")
    over_16_7ms = int(frame.get("over_16_7ms") or 0)

    if count < budgets.min_measured_frames:
        violations.append(
            BudgetViolation(
                check="min_measured_frames",
                message=(
                    f"measured frames {count} < minimum {budgets.min_measured_frames}"
                ),
            )
        )

    if p90_ms is None:
        violations.append(
            BudgetViolation(
                check="p90_ms",
                message="no p90_ms available (missing Frame spans)",
            )
        )
    elif float(p90_ms) > budgets.p90_ms_max:
        violations.append(
            BudgetViolation(
                check="p90_ms_max",
                message=f"p90 {p90_ms}ms > budget {budgets.p90_ms_max}ms",
            )
        )

    if p99_ms is None:
        violations.append(
            BudgetViolation(
                check="p99_ms",
                message="no p99_ms available (missing Frame spans)",
            )
        )
    elif float(p99_ms) > budgets.p99_ms_max:
        violations.append(
            BudgetViolation(
                check="p99_ms_max",
                message=f"p99 {p99_ms}ms > budget {budgets.p99_ms_max}ms",
            )
        )

    if count > 0:
        ratio = over_16_7ms / count
        if ratio > budgets.over_16_7ms_ratio_max:
            violations.append(
                BudgetViolation(
                    check="over_16_7ms_ratio_max",
                    message=(
                        f">16.7ms frame ratio {ratio:.4f} > "
                        f"budget {budgets.over_16_7ms_ratio_max:.4f}"
                    ),
                )
            )

    if (
        baseline_p90_ms
        and len(baseline_p90_ms) >= 3
        and p90_ms is not None
    ):
        median_baseline = statistics.median(baseline_p90_ms)
        regression = p90_regression_ratio(float(p90_ms), median_baseline)
        if regression > budgets.p90_regression_vs_median_max:
            violations.append(
                BudgetViolation(
                    check="p90_regression_vs_median_max",
                    message=(
                        f"p90 regression {regression:.4f} > budget "
                        f"{budgets.p90_regression_vs_median_max:.4f} "
                        f"(current={p90_ms}ms median_baseline={median_baseline}ms)"
                    ),
                )
            )

    outcome: GateOutcome = "fail" if violations else "pass"
    return FrameBudgetGateResult(
        outcome=outcome,
        violations=tuple(violations),
        frame=frame,
        baseline_relative_spread=spread,
        p90_regression_ratio=regression,
    )


def frame_metrics(
    *,
    complete: dict[str, list[int]],
    asyncs: dict[str, list[int]],
) -> dict[str, Any]:
    durs_us = _collect_frame_durations_us(complete=complete, asyncs=asyncs)
    st = compute_stats("Frame", durs_us) if durs_us else None
    count = len(durs_us)
    over_16_7ms = _count_over_budget(durs_us, budget_us=16_667) if durs_us else 0
    return {
        "count": count,
        "p90_ms": round(percentile(sorted(durs_us), 0.90) / 1000.0, 3) if durs_us else None,
        "p99_ms": round(percentile(sorted(durs_us), 0.99) / 1000.0, 3) if durs_us else None,
        "max_ms": round((st.max_us if st else 0) / 1000.0, 3) if durs_us else None,
        "over_8_3ms": _count_over_budget(durs_us, budget_us=8_333) if durs_us else 0,
        "over_16_7ms": over_16_7ms,
        "over_16_7ms_ratio": round(over_16_7ms / count, 6) if count else None,
    }


# Span-name substrings → next investigation step when present in top spans.
_SPAN_HINTS: tuple[tuple[str, str], ...] = (
    ("BUILD", "UI-side build work — inspect rebuild scope / BlocSelector width"),
    ("LAYOUT", "UI-side layout — watch Intrinsic* and shrinkWrap in lists"),
    ("PAINT", "UI-side paint — check unnecessary repaints"),
    ("Rasterizer", "Raster-side — clips, opacity, shadows, saveLayer, layers"),
    ("GPURasterizer", "Raster-side — clips, opacity, shadows, saveLayer, layers"),
    ("Shader", "Raster/shader compilation — warm shaders or simplify effects"),
    ("Image", "Image decode/cache — size requests; isolate heavy cells"),
    ("GC", "GC pressure — confirm with DevTools Memory (not alone)"),
    ("Garbage", "GC pressure — confirm with DevTools Memory (not alone)"),
    ("json", "Possible main-isolate parse — see compute_isolate_review.md"),
)


def classify_span_hints(span_names: Iterable[str]) -> list[str]:
    """Map top timeline span names to triage hints (deduped, stable order)."""
    seen: set[str] = set()
    out: list[str] = []
    for name in span_names:
        upper = name.upper()
        for needle, hint in _SPAN_HINTS:
            if needle.upper() in upper and hint not in seen:
                seen.add(hint)
                out.append(hint)
    return out


def triage_next_steps(
    frame: dict[str, Any],
    *,
    gate_outcome: str,
    top_complete: list[dict[str, Any]] | None = None,
    top_async: list[dict[str, Any]] | None = None,
) -> list[str]:
    """Human/agent next steps after frame-budget analysis.

    Automated traces prove *that* frames are late; DevTools profile mode still
    owns UI vs Raster attribution. See docs/performance/finding_jank_cause.md.

    Pressure means gate ``fail`` or any true 60Hz miss (``over_16_7ms > 0``).
    A lone ``over_8_3ms`` count with gate ``pass`` is not treated as jank —
    repo budgets already use 8.3ms as the p90 ceiling at gate time.
    """
    steps: list[str] = []
    over_16 = int(frame.get("over_16_7ms") or 0)
    over_8 = int(frame.get("over_8_3ms") or 0)
    count = int(frame.get("count") or 0)
    pressure = gate_outcome == "fail" or over_16 > 0

    if gate_outcome == "report_only":
        steps.append(
            "Gate is report-only (baseline variance too high) — "
            "recapture 3 stable runs before claiming pass/fail or changing code."
        )
        steps.append(
            "Automated gate uses tool/perf_budgets.json "
            "(p90≤8.3ms, p99≤16.7ms); UI vs Raster still needs profile DevTools."
        )
    elif pressure:
        steps.append(
            "Frame-budget pressure detected — jank is a symptom; "
            "do not change code until UI vs Raster (or limiting span) is identified."
        )
        if gate_outcome == "fail" and over_16 == 0:
            steps.append(
                "Gate failed on budget thresholds (often p90>8.3ms) even with "
                "zero >16.7ms frames — still identify the limiting work before patching."
            )
        steps.append(
            "Reproduce the same interaction in profile mode: "
            "cd apps/mobile && flutter run --profile "
            "(iOS Simulator often cannot run --profile; use a physical device "
            "for final accept)."
        )
        steps.append(
            "DevTools Performance: select a red frame; compare UI vs Raster; "
            "then enable BUILD/LAYOUT/PAINT or inspect raster effects."
        )
    elif count == 0:
        steps.append(
            "No Frame spans found — re-capture with traceAction, or use "
            "profile-mode DevTools Performance on the slow interaction."
        )
    else:
        steps.append(
            "No frame-budget pressure in this artifact "
            f"(gate={gate_outcome}, >16.7ms={over_16}, >8.3ms={over_8}) — "
            "treat Pipeline* spikes as noise unless they coincide with gate fail "
            "or >16.7ms Frame counts."
        )

    names: list[str] = []
    for row in (*(top_complete or ()), *(top_async or ())):
        name = row.get("name")
        if isinstance(name, str):
            names.append(name)
    for hint in classify_span_hints(names):
        steps.append(f"Span hint: {hint}")

    steps.append(
        "Canon: docs/performance/finding_jank_cause.md — "
        "or bash tool/triage_jank.sh"
    )
    return steps


def analyze_trace_file(
    path: Path,
    *,
    trace_key: str | None = None,
    budgets: PerfBudgets | None = None,
) -> dict[str, Any]:
    """Load a perf report JSON file and return per-trace summaries."""
    raw = json.loads(path.read_text(encoding="utf-8"))
    trace_keys = [trace_key] if trace_key else [k for k in raw.keys() if k.endswith("_trace")]
    resolved_budgets = budgets or load_perf_budgets()

    out: dict[str, Any] = {"file": str(path), "traces": {}}
    for k in trace_keys:
        trace = raw.get(k)
        if not isinstance(trace, dict):
            continue
        events = list(iter_events(trace.get("traceEvents", [])))
        complete = collect_complete_spans(events)
        asyncs = collect_async_spans(events)
        frame = frame_metrics(complete=complete, asyncs=asyncs)
        out["traces"][k] = {
            "timeExtentMicros": trace.get("timeExtentMicros"),
            "eventCount": len(events),
            "frame": frame,
            "gate": evaluate_frame_budget_gate(frame, resolved_budgets).outcome,
        }
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("path", type=Path, help="perf_report_data_*.json path")
    ap.add_argument("--trace", default=None, help="trace key to analyze (default: all)")
    ap.add_argument("--limit", type=int, default=25)
    ap.add_argument("--min-count", type=int, default=5)
    ap.add_argument("--min-max-ms", type=float, default=2.0)
    ap.add_argument(
        "--budgets",
        type=Path,
        default=None,
        help="perf budgets JSON (default: tool/perf_budgets.json)",
    )
    ap.add_argument("--json", action="store_true", help="emit JSON instead of text")
    ap.add_argument(
        "--triage",
        action="store_true",
        help="print next-step cause triage after each trace summary",
    )
    args = ap.parse_args()

    budgets = load_perf_budgets(args.budgets)
    raw = json.loads(args.path.read_text(encoding="utf-8"))
    trace_keys = [args.trace] if args.trace else [k for k in raw.keys() if k.endswith("_trace")]

    out: dict[str, Any] = {"file": str(args.path), "budgets": budgets.__dict__, "traces": {}}

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
        frame = frame_metrics(complete=complete, asyncs=asyncs)
        gate = evaluate_frame_budget_gate(frame, budgets)
        top_complete_rows = [s.to_row() for s in top_complete]
        top_async_rows = [s.to_row() for s in top_async]
        triage = triage_next_steps(
            frame,
            gate_outcome=gate.outcome,
            top_complete=top_complete_rows,
            top_async=top_async_rows,
        )

        out["traces"][k] = {
            "timeExtentMicros": trace.get("timeExtentMicros"),
            "eventCount": len(events),
            "frame": frame,
            "gate": {
                "outcome": gate.outcome,
                "violations": [v.__dict__ for v in gate.violations],
                "baseline_relative_spread": gate.baseline_relative_spread,
                "p90_regression_ratio": gate.p90_regression_ratio,
            },
            "top_complete": top_complete_rows,
            "top_async": top_async_rows,
            "triage": triage,
        }

    def gate_exit_code() -> int:
        """Nonzero when any analyzed trace gate outcome is fail."""
        for summary in out["traces"].values():
            gate = summary.get("gate") or {}
            if gate.get("outcome") == "fail":
                return 1
        return 0

    if args.json:
        print(json.dumps(out, indent=2, sort_keys=True))
        return gate_exit_code()

    print(f"perf trace: {args.path}")
    for k, summary in out["traces"].items():
        print()
        print(f"== {k} ==")
        print(f"- events: {summary['eventCount']}")
        print(f"- timeExtentMicros: {summary['timeExtentMicros']}")
        frame = summary.get("frame") or {}
        gate = summary.get("gate") or {}
        if frame.get("count", 0):
            print()
            print("Frame budget (async 'Frame' span)")
            print(
                "  - "
                f"count={frame['count']} "
                f"p90={frame['p90_ms']}ms p99={frame['p99_ms']}ms max={frame['max_ms']}ms "
                f">8.3ms={frame['over_8_3ms']} >16.7ms={frame['over_16_7ms']}"
            )
            print(f"  - gate: {gate.get('outcome', 'unknown')}")
            for violation in gate.get("violations") or []:
                print(f"    ! {violation.get('check')}: {violation.get('message')}")
        else:
            print()
            print("Frame budget (async 'Frame' span)")
            print("  (no 'Frame' spans found)")
            print(f"  - gate: {gate.get('outcome', 'fail')}")

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

        if args.triage or gate.get("outcome") == "fail":
            print()
            print("Triage next steps (cause, not patch)")
            for step in summary.get("triage") or []:
                print(f"  - {step}")

    return gate_exit_code()


if __name__ == "__main__":
    raise SystemExit(main())

