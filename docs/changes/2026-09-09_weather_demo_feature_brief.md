# Feature: Weather Demo

Live city weather via Open-Meteo (no API key) under `/weather-demo`, entered from
the Example hub.

## Problem

Need a small Clean Architecture HTTP demo: geocode + forecast, typed failures,
and CC BY attribution without SecretConfig or location permissions.

## Scope

- In: Open-Meteo geocode/forecast over shared Dio (absolute URLs); sealed
  `WeatherFailure` / `WeatherState`; Cubit search/retry; Example hub + l10n;
  DI + GoRouter wiring
- Out: GPS; API keys; Freezed (hand-written primary constructors + sealed
  states); offline-first; deeplink map; profile nav

## Layers Touched

- [x] domain
- [x] data
- [x] presentation
- [x] DI
- [x] routes / l10n

## Contracts

- Repository: `WeatherRepository.fetchForCity`
- State: sealed `WeatherState` (`idle|loading|success|failure`)
- DTO / mapper: `WeatherGeocodeResult`, `WeatherForecastDto` → `WeatherSnapshot`

## Tests

### Behaviour

- [x] Scenario: search → success; empty query → invalidQuery; notFound
- [x] Files: `apps/mobile/test/features/weather_demo/presentation/weather_cubit_test.dart`

### State

- [x] Scenario: covered via Cubit emissions above
- [x] Files: same Cubit test

### Unit

- [x] Scenario: forecast/geocode DTO parse (+ hourly cap); mocked Dio repo/client
- [x] Files: `apps/mobile/test/features/weather_demo/data/weather_dto_test.dart`,
  `apps/mobile/test/features/weather_demo/data/weather_repository_impl_test.dart`

### Integration

- [x] Journey: N/A (hub deep-link only; covered by suite smoke when Example flows run)

### Proof Command

- [x] `cd apps/mobile && flutter test test/features/weather_demo`

## Docs

- [x] [`feature_overview.md`](../feature_overview.md), [`changes/2026-09-09_weather_notes_demos.md`](2026-09-09_weather_notes_demos.md)

## Risks

- Open-Meteo rate/availability; absolute URL required because Dio may have another `baseUrl`.
