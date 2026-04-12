"""Shared orchestration exceptions."""


class Saturation(Exception):
    """Raised when 120B concurrency slots are exhausted (maps to HTTP 503)."""
