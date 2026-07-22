import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';
import 'package:storage/storage.dart';

/// Hive-backed implementation of [DemoBalanceRepository].
class HiveDemoBalanceRepository extends HiveRepositoryBase
    implements DemoBalanceRepository {
  HiveDemoBalanceRepository({required super.hiveService});

  static const String _boxName = 'igaming_demo_balance';
  static const String _keyAmountUnits = 'amount_units';

  @override
  String get boxName => _boxName;

  @override
  Future<DemoBalance> getBalance() async => StorageGuard.run<DemoBalance>(
    logContext: 'HiveDemoBalanceRepository.getBalance',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic raw = box.get(_keyAmountUnits);
      final int? units = intFromDynamic(raw);
      if (units == null || units < 0) {
        final DemoBalance initial = DemoBalance.initial();
        await setBalance(initial);
        return initial;
      }
      return DemoBalance(amountUnits: units);
    },
    fallback: () async {
      AppLogger.error(
        'HiveDemoBalanceRepository.getBalance fallback',
        Exception('Using initial balance'),
        StackTrace.current,
      );
      return DemoBalance.initial();
    },
  );

  @override
  Future<void> setBalance(final DemoBalance balance) async =>
      StorageGuard.run<void>(
        logContext: 'HiveDemoBalanceRepository.setBalance',
        action: () async {
          final int safe = balance.amountUnits < 0 ? 0 : balance.amountUnits;
          final Box<dynamic> box = await getBox();
          await box.put(_keyAmountUnits, safe);
        },
        fallback: () {},
      );

  @override
  Future<void> updateBalance(final int deltaUnits) async =>
      StorageGuard.run<void>(
        logContext: 'HiveDemoBalanceRepository.updateBalance',
        action: () async {
          final DemoBalance current = await getBalance();
          final int newAmount = current.amountUnits + deltaUnits;
          final int clamped = newAmount < 0 ? 0 : newAmount;
          await setBalance(DemoBalance(amountUnits: clamped));
        },
        fallback: () {},
      );
}
