import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';

/// Contract for repositories that can participate in global sync.
abstract class SyncableRepository {
  /// Entity type identifier that must match queued [SyncOperation.entityType].
  String get entityType;

  /// Pulls latest remote state when network is available.
  Future<void> pullRemote();

  /// Processes a pending sync operation that was queued while offline.
  Future<void> processOperation(final SyncOperation operation);
}
