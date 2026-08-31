# Dependency Update Monitoring

This project uses automated dependency update monitoring to keep dependencies up to date and secure.

## Tools

### Primary: Renovate

[Renovate](https://docs.renovatebot.com/) is the primary tool for automated dependency updates. It monitors `pubspec.yaml` and creates pull requests for dependency updates.

**Configuration**: See `renovate.json` in the project root.

**Features**:

- Groups minor/patch updates together
- Separates major version updates by category (Flutter SDK, Firebase, BLoC)
- Runs on weekdays only (9am-5pm UTC)
- Creates semantic commit messages
- Provides a dependency dashboard

**Update Strategy**:

- **Minor/Patch updates**: Grouped together as "dart-minor-patch" (`genui`, `google_sign_in_mocks`, and `intl` use separate `pub-coordinated-pins` group plus `allowedVersions` rules below)
- **Major updates**: Separated by category:
  - Flutter SDK major updates
  - Firebase major updates
  - BLoC major updates
- **Dev dependencies**: Patch updates are auto-merged (if tests pass)
- **Security updates**: Created immediately, regardless of schedule

**Coordinated pub pins** (see comments at top of `pubspec.yaml`; enforced in `renovate.json` via `allowedVersions` / `enabled: false`):

- `genui` — held below `0.8.0` while `genui_google_generative_ai` `0.7.x` requires `genui ^0.7`
- `google_sign_in_mocks` (dev) — held below `0.4.0` while `firebase_ui_oauth_google` stays on `google_sign_in` 6
- `intl` — held below `0.20.3` while `flutter_localizations` from the Flutter SDK pins `intl 0.20.2` (re-check when upgrading Flutter)
- `json_serializable` — `^6.14.0` with `dependency_overrides: analyzer: 10.0.2`, `dart_style: 3.1.4` (6.14+ needs analyzer ≥10; 10.0.2 aligns native plugin CLI with `analysis_server_plugin`). Path plugins `mix_lint` 2.x and `file_length_lint` use `analysis_server_plugin` via `analysis_options.yaml` `plugins:` + `path:`; `custom_lint` is not in the graph. Renovate caps `json_serializable` at `<7.0.0` and does not auto-bump `analyzer` / `analyzer_plugin`. Verify with `./tool/check_pubspec_codegen_compat.sh`; `upgrade_validate_all.sh` step 2b restores pins after major pub upgrades.
- `go_router` — held below `18.0.0`; 18.0.0 fails `./bin/integration_tests` with route/shell dispose ordering (`InheritedElement.debugDeactivated`, route-scoped `ProviderNotFoundException`). Re-run the full integration matrix before raising the caret. See [2026-08-31 change note](../changes/2026-08-31_pub_upgrade_flex_color_picker_go_router_defer.md) and [2026-08-24 upgrade validate](../changes/2026-08-24_upgrade_validate_go_router_freezed_fcm.md).

**Unresolvable majors (checked 2026-08-18):** `flutter pub outdated` reports Current == Resolvable for every leftover. Do not force these with `dependency_overrides`; pub solving already has the newest compatible graph.

| Package | Latest | Why it cannot bump yet |
| --- | --- | --- |
| `analyzer` / `_fe_analyzer_shared` / `dart_style` | 14.1.0 / 105.0.0 / 3.1.12 | Root override pins analyzer 10.0.2 + dart_style 3.1.4 for path lints + `json_serializable` 6.14 |
| `app_links` | 7.2.1 | `firebase_ui_auth` 3.1.0 (latest) requires `app_links ^6.4` |
| `genui` + `google_cloud_*` | genui 0.10.2 | `genui_google_generative_ai` 0.7.1 (latest) requires `genui ^0.7` |
| `google_sign_in*` / `google_sign_in_mocks` | 7.2.0 / 0.4.1 | `firebase_ui_oauth_google` 2.1.0 (latest) requires `google_sign_in ^6.2.1` |
| `email_validator` | override ^3.0.0 | genui wants ^3; `firebase_ui_auth` wants ^2.1.17 — override keeps the graph solvable |
| `melos` / `cli_util` / `pub_updater` | 8.3.0 / 0.5.2 / 0.6.0 | Melos 8 needs `cli_util ^0.5`; `flutter_launcher_icons` 0.14.4 (latest) needs `cli_util ^0.4.1`. Renovate holds melos `<7.8.2` for the same reason. |
| `go_router` | 18.0.0 | Integration matrix fails on 18 (dispose + route-scoped providers); pin `^17.5.0` until dedicated shell/route migration ([2026-08-31](../changes/2026-08-31_pub_upgrade_flex_color_picker_go_router_defer.md)) |
| `path_provider_foundation` | 2.6.0 | 2.6.0 is the iOS 26.x simulator FFI crash; pin stays 2.5.1 ([`workarounds.md`](workarounds.md)) |
| `test` / `test_api` / `test_core` / `material_color_utilities` / `dbus` / `package_config` | patch-ahead | SDK or rdep pins; not independently resolvable |

### Backup: Dependabot

[Dependabot](https://docs.github.com/en/code-security/dependabot) is configured as a backup, primarily for security vulnerability monitoring.

**Configuration**: See `.github/dependabot.yml`

**Features**:

- Weekly security scans (Mondays at 9am UTC)
- Creates PRs only for security vulnerabilities
- Limited to 5 open PRs at a time
- Also scans root `Gemfile.lock` (Fastlane / Ruby) for security advisories

**Ruby / Fastlane (`Gemfile`)**: When Rubygems `fastlane` lags a security fix (for example `jwt` CVE-2026-45363), the repo may temporarily pin `fastlane` to a GitHub ref that widens the `jwt` constraint, plus `gem 'jwt', '~> 3.2'`. Revert to a Rubygems `fastlane` version once it ships with the same constraint (for example `2.235.0`).

## Automated Testing

When Renovate or Dependabot creates a pull request, GitHub Actions automatically:

1. Runs `flutter pub get`
2. Runs `flutter analyze`
3. Runs `flutter test --coverage`
4. Enforces coverage threshold (75% filtered rollup)
5. Comments on the PR with test results

See `.github/workflows/dependency-updates.yml` for details.

**Renovate `renovate/artifacts` check:** Often fails on this Flutter workspace when the bot runs `dart pub` instead of `flutter pub`. Treat artifacts as **non-blocking** for merge triage when required `build` / dependency-updates checks are green. Prefer `bash tool/commit_push_pr_watch_merge_cleanup.sh` over ad-hoc check polling; see [`validation_scripts/upgrade_pr_triage_validate.md`](../validation_scripts/upgrade_pr_triage_validate.md) and [`agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md) § Durable Prefs.

## Adopt a package or implement locally

Choose by ownership cost, not line count alone:

| Situation | Default | Required checks |
| --- | --- | --- |
| Hard, solved infrastructure such as HTTP, serialization, crypto primitives, or platform integration | Prefer a trusted package | Recent releases/commits, issue and security posture, null safety, license, transitive dependencies, binary size, migration policy, and verified iOS/Android/Web/macOS support |
| Small stable helper with no platform or security complexity | Implement locally | Clear tests; confirm existing SDK/repo utilities do not already solve it |
| Product-defining domain behavior | Own the code behind domain contracts | Explicit invariants, focused tests, and an ADR when the choice is cross-cutting or costly to reverse |
| Available packages are bloated, abandoned, unsafe, or miss required platforms | Implement a narrow adapter/local solution | Record rejected options and the trigger for reevaluating the ecosystem |

Before adoption, check the pinned resolver constraints and read the actual API
through [`package_docs_mcp.md`](../agent_kb/package_docs_mcp.md). “Latest” is not
proof of compatibility. Wrap external APIs behind the narrowest honest boundary
when replacement, testing, or platform fallbacks are plausible; do not add an
abstraction only to hide a two-line helper.

## Manual Dependency Updates

To manually check for outdated dependencies:

```bash
flutter pub outdated
```

To upgrade dependencies:

```bash
# Upgrade to latest compatible versions
flutter pub upgrade

# Upgrade to latest versions (including major versions)
flutter pub upgrade --major-versions
```

## Reviewing Dependency Updates

1. **Check the Renovate Dashboard**: Visit the Renovate dashboard issue in GitHub to see all pending updates.

2. **Review PRs**: Each update PR includes:
   - Changelog links
   - Release notes
   - Breaking changes (if any)

3. **Test Before Merging**: All PRs are automatically tested, but you should:
   - Review the changes
   - Test locally if needed
   - Check for breaking changes

## Configuration Files

- `renovate.json` - Renovate configuration
- `.github/dependabot.yml` - Dependabot configuration
- `.github/workflows/dependency-updates.yml` - Automated testing workflow

## Best Practices

1. **Review Regularly**: Check the Renovate dashboard weekly
2. **Merge Minor/Patch Updates**: These are generally safe and grouped together
3. **Test Major Updates**: Major version updates may include breaking changes
4. **Keep Security Updates Current**: Security updates are created immediately
5. **Monitor CI/CD**: Ensure automated tests pass before merging

## Disabling Updates

To temporarily disable updates for a specific package, add a comment to `renovate.json`:

```json
{
  "packageRules": [
    {
      "matchPackageNames": ["package-name"],
      "enabled": false
    }
  ]
}
```

## Troubleshooting

### Renovate not creating PRs

1. Check if Renovate is installed in your GitHub repository
2. Verify `renovate.json` syntax is valid
3. Check the Renovate dashboard issue for errors

### Dependency Dashboard (issue #2) warnings

[Issue #2](https://github.com/redjadet/flutter_bloc_app/issues/2) is Renovate’s **Dependency Dashboard** (`:dependencyDashboard` in `renovate.json`). It is meant to stay **open**; Renovate updates the body each run. Do not close it unless you remove `:dependencyDashboard` from `renovate.json`.

| Dashboard message | Cause | Action |
| --- | --- | --- |
| `Failed to look up maven package dev.flutter.flutter-plugin-loader` | Plugin ID is resolved via Gradle plugin portal, not Maven Central | Listed in `renovate.json` `ignoreDeps` and Gradle rule (`enabled: false`). Upgrade the version in `android/settings.gradle` with Flutter/SDK release notes. |
| `pubspec-compat` fails after a dependency PR bumps codegen or analyzer | `json_serializable` 6.14+ needs analyzer ≥10; path lints need matching `analysis_server_plugin` / overrides | Keep `json_serializable: ^6.14.0` and `dependency_overrides` (`analyzer: 10.0.2`, `dart_style: 3.1.4`). Run `./tool/check_pubspec_codegen_compat.sh`. Rebase or close the Renovate PR and restore pins via `upgrade_validate_all.sh` step 2b if needed. |
| `Custom registries are not allowed for this datasource` | Harmless Renovate warning when `Gemfile` pins `fastlane` from GitHub (`git-refs` datasource); see [renovate#37432](https://github.com/renovatebot/renovate/issues/37432) | Safe to ignore until `fastlane` returns to a Rubygems release (see `Gemfile` comment). |
| Rate-limited / blocked PRs | Renovate concurrency or manual edit/close | Use checkboxes on the dashboard or merge open dependency PRs; see **PR Edited (Blocked)** / **PR Closed (Blocked)** sections. |

### Dependency update workflow fails to comment on the PR (403)

If the **Dependency Updates** workflow fails with:

- `Resource not accessible by integration` (HTTP 403) when calling `issues.createComment`

It usually means the workflow run does not have the required token permissions to
write issue/PR comments (common on `pull_request` workflows depending on repo/org
policy).

Fix options:

- Ensure `.github/workflows/dependency-updates.yml` includes appropriate
  `permissions:` (at least `issues: write`).
- Make the “comment results” step best-effort (for example with
  `continue-on-error: true`) so tests still report pass/fail even if the comment
  cannot be posted.

### Tests failing on dependency updates

1. Review the test output in the PR
2. Check for breaking changes in the dependency
3. Update code if necessary to accommodate changes

### Dependency conflicts

1. Run `flutter pub get` to see detailed error messages
2. Check `pubspec.lock` for version conflicts
3. Consider using `dependency_overrides` temporarily (not recommended for production)
