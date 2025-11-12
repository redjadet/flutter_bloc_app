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

- **Minor/Patch updates**: Grouped together as "dart-minor-patch"
- **Major updates**: Separated by category:
  - Flutter SDK major updates
  - Firebase major updates
  - BLoC major updates
- **Dev dependencies**: Patch updates are auto-merged (if tests pass)
- **Security updates**: Created immediately, regardless of schedule

### Backup: Dependabot

[Dependabot](https://docs.github.com/en/code-security/dependabot) is configured as a backup, primarily for security vulnerability monitoring.

**Configuration**: See `.github/dependabot.yml`

**Features**:

- Weekly security scans (Mondays at 9am UTC)
- Creates PRs only for security vulnerabilities
- Limited to 5 open PRs at a time

## Automated Testing

When Renovate or Dependabot creates a pull request, GitHub Actions automatically:

1. Runs `flutter pub get`
2. Runs `flutter analyze`
3. Runs `flutter test --coverage`
4. Enforces coverage threshold (60%)
5. Comments on the PR with test results

See `.github/workflows/dependency-updates.yml` for details.

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

### Tests failing on dependency updates

1. Review the test output in the PR
2. Check for breaking changes in the dependency
3. Update code if necessary to accommodate changes

### Dependency conflicts

1. Run `flutter pub get` to see detailed error messages
2. Check `pubspec.lock` for version conflicts
3. Consider using `dependency_overrides` temporarily (not recommended for production)
