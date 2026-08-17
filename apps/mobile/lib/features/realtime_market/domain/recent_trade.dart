import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_trade.freezed.dart';

@freezed
abstract class RecentTrade with _$RecentTrade {
  const factory RecentTrade({
    required String id,
    required double price,
    required double quantity,
    required bool isBuy,
    required DateTime at,
  }) = _RecentTrade;
}
