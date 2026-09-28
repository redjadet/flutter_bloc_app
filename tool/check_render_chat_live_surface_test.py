"""Offline unit tests for render chat live OpenAPI surface validation."""

from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parent
ROOT = TOOL_ROOT.parent
if str(TOOL_ROOT) not in sys.path:
    sys.path.insert(0, str(TOOL_ROOT))

from render_chat_live_surface import (  # noqa: E402
    REQUIRED_OPENAPI_PATHS,
    format_report,
    load_openapi_json,
    main,
    required_paths_missing,
)


class RenderChatLiveSurfaceTest(unittest.TestCase):
    def test_required_paths_constant_matches_w12_contract(self) -> None:
        self.assertEqual(
            REQUIRED_OPENAPI_PATHS,
            ("/health", "/ready", "/v1/chat/completions"),
        )

    def test_missing_ready_is_reported(self) -> None:
        document = {
            "openapi": "3.1.0",
            "paths": {
                "/health": {},
                "/v1/chat/completions": {},
            },
        }
        self.assertEqual(required_paths_missing(document), ["/ready"])

    def test_complete_surface_has_no_missing(self) -> None:
        document = {
            "paths": {
                "/health": {},
                "/ready/": {},
                "v1/chat/completions": {},
            }
        }
        self.assertEqual(required_paths_missing(document), [])

    def test_load_rejects_non_object(self) -> None:
        with self.assertRaises(ValueError):
            load_openapi_json("[]")

    def test_format_report_fail_mentions_redeploy(self) -> None:
        report = format_report(
            origin="https://example.test/",
            present=["/health"],
            missing=["/ready"],
        )
        self.assertIn("https://example.test", report)
        self.assertIn("missing required: /ready", report)
        self.assertIn("Redeploy", report)

    def test_main_exits_nonzero_when_ready_missing(self) -> None:
        payload = {
            "openapi": "3.1.0",
            "info": {"title": "fixture", "version": "0"},
            "paths": {
                "/health": {},
                "/v1/chat/completions": {},
            },
        }
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            suffix=".json",
            delete=False,
        ) as handle:
            json.dump(payload, handle)
            path = handle.name
        try:
            code = main(["--origin", "https://fixture.test", path])
        finally:
            Path(path).unlink(missing_ok=True)
        self.assertEqual(code, 1)

    def test_main_ok_for_complete_fixture(self) -> None:
        payload = {
            "openapi": "3.1.0",
            "paths": {
                "/health": {},
                "/ready": {},
                "/v1/chat/completions": {},
            },
        }
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            suffix=".json",
            delete=False,
        ) as handle:
            json.dump(payload, handle)
            path = handle.name
        try:
            code = main(["--origin", "https://fixture.test", path])
        finally:
            Path(path).unlink(missing_ok=True)
        self.assertEqual(code, 0)


if __name__ == "__main__":
    unittest.main()
