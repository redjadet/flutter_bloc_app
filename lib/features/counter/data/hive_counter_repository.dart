import 'dart:async';

import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository_helpers.dart';
import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository_watch_helper.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';

/// Hive-backed implementation of [CounterRepository].
class HiveCounterRepository extends HiveRepositoryBase
    implements CounterRepository {
  HiveCounterRepository({required super.hiveService}) {
    _watchHelper = HiveCounterRepositoryWatchHelper(
      loadSnapshot: () => load(),
      emptySnapshot: _emptySnapshot,
      getBox: () => getBox(),
    );
  }

  static const String _boxName = 'counter';
  static const String _keyCount = 'count';
  static const String _keyChanged = 'last_changed';
  static const String _keyUserId = 'user_id';
  static const String _localUserId = 'local';
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(
    userId: _localUserId,
    count: 0,
  );

  @override
  String get boxName => _boxName;

  late final HiveCounterRepositoryWatchHelper _watchHelper;

  @override
  Future<CounterSnapshot> load() async => StorageGuard.run<CounterSnapshot>(
    logContext: 'HiveCounterRepository.load',
    action: () async {
      final Box<dynamic> box = await getBox();

      // Safely extract count with type validation
      final dynamic countValue = box.get(_keyCount, defaultValue: 0);
      final int count = countValue is int
          ? countValue
          : (countValue is num ? countValue.toInt() : 0);

      // Safely extract timestamp with validation
      final dynamic changedMsValue = box.get(_keyChanged);
      final int? changedMs = changedMsValue is int
          ? changedMsValue
          : (changedMsValue is num ? changedMsValue.toInt() : null);

      // Validate DateTime before creating
      final DateTime? changed = HiveCounterRepositoryHelpers.parseTimestamp(
        changedMs,
      );

      // Safely extract userId
      final dynamic userIdValue = box.get(_keyUserId);
      final String? userId = userIdValue is String && userIdValue.isNotEmpty
          ? userIdValue
          : null;

      // Ensure count is non-negative
      final int safeCount = count < 0 ? 0 : count;

      final CounterSnapshot snapshot = CounterSnapshot(
        userId: userId ?? _localUserId,
        count: safeCount,
        lastChanged: changed,
      );
      _watchHelper.cachedSnapshot = snapshot;
      return snapshot;
    },
    fallback: () {
      _watchHelper.cachedSnapshot = _emptySnapshot;
      return _emptySnapshot;
    },
  );

  @override
  Future<void> save(final CounterSnapshot snapshot) async =>
      StorageGuard.run<void>(
        logContext: 'HiveCounterRepository.save',
        action: () async {
          final Box<dynamic> box = await getBox();
          final CounterSnapshot normalized =
              HiveCounterRepositoryHelpers.normalizeSnapshot(
                snapshot,
                _emptySnapshot,
                _localUserId,
              );

          await box.put(_keyCount, normalized.count);
          if (normalized.lastChanged != null) {
            await box.put(
              _keyChanged,
              normalized.lastChanged!.millisecondsSinceEpoch,
            );
          } else {
            await box.delete(_keyChanged);
          }
          await box.put(_keyUserId, normalized.userId ?? _localUserId);

          _watchHelper.emitSnapshot(normalized);
        },
        fallback: () {},
      );

  @override
  Stream<CounterSnapshot> watch() {
    _watchHelper.createWatchController(
      onListen: () => _watchHelper.handleOnListen(),
      onCancel: () => _watchHelper.handleOnCancel(),
    );
    return _watchHelper.stream;
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _watchHelper.dispose();
  }
}
