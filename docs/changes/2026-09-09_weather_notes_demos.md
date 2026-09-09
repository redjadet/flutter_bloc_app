# Weather + Notes demos

Added `weather_demo` (Open-Meteo live HTTP, no API key) and `notes_demo` (Hive local CRUD with AlertDialog editor). Both wired through demo DI, GoRouter, and the Example hub.

Primary constructors used for domain/DTO/service classes; sealed Dart states used instead of Freezed for these demos to avoid Freezed/primary-constructor codegen friction on the current toolchain.
