import 'package:flutter_bloc_app/features/realtime_market/data/dto/market_snapshot_dto.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';

/// Maps Hive payloads and domain entities for the realtime market cache.
abstract final class MarketSnapshotMapper {
  static Map<String, Object?> toHiveMap(final MarketFeedSnapshot snapshot) =>
      MarketSnapshotDto.fromDomain(snapshot).toJson();

  /// Returns `null` for cache miss or malformed stored payload.
  static MarketFeedSnapshot? fromHiveValue(final Object? value) {
    if (value is! Map) {
      return null;
    }
    try {
      return MarketSnapshotDto.fromJson(
        Map<dynamic, dynamic>.from(value),
      ).toDomain();
    } on Exception {
      return null;
    }
  }
}
