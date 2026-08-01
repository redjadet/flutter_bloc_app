# Analytics consent StreamController dispose

## Summary

`SharedPreferencesAnalyticsConsentRepository` already closed `_changesController`
in a concrete `dispose()`, but that API was not on `AnalyticsConsentRepository`
and DI never invoked it on GetIt reset — so the leak remained for app lifetime
teardown / test resets.

- Add `dispose()` to `AnalyticsConsentRepository`
- Wire GetIt `dispose:` in `registerAnalyticsServices`
- Close fake consent controllers in tests; prove stream completes on dispose

## Validation

- `flutter test` analytics + production_readiness + analytics_consent_section
