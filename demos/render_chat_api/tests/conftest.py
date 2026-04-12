"""Pytest setup: test auth bypass + generous rate limits."""

from __future__ import annotations

import os

# Must run before `main` / `settings` are imported by tests.
os.environ.setdefault("CALLER_AUTH_MODE", "test_bypass")
os.environ.setdefault("ALLOW_TEST_AUTH_BYPASS", "1")
os.environ.setdefault("CORS_ORIGINS", "http://testserver")
os.environ.setdefault("RATE_LIMIT_PER_UID_PER_MINUTE", "100000")
os.environ.setdefault("MAX_CONCURRENT_120B", "1")
