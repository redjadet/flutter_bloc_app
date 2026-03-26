import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive/hive.dart';

abstract interface class IapDemoCreditsStore {
  Future<int> loadCredits();
  Future<void> saveCredits(final int credits);
}

class InMemoryIapDemoCreditsStore implements IapDemoCreditsStore {
  InMemoryIapDemoCreditsStore([this._credits = 0]);

  int _credits;

  @override
  Future<int> loadCredits() async => _credits;

  @override
  Future<void> saveCredits(final int credits) async {
    _credits = credits;
  }
}

class HiveIapDemoCreditsStore implements IapDemoCreditsStore {
  HiveIapDemoCreditsStore({required final HiveService hiveService})
    : _hiveService = hiveService;

  static const String _boxName = 'iap_demo';
  static const String _keyCredits = 'credits';

  final HiveService _hiveService;
  Future<Box<dynamic>>? _box;

  Future<Box<dynamic>> _getBox() => _box ??= _hiveService.openBox(_boxName);

  @override
  Future<int> loadCredits() async => StorageGuard.run<int>(
    logContext: 'HiveIapDemoCreditsStore.loadCredits',
    action: () async {
      final Box<dynamic> box = await _getBox();
      final dynamic value = box.get(_keyCredits, defaultValue: 0);
      return value is int ? value : 0;
    },
    fallback: () => 0,
  );

  @override
  Future<void> saveCredits(final int credits) async => StorageGuard.run<void>(
    logContext: 'HiveIapDemoCreditsStore.saveCredits',
    action: () async {
      final Box<dynamic> box = await _getBox();
      await box.put(_keyCredits, credits);
    },
    fallback: () {},
  );
}
