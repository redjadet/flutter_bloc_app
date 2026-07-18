# Validation scripts — manual execution

Router: [`../validation_scripts.md`](../validation_scripts.md).

## Manual Execution

You can run individual scripts manually:

```bash
# Check for context.mounted issues
bash tool/check_context_mounted.sh

# Check for hard-coded colors
bash tool/check_hardcoded_colors.sh

# Check for hard-coded strings
bash tool/check_hardcoded_strings.sh

# Check for missing isClosed checks
bash tool/check_cubit_isclosed.sh

# Check lifecycle and error-handling (snackbar, stream.listen onError, dialog mounted)
bash tool/check_lifecycle_error_handling.sh

# Check offline-first stale-sync regression (don't overwrite newer state)
bash tool/check_offline_first_remote_merge.sh

# Check for missing const constructors (heuristic)
bash tool/check_missing_const.sh

# Check SOLID layering
bash tool/check_solid_presentation_data_imports.sh
bash tool/check_solid_data_presentation_imports.sh

# Check performance heuristics
bash tool/check_perf_shrinkwrap_lists.sh
bash tool/check_perf_nonbuilder_lists.sh
bash tool/check_perf_missing_repaint_boundary.sh
bash tool/check_perf_unnecessary_rebuilds.sh

# Check for concurrent modification issues
bash tool/check_concurrent_modification.sh

# Check memory heuristics
bash tool/check_memory_unclosed_streams.sh
bash tool/check_memory_missing_dispose.sh
bash tool/check_dialog_controller_dispose.sh
bash tool/check_dialog_text_controller_lifecycle.sh
```

## Suppressing Violations

All scripts support `check-ignore` comment pattern:

```dart
// check-ignore: reason for ignoring
Navigator.of(context).pop(); // This line will be ignored

// Or on the same line:
Navigator.of(context).pop(); // check-ignore: temporary debug code
```

**Important**: Always provide reason when using `check-ignore`. Ignored violations are reported in script output.

## Script Output

Each script provides:

1. **Status message**: What is being checked
2. **Ignored violations**: Items with `check-ignore` comments (with reasons)
3. **Violations**: Actual issues that need to be fixed
4. **Exit code**: `0` for success, `1` for failures (heuristic checks may exit `0` with warnings)

## Best Practices

1. **Run checklist for broad or pre-ship validation**: `./bin/checklist`
   catches issues early when you need full sweep
2. **Use checklist-fast only for local sanity**: `./bin/checklist-fast`
   is intentionally narrow and should not replace full gate for app/runtime work
3. **Fix violations immediately**: Don't accumulate technical debt
4. **Use check-ignore sparingly**: Only when there's legitimate reason
5. **Review heuristic warnings**: Scripts like `check_missing_const.sh` and `check_side_effects_build.sh` are heuristics - review manually
6. **Keep scripts updated**: As codebase patterns evolve, update scripts accordingly

## Related Documentation

- **Developer onboarding**: [`../new_developer_guide.md`](../new_developer_guide.md)
- **UI/UX Guidelines**: [`../ui_ux_responsive_review.md`](../review/ui_ux_responsive_review.md)
- **Testing Best Practices**: [`../testing_overview.md`](../testing_overview.md)
- **Common Bugs Prevention Tests**: `test/shared/common_bugs_prevention_test.dart`
