import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_trade.freezed.dart';

@freezed
abstract class RecentTrade with _$RecentTrade {
  const factory RecentTrade({
    required final String id,
    required final double price,
    required final double quantity,
    required final bool isBuy,
    required final DateTime at,
  }) = _RecentTrade;
}
