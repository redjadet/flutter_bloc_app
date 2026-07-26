# Integration dart-define argv split

## Summary

`tool/run_integration_tests.sh` collected `flutter_dart_defines_from_env.sh`
output with a line-oriented `read`, packing every `--dart-define=KEY=value`
token into **one** argv. Flutter then treated the first key’s value as
`REAL_KEY --dart-define=NEXT=...`, overriding the direnv flutter wrapper’s
correct defines. Android guest sign-in failed with “API key not valid”; iOS
kept working via simulator local-guest when iOS defines stayed clean.

## Fix

Word-split defines into separate array entries (same pattern as
`tool/direnv/bin/flutter`). Regression:
`tool/run_integration_tests_dart_defines_test.py`.

## Validation

```bash
python3 -m unittest tool/run_integration_tests_dart_defines_test.py -v
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 \
INTEGRATION_TESTS_RUN_PREFLIGHT=0 \
INTEGRATION_TESTS_RUN_COVERAGE=0 \
./bin/integration_tests integration_test/guest_sign_in_flow_test.dart
```
