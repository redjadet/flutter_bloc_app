import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_stats.freezed.dart';

@freezed
abstract class MarketStats with _$MarketStats {
  const factory MarketStats({
    required final double high24h,
    required final double low24h,
    required final double volume24h,
  }) = _MarketStats;
}
