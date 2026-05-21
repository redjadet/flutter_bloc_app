# OverflowBar PRIMARY_SCOPE inventory

Date: 2026-05-21. Folder-first scan for horizontal action-row overflow risk.

## Status (v1 + v2)

| Gate | Result |
| ---- | ------ |
| `tool/check_row_action_overflow.sh` (primary + all + fixtures) | **pass** |
| `tool/check_action_bar_layout.sh` | **pass** (4 tests) |
| Class A staff signature | `ResponsiveActionOverflowBar` |
| Class B auth / booking | `ResponsiveDualCtaRow` (360dp available-width stack) |
| Cupertino pickers (all-scope) | `ResponsiveActionOverflowBar` in date picker + platform sheets |
| Shared helper | `lib/shared/widgets/responsive_action_bar.dart` |

## Two-layer guard (dual CTA)

| Layer | What it checks |
| ----- | -------------- |
| **Call site** (`logged_out_action_buttons.dart`, booking confirm, …) | No raw `Row(` + 2 buttons; use `ResponsiveDualCtaRow` or `ResponsiveActionOverflowBar`. Script ignores `ResponsiveDualCtaRow(` as a `Row(` match. |
| **Canonical impl** (`lib/shared/widgets/responsive_action_bar.dart`) | In PRIMARY_SCOPE: the real `Row(` + `Expanded` + dual children must keep `Expanded`. |
| **Repo-wide** (`scope=all`) | Any new raw multi-button `Row(` elsewhere in `lib/`. |
| **Runtime** | `responsive_dual_cta_row_layout_test.dart` + `logged_out_action_buttons_test.dart` at 320dp. |

Reverting a call site to `Row(children: [OutlinedButton, FilledButton])` without `Expanded` is caught on **all** pass. Reverting only the helper’s internal `Row` is caught on **primary** (helper file listed explicitly).

## Static check

- Script: `tool/check_row_action_overflow.sh`
- Default: `scope=primary`, then `scope=all` when `CHECK_ROW_ACTION_OVERFLOW_ALSO_ALL=1` (default)
- Fixtures: `tool/check_row_action_overflow_fixtures.sh` (`bad_row_two_buttons`, `good_overflow_bar`, `good_dual_cta_responsive`)
- Awk: 80-line window after standalone `Row(` (excludes `ResponsiveDualCtaRow`, `IconLabelRow`, etc.); mitigations include `ResponsiveDualCtaRow`, `ResponsiveActionOverflowBar`, `Expanded`, …

## Class A — migrated to OverflowBar / helper

| File | Mitigation |
| ---- | ---------- |
| `staff_demo_proof_signature_section.dart` | `ResponsiveActionOverflowBar` |
| `todo_list_date_picker.dart` | `ResponsiveActionOverflowBar` (center) |
| `platform_adaptive_sheets.dart` | `ResponsiveActionOverflowBar` (Cupertino picker) |

## Class B — dual CTA (equal split / stack)

| File | Mitigation |
| ---- | ---------- |
| `logged_out_action_buttons.dart` | `ResponsiveDualCtaRow` |
| `online_therapy_demo_client_booking_confirm_page.dart` | `ResponsiveDualCtaRow` |

Supabase feature paths: no `Row(` + dual Material/Cupertino action buttons flagged at inventory time.

## Class C — dialog `actions`

Dialog-related files under `lib/features/` mostly use `AlertDialog.actions`
(framework overflow). No manual action `Row` required. Refresh count with
`rg --files -g '*dialog*.dart' lib/features | wc -l`.

## Class D/E/F — high-signal (no change)

| File | Class | Notes |
| ---- | ----- | ----- |
| `profile_action_buttons.dart` | — | Vertical `Column` CTAs |
| `profile_gallery.dart` | D/F | Gallery strip |
| `register_form.dart` | E/D | Form fields |
| `todo_batch_actions_bar.dart` | F | `Wrap` (reference) |
| `common_form_field.dart` | E | Dropdown row |
| `chat_history_sheet.dart` | — | `IconLabelRow` for actions |

## PRIMARY_SCOPE `Row(` sample (rg)

Sample lines with `Row(` in presentation/widgets and profile/settings
(2026-05-21). Use the PRIMARY_SCOPE file-list command from the plan to refresh
the full inventory.

```text
lib/features/staff_app_demo/.../staff_demo_proof_signature_section.dart:82  (title row, not actions)
lib/features/auth/.../register_country_picker.dart:108
lib/features/auth/.../register_phone_field.dart:33
lib/features/profile/.../profile_gallery.dart:29
lib/features/chat/.../chat_input_bar.dart:36
lib/features/example/.../whiteboard_toolbar.dart:103
… (see rg output in repo)
```

## Regression tests

- `test/shared/widgets/action_bar_layout_regression_test.dart`
- `test/shared/widgets/responsive_dual_cta_row_layout_test.dart` (canonical dual CTA `Row`/`Column`)
- `test/features/staff_app_demo/presentation/widgets/staff_demo_proof_signature_section_layout_test.dart`
- `test/features/auth/presentation/widgets/logged_out_action_buttons_test.dart` (320dp stack + overflow capture)
- `test/features/online_therapy_demo/presentation/pages/online_therapy_demo_client_booking_confirm_page_layout_test.dart` (320dp booking CTAs)

Run: `bash tool/check_action_bar_layout.sh` or `CHECKLIST_RUN_ACTION_BAR_LAYOUT_TESTS=1 ./bin/checklist`.
