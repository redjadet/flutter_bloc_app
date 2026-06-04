# Event Bus demo (Example page entry)

**Date:** 2026-06-04

## Summary

- New **`event_bus_demo`** feature: typed `EventBus` events (`UserLoggedInEvent`, `UserLoggedOutEvent`), login panel firing events, home + notification panels listening on the same page (Medium article flow).
- **Example page**: "Open Event Bus demo" button (`example-event-bus-demo-button`) → `AppRoutes.eventBusDemo`.
- **DI**: demo-scoped `EventBus` singleton with `destroy` on dispose (`register_event_bus_demo_services.dart`).
- **Routing / deeplink**: `/event-bus-demo`, `DeepLinkTarget.eventBusDemo`.
- **l10n**: strings in all supported locales; `untranslated_messages.json` empty.
- **Tests**: bus unit, page widget, example body, router/deeplink guards; iOS integration flow `integration_test/event_bus_demo_flow_test.dart` (Example → demo → login). Harness ignores simulator Hive secure-storage fallback log.

## Verification

```bash
./tool/analyze.sh
./bin/router_feature_validate
flutter test test/features/event_bus_demo test/features/example/presentation/widgets/example_page_body_test.dart test/app/router/routes_demos_includes_iap_test.dart test/core/router/app_routes_test.dart test/features/deeplink
./bin/checklist
./bin/integration_tests
```
