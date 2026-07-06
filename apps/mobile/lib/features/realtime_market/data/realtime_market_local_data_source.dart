import 'package:flutter_bloc_app/features/realtime_market/data/mappers/market_snapshot_mapper.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed cache for the last emitted market snapshot per pair.
///
/// Box name version `realtime_market_v1` pins payload layout for v1 (no
/// `HiveBoxSchema` entry): breaking shape changes require a new box name.
class RealtimeMarketLocalDataSource extends HiveRepositoryBase {
  RealtimeMarketLocalDataSource({required super.hiveService});

  @override
  String get boxName => 'realtime_market_v1';

  static String snapshotKey(final String pairId) => 'snapshot:$pairId';

  Future<MarketFeedSnapshot?> loadCached(final String pairId) async {
    final Box<dynamic> box = await getBox();
    final Object? raw = box.get(snapshotKey(pairId));
    return MarketSnapshotMapper.fromHiveValue(raw);
  }

  Future<void> saveSnapshot(
    final String pairId,
    final MarketFeedSnapshot snapshot,
  ) async {
    final Box<dynamic> box = await getBox();
    final MarketFeedSnapshot? existing = await loadCached(pairId);
    if (existing != null && existing.updatedAt.isAfter(snapshot.updatedAt)) {
      return;
    }
    await box.put(
      snapshotKey(pairId),
      MarketSnapshotMapper.toHiveMap(snapshot),
    );
  }
}
