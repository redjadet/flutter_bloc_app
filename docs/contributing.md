# Contributing

Contributions are welcome! Please follow these guidelines to ensure consistency and quality.

## Before Submitting

1. **Run the checklist** before submitting PRs: `./bin/checklist`
2. **Write tests** for new features
3. **Update documentation** as needed
4. **Follow Clean Architecture** principles

## Code Standards

### Architecture

- **Follow Clean Architecture**: Domain → Data → Presentation
- **Use dependency injection**: Inject dependencies via constructors, not `getIt` in widgets
- **Respect layer boundaries**: Domain never imports Flutter, Data never imports Presentation

### UI/UX

- **Use responsive extensions** for UI components (`context.responsive*`)
- **Use platform-adaptive components** (`PlatformAdaptive.*` helpers, never raw Material buttons)
- **Use theme-aware colors** (`Theme.of(context).colorScheme`, never hard-coded colors)
- **Use localization** (`context.l10n.*`, never hard-coded strings)
- **Handle safe areas and keyboard** (use `CommonPageLayout` or handle manually)
- **Test text scaling** (1.3+ scale) and accessibility

### Code Quality

- **Keep files under 250 lines** (enforced by linter)
- **Use `const` constructors** where possible
- **Follow SOLID principles**: See `docs/solid_principles.md`
- **Apply DRY principles**: See `docs/dry_principles.md`

## Testing Requirements

- Write unit tests for business logic
- Write bloc tests for state management
- Write widget tests for UI components
- Add golden tests for visual regression
- Ensure tests pass: `flutter test`

## Documentation

- Update relevant documentation files in `docs/`
- Add code comments for complex logic
- Update README if adding major features

## Validation

The `./bin/checklist` command automatically validates:

- Code formatting
- Static analysis
- Architecture violations
- UI/UX best practices
- Test coverage

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
