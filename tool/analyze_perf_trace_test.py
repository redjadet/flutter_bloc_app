"""Unit tests for tool/analyze_perf_trace.py frame budget gate."""

from __future__ import annotations

import importlib.util
import json
import sys
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
TESTDATA = Path(__file__).resolve().parent / "testdata" / "perf"


def _load_module():
    script_path = Path(__file__).with_name("analyze_perf_trace.py")
    spec = importlib.util.spec_from_file_location("analyze_perf_trace", script_path)
    if spec is None or spec.loader is None:
        msg = f"Could not load module spec for {script_path}"
        raise RuntimeError(msg)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class AnalyzePerfTraceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = _load_module()
        cls.budgets = cls.module.load_perf_budgets()

    def _frame_from_fixture(self, name: str) -> dict:
        path = TESTDATA / name
        raw = json.loads(path.read_text(encoding="utf-8"))
        trace_key = next(k for k in raw if k.endswith("_trace"))
        trace = raw[trace_key]
        events = list(self.module.iter_events(trace.get("traceEvents", [])))
        complete = self.module.collect_complete_spans(events)
        asyncs = self.module.collect_async_spans(events)
        return self.module.frame_metrics(complete=complete, asyncs=asyncs)

    def test_load_perf_budgets_defaults(self):
        budgets = self.module.load_perf_budgets()
        self.assertEqual(budgets.min_measured_frames, 100)
        self.assertEqual(budgets.p90_ms_max, 8.3)
        self.assertEqual(budgets.p99_ms_max, 16.7)
        self.assertEqual(budgets.over_16_7ms_ratio_max, 0.01)
        self.assertEqual(budgets.p90_regression_vs_median_max, 0.25)
        self.assertEqual(budgets.variance_report_only_threshold, 0.20)

    def test_pass_fixture_meets_budgets(self):
        frame = self._frame_from_fixture("pass_trace.json")
        result = self.module.evaluate_frame_budget_gate(frame, self.budgets)
        self.assertEqual(result.outcome, "pass")
        self.assertEqual(result.violations, ())
        self.assertGreaterEqual(frame["count"], 100)

    def test_fail_too_few_frames(self):
        frame = self._frame_from_fixture("fail_too_few_frames.json")
        result = self.module.evaluate_frame_budget_gate(frame, self.budgets)
        self.assertEqual(result.outcome, "fail")
        checks = {v.check for v in result.violations}
        self.assertIn("min_measured_frames", checks)

    def test_fail_p90_over_budget(self):
        frame = self._frame_from_fixture("fail_p90.json")
        result = self.module.evaluate_frame_budget_gate(frame, self.budgets)
        self.assertEqual(result.outcome, "fail")
        checks = {v.check for v in result.violations}
        self.assertIn("p90_ms_max", checks)

    def test_fail_p99_over_budget(self):
        frame = self._frame_from_fixture("fail_p99.json")
        result = self.module.evaluate_frame_budget_gate(frame, self.budgets)
        self.assertEqual(result.outcome, "fail")
        checks = {v.check for v in result.violations}
        self.assertIn("p99_ms_max", checks)

    def test_fail_over_16_7ms_ratio(self):
        frame = self._frame_from_fixture("fail_over_ratio.json")
        result = self.module.evaluate_frame_budget_gate(frame, self.budgets)
        self.assertEqual(result.outcome, "fail")
        checks = {v.check for v in result.violations}
        self.assertIn("over_16_7ms_ratio_max", checks)

    def test_variance_report_only_withholds_gate(self):
        frame = self._frame_from_fixture("pass_trace.json")
        baseline = [5.0, 5.0, 10.0]
        spread = self.module.baseline_relative_spread(baseline)
        self.assertGreater(spread, self.budgets.variance_report_only_threshold)
        result = self.module.evaluate_frame_budget_gate(
            frame,
            self.budgets,
            baseline_p90_ms=baseline,
        )
        self.assertEqual(result.outcome, "report_only")
        self.assertEqual(result.violations, ())
        self.assertIsNotNone(result.baseline_relative_spread)

    def test_p90_regression_fail(self):
        frame = {
            "count": 120,
            "p90_ms": 11.0,
            "p99_ms": 11.0,
            "over_16_7ms": 0,
        }
        baseline = [8.0, 8.0, 8.0]
        regression = self.module.p90_regression_ratio(11.0, 8.0)
        self.assertGreater(regression, self.budgets.p90_regression_vs_median_max)
        result = self.module.evaluate_frame_budget_gate(
            frame,
            self.budgets,
            baseline_p90_ms=baseline,
        )
        self.assertEqual(result.outcome, "fail")
        checks = {v.check for v in result.violations}
        self.assertIn("p90_regression_vs_median_max", checks)

    def test_analyze_trace_file_pass(self):
        summary = self.module.analyze_trace_file(TESTDATA / "pass_trace.json")
        trace = summary["traces"]["perf_trace"]
        self.assertEqual(trace["gate"], "pass")

    def test_cli_exit_nonzero_on_fail_trace(self):
        script = Path(__file__).with_name("analyze_perf_trace.py")
        result = __import__("subprocess").run(
            [sys.executable, str(script), str(TESTDATA / "fail_p90.json")],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 1, msg=result.stdout[-500:])

    def test_cli_exit_zero_on_pass_trace(self):
        script = Path(__file__).with_name("analyze_perf_trace.py")
        result = __import__("subprocess").run(
            [sys.executable, str(script), str(TESTDATA / "pass_trace.json")],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, msg=result.stdout[-500:])

    def test_classify_span_hints_build_and_raster(self):
        hints = self.module.classify_span_hints(
            ["BUILD", "Rasterizer::Draw", "unrelated"]
        )
        self.assertTrue(any("rebuild" in h for h in hints))
        self.assertTrue(any("Raster" in h for h in hints))

    def test_triage_next_steps_on_budget_miss(self):
        frame = {
            "count": 100,
            "p90_ms": 20.0,
            "p99_ms": 25.0,
            "over_8_3ms": 10,
            "over_16_7ms": 5,
        }
        steps = self.module.triage_next_steps(
            frame,
            gate_outcome="fail",
            top_complete=[{"name": "BUILD"}],
            top_async=[],
        )
        joined = "\n".join(steps)
        self.assertIn("symptom", joined.lower())
        self.assertIn("profile", joined.lower())
        self.assertIn("finding_jank_cause.md", joined)
        self.assertTrue(any("Span hint" in s for s in steps))

    def test_triage_ignores_lone_over_8_when_gate_pass(self):
        frame = {
            "count": 120,
            "p90_ms": 5.0,
            "p99_ms": 7.0,
            "over_8_3ms": 2,
            "over_16_7ms": 0,
        }
        steps = self.module.triage_next_steps(frame, gate_outcome="pass")
        joined = "\n".join(steps)
        self.assertIn("No frame-budget pressure", joined)
        self.assertNotIn("Frame-budget pressure detected", joined)

    def test_triage_report_only_withholds_pass_fail(self):
        frame = {
            "count": 120,
            "p90_ms": 5.0,
            "p99_ms": 7.0,
            "over_8_3ms": 0,
            "over_16_7ms": 0,
        }
        steps = self.module.triage_next_steps(frame, gate_outcome="report_only")
        joined = "\n".join(steps)
        self.assertIn("report-only", joined.lower())
        self.assertIn("recapture", joined.lower())
        self.assertNotIn("No frame-budget pressure", joined)
        self.assertNotIn("Frame-budget pressure detected", joined)

    def test_cli_triage_flag_prints_section(self):
        script = Path(__file__).with_name("analyze_perf_trace.py")
        result = __import__("subprocess").run(
            [
                sys.executable,
                str(script),
                str(TESTDATA / "pass_trace.json"),
                "--triage",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, msg=result.stdout[-500:])
        self.assertIn("Triage next steps", result.stdout)
        self.assertIn("finding_jank_cause.md", result.stdout)


if __name__ == "__main__":
    unittest.main()
