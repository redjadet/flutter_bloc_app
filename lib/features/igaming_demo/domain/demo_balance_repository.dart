import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';

/// Persists and retrieves the play-for-fun virtual balance.
/// Contract: balance is always non-negative; implementors enforce this.
abstract class DemoBalanceRepository {
  Future<DemoBalance> getBalance();

  Future<void> setBalance(final DemoBalance balance);

  /// Applies a delta (positive or negative); implementor clamps to >= 0.
  Future<void> updateBalance(final int deltaUnits);
}
