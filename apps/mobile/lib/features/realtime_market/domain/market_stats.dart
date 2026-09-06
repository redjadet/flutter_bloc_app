import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_stats.freezed.dart';

@freezed
abstract class MarketStats with _$MarketStats {
  const factory({
    required double high24h,
    required double low24h,
    required double volume24h,
  }) = _MarketStats;
}
