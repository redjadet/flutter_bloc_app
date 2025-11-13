# SharedPreferences to Isar Database Migration

## Overview

This document describes the migration from SharedPreferences to Isar database with built-in encryption support for iOS and Android platforms.

## Database Choice: Isar

**Selected:** Isar (over Realm and Hive)

### Why Isar?

- ✅ Built-in AES-256 encryption (no additional plugins needed)
- ✅ Superior performance (10ms vs 250ms for 15K objects in benchmarks)
- ✅ Active maintenance and Flutter-first design
- ✅ Type-safe with code generation
- ✅ Cross-platform support (iOS/Android)

### Why Not Realm?

- ❌ Realm Flutter support is **deprecated** with end-of-life set for September 2025
- ❌ Slower performance compared to Isar
- ❌ Not future-proof for Flutter projects

## Important: Dependency Conflict

**Current Status:** There is a known dependency conflict between `isar_generator ^3.1.0+1` and `freezed ^3.2.3`:

- `isar_generator >=3.0.0` requires `source_gen ^1.2.2`
- `freezed ^3.2.3` requires `source_gen >=3.0.0 <5.0.0`

These requirements are incompatible.

### Resolution Options

1. **Wait for Isar Update**: Monitor Isar repository for updates that support newer `source_gen` versions
2. **Downgrade Freezed**: Use `freezed ^2.4.7` (compatible with `source_gen ^1.2.2`) - may require code changes
3. **Use Dependency Override**: Force a compatible `source_gen` version (risky, may break other generators)
4. **Alternative Database**: Consider Hive with encryption plugin if the conflict cannot be resolved

### Temporary Workaround

To proceed with implementation, you may need to:

- Temporarily disable `file_length_lint` (also has analyzer version conflicts)
- Use dependency overrides (documented in `pubspec.yaml`)
- Or wait for package updates

## Architecture

### Repository Pattern

The migration maintains the existing clean architecture:

```text
Domain Layer (Interfaces)
    ↓
Data Layer (Isar Implementations)
    ↓
Isar Database (Encrypted Storage)
```

### Components

1. **Isar Models** (`lib/shared/storage/isar_models.dart`)
   - `CounterSnapshotModel`: Stores counter state
   - `LocalePreferenceModel`: Stores locale preference
   - `ThemePreferenceModel`: Stores theme preference
   - `MigrationStatusModel`: Tracks migration completion

2. **IsarKeyManager** (`lib/shared/storage/isar_key_manager.dart`)
   - Generates 256-bit encryption keys
   - Stores keys in `flutter_secure_storage`
   - Retrieves keys for database initialization

3. **IsarService** (`lib/shared/storage/isar_service.dart`)
   - Singleton service for Isar database instance
   - Handles initialization with encryption
   - Manages database lifecycle

4. **Repository Implementations**
   - `IsarCounterRepository`: Counter data with watch() stream support
   - `IsarLocaleRepository`: Locale preference storage
   - `IsarThemeRepository`: Theme preference storage

5. **Migration Service** (`lib/shared/storage/shared_preferences_migration_service.dart`)
   - Detects if migration is needed
   - Migrates data from SharedPreferences to Isar
   - Marks migration as complete

## Implementation Details

### Encryption Key Management

- **Generation**: 256-bit key using `Random.secure()`
- **Storage**: Keys stored in `flutter_secure_storage` with key `isar_encryption_key`
- **Retrieval**: Keys retrieved on Isar initialization
- **Format**: Base64 encoded for storage

### Migration Strategy

1. **Check Migration Status**: Query `MigrationStatusModel` in Isar
2. **Read from SharedPreferences**: If not migrated, read existing data
3. **Write to Isar**: Store data in Isar collections
4. **Mark Complete**: Set migration flag to prevent re-migration
5. **Error Handling**: Graceful fallback if migration fails

### Data Models

All models use a single-instance pattern with `id = 0`:

- Simplifies queries (no need for complex IDs)
- Matches SharedPreferences key-value pattern
- Easy to migrate and maintain

## Migration Steps

### 1. Add Dependencies

```yaml
dependencies:
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.1

dev_dependencies:
  isar_generator: ^3.1.0+1
```

**Note**: Resolve dependency conflicts before proceeding (see above).

### 2. Generate Isar Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Initialize Isar in App

Migration runs automatically in `main_bootstrap.dart`:

```dart
await configureDependencies();
await getIt<SharedPreferencesMigrationService>().migrateIfNeeded();
```

### 4. Update Dependency Injection

All repositories are registered in the dependency injection system (`lib/core/di/injector_registrations.dart`, called from `lib/core/di/injector.dart`):

- `IsarKeyManager` → `IsarService` → Repositories
- Migration service runs on app startup

## Testing

### Unit Tests

- Test Isar repositories with in-memory instances
- Test migration service with mock SharedPreferences
- Test encryption key generation and storage

### Integration Tests

- Test migration flow from SharedPreferences to Isar
- Test data persistence across app restarts
- Test encryption/decryption functionality

## Troubleshooting

### Dependency Conflicts

If you encounter dependency conflicts:

1. Check `pubspec.yaml` for version constraints
2. Review Isar and Freezed compatibility
3. Consider using dependency overrides (with caution)
4. Monitor package updates

### Migration Issues

If migration fails:

1. Check logs for specific errors
2. Verify SharedPreferences data exists
3. Ensure Isar database initializes correctly
4. Migration will retry on next app launch

### Encryption Key Issues

If encryption key retrieval fails:

1. Check `flutter_secure_storage` permissions
2. Verify key generation logic
3. Check platform-specific secure storage availability
4. App will generate a temporary key (data won't persist)

## Performance Considerations

- Isar initialization is async - handled in app startup
- Use Isar watchers for reactive streams (CounterRepository.watch())
- Batch operations during migration for efficiency
- Database operations are non-blocking

## Rollback Plan

If issues arise:

1. Keep SharedPreferences repositories as fallback
2. Add feature flag to switch between Isar and SharedPreferences
3. Monitor error logs for database issues
4. Can revert DI registrations quickly

## Future Improvements

1. **Resolve Dependency Conflicts**: Update when Isar supports newer `source_gen`
2. **Key Rotation**: Implement encryption key rotation mechanism
3. **Migration Cleanup**: Remove SharedPreferences after migration period
4. **Performance Monitoring**: Add metrics for database operations
5. **Backup/Restore**: Implement data backup and restore functionality

## References

- [Isar Documentation](https://isar.dev/)
- [Isar GitHub](https://github.com/isar/isar)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## Migration Checklist

- [x] Add Isar dependencies
- [x] Create Isar models
- [x] Implement encryption key manager
- [x] Create Isar service
- [x] Implement Isar repositories
- [x] Create migration service
- [x] Update dependency injection
- [x] Integrate migration in app initialization
- [ ] Resolve dependency conflicts
- [ ] Generate Isar code (blocked by conflicts)
- [ ] Update unit tests
- [ ] Run delivery checklist
- [ ] Remove SharedPreferences (after migration period)

## Notes

- SharedPreferences repositories are kept temporarily for migration
- Migration runs automatically on first launch after update
- All data is encrypted at rest using AES-256
- Encryption keys are stored securely using platform keychain/keystore
