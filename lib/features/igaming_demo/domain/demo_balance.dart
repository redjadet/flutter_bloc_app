import 'package:freezed_annotation/freezed_annotation.dart';

part 'demo_balance.freezed.dart';
part 'demo_balance.g.dart';

/// Initial virtual balance for play-for-fun demo (minor units, e.g. cents).
const int initialDemoBalanceUnits = 10_000;

/// Immutable virtual balance for the iGaming demo (play-for-fun).
@freezed
abstract class DemoBalance with _$DemoBalance {
  const factory DemoBalance({
    required final int amountUnits,
  }) = _DemoBalance;

  factory DemoBalance.fromJson(final Map<String, dynamic> json) =>
      _$DemoBalanceFromJson(json);

  const DemoBalance._();

  /// Creates the initial balance for first-time users.
  factory DemoBalance.initial() => const DemoBalance(
    amountUnits: initialDemoBalanceUnits,
  );
}
