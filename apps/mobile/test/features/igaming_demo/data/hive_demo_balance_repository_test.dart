import 'package:flutter_bloc_app/features/igaming_demo/data/hive_demo_balance_repository.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late HiveDemoBalanceRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    repository = HiveDemoBalanceRepository(hiveService: hiveService);
  });

  tearDown(() async {
    await test_helpers.cleanupHiveBoxes(<String>['igaming_demo_balance']);
  });

  test('getBalance seeds initial when empty', () async {
    final DemoBalance balance = await repository.getBalance();
    expect(balance.amountUnits, initialDemoBalanceUnits);
  });

  test('setBalance and updateBalance clamp negatives', () async {
    await repository.setBalance(const DemoBalance(amountUnits: 500));
    expect((await repository.getBalance()).amountUnits, 500);

    await repository.updateBalance(-200);
    expect((await repository.getBalance()).amountUnits, 300);

    await repository.updateBalance(-10_000);
    expect((await repository.getBalance()).amountUnits, 0);

    await repository.setBalance(const DemoBalance(amountUnits: -5));
    expect((await repository.getBalance()).amountUnits, 0);
  });
}
