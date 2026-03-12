# Contributing

Contributions are welcome! Please follow these guidelines to ensure consistency and quality.

**For setup, development workflow, and validation details**, see [new_developer_guide](new_developer_guide.md) and [validation_scripts](validation_scripts.md).

## Before Submitting

1. **Run the checklist** before submitting PRs: `./bin/checklist`
2. **Write tests** for new features
3. **Update documentation** as needed
4. **Follow Clean Architecture** principles (see [clean_architecture.md](clean_architecture.md))

## Validation

The `./bin/checklist` command automatically validates:

- Code formatting for changed Dart files
- Static analysis and validation scripts for code-relevant changes
- Architecture violations
- UI/UX best practices
- Test coverage

The checklist also avoids unnecessary work:

- `flutter pub get` runs only when dependency metadata changed
- docs-only change sets exit early instead of running code validation
- Mix lint and focused Todo layout regressions are skipped automatically when unrelated to the current change set

All checks must pass before merging.

## Related Documentation

### Getting Started

- [New Developer Guide](new_developer_guide.md) - Comprehensive getting started guide for new developers
- [Feature Overview](feature_overview.md) - Catalog of features and capabilities

### Architecture & Design

- [Clean Architecture](clean_architecture.md) - Layer responsibilities, examples, and review checklist
- [Architecture Details](architecture_details.md) - Architecture diagrams and principles
- [SOLID Principles](solid_principles.md) - Detailed SOLID principles with codebase examples
- [DRY Principles](dry_principles.md) - DRY consolidations and patterns
- [Code Quality](CODE_QUALITY.md) - Comprehensive code quality analysis including architecture compliance

### Development Guidelines

- [UI/UX Guidelines](ui_ux_responsive_review.md) - Responsive design and platform adaptation
- [Flutter Best Practices Review](flutter_best_practices_review.md) - Best practices audit with action checklist
- [Testing Overview](testing_overview.md) - Testing strategy and patterns
- [Validation Scripts](validation_scripts.md) - Automated validation scripts and their purposes
