#!/usr/bin/env python3
"""Regression for Dart 3.13 Freezed `final` parameter stripping."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "tool" / "strip_freezed_dart_313_params.py"


def _load_module():
    spec = importlib.util.spec_from_file_location(
        "strip_freezed_dart_313_params",
        MODULE_PATH,
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"unable to load {MODULE_PATH}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class StripFreezedDart313ParamsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.module = _load_module()

    def _strip(self, source: str) -> str:
        return self.module.strip_freezed_dart_313_params(source)

    def test_strips_required_final_constructor_params(self) -> None:
        source = (
            "  const ChatListLoaded("
            "{required final  List<ChatContact> contacts}"
            "): _contacts = contacts;\n"
        )
        out = self._strip(source)
        self.assertIn("required List<ChatContact> contacts", out)
        self.assertNotIn("required final", out)

    def test_strips_comma_final_hidden_field_params(self) -> None:
        source = (
            "  const _ChatState("
            "{this.isLoading = false, final  List<ChatMessage> messages = const <ChatMessage>[]}"
            "): _messages = messages;\n"
        )
        out = self._strip(source)
        self.assertIn(", List<ChatMessage> messages", out)
        self.assertNotIn("final  List<ChatMessage>", out)

    def test_keeps_final_that_local(self) -> None:
        source = (
            "TResult when<TResult>(TResult Function() $default,)"
            " {final _that = this;\n"
            "switch (_that) {\n"
        )
        out = self._strip(source)
        self.assertIn("{final _that = this;", out)

    def test_repairs_overstripped_that_local(self) -> None:
        source = (
            "TResult when<TResult>(TResult Function() $default,)"
            " { _that = this;\n"
            "switch (_that) {\n"
        )
        out = self._strip(source)
        self.assertIn("{final _that = this;", out)
        self.assertNotIn("{ _that = this;", out)

    def test_repairs_overstripped_value_local_after_brace(self) -> None:
        source = (
            "@override List<int>? get lastReadValue { value = _lastReadValue;\n"
            "  if (value == null) return null;\n"
        )
        out = self._strip(source)
        self.assertIn("{final value = _lastReadValue;", out)
        self.assertNotIn("{ value = _lastReadValue;", out)

    def test_keeps_value_local_when_final_still_present(self) -> None:
        source = (
            "@override List<int>? get lastReadValue {\n"
            "  final value = _lastReadValue;\n"
        )
        out = self._strip(source)
        self.assertEqual(out, source)

    def test_keeps_field_final(self) -> None:
        source = "  final List<ChatContact> _contacts;\n"
        out = self._strip(source)
        self.assertEqual(out, source)

    def test_strips_tool_script_main_args_final(self) -> None:
        source = "Future<void> main(final List<String> args) async {\n"
        out = self.module.strip_ordinary_final_parameters(source)
        self.assertIn("main( List<String> args)", out)
        self.assertNotIn("final List<String> args", out)

    def test_keeps_tool_script_local_final(self) -> None:
        source = "void foo() {\n  final root = Directory.current;\n}\n"
        out = self.module.strip_ordinary_final_parameters(source)
        self.assertEqual(out, source)

    def test_keeps_for_in_loop_final(self) -> None:
        source = "  for (final file in scanFiles) {\n"
        out = self.module.strip_ordinary_final_parameters(source)
        self.assertEqual(out, source)

    def test_repairs_overstripped_for_in_loop_final(self) -> None:
        source = "  for (file in scanFiles) {\n    await for (entity in root) {\n"
        out = self.module.strip_ordinary_final_parameters(source)
        self.assertIn("for (final file in scanFiles)", out)
        self.assertIn("await for (final entity in root)", out)


if __name__ == "__main__":
    unittest.main()
