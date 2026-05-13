import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_connection_status.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_stats.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/recent_trade.dart';

/// JSON-serializable snapshot for Hive (demo feature).
class MarketSnapshotDto {
  factory MarketSnapshotDto.fromDomain(final MarketFeedSnapshot s) {
    return MarketSnapshotDto._(<String, Object?>{
      'pairId': s.pairId,
      'lastPrice': s.lastPrice,
      'changePct24h': s.changePct24h,
      'connection': s.connection.name,
      'bids': s.bids.map(_orderBookToMap).toList(),
      'asks': s.asks.map(_orderBookToMap).toList(),
      'recentTrades': s.recentTrades.map(_tradeToMap).toList(),
      'stats': _statsToMap(s.stats),
      'chartCloses': s.chartCloses,
      'updatedAtMs': s.updatedAt.millisecondsSinceEpoch,
    });
  }

  factory MarketSnapshotDto.fromJson(final Map<dynamic, dynamic> json) {
    final Map<String, Object?> out = <String, Object?>{};
    for (final MapEntry<dynamic, dynamic> e in json.entries) {
      out[e.key.toString()] = e.value as Object?;
    }
    return MarketSnapshotDto._(out);
  }

  MarketSnapshotDto._(this._json);

  final Map<String, Object?> _json;

  Map<String, Object?> toJson() => _json;

  MarketFeedSnapshot toDomain() {
    try {
      final String pairId = _string(_json, 'pairId');
      final double lastPrice = _num(_json, 'lastPrice').toDouble();
      final double changePct24h = _num(_json, 'changePct24h').toDouble();
      final MarketConnectionStatus connection = MarketConnectionStatus.values
          .byName(_string(_json, 'connection'));
      final List<OrderBookLevel> bids = _list(
        _json,
        'bids',
      ).map((final e) => _orderBookFromMap(_asMap(e))).toList();
      final List<OrderBookLevel> asks = _list(
        _json,
        'asks',
      ).map((final e) => _orderBookFromMap(_asMap(e))).toList();
      final List<RecentTrade> trades = _list(
        _json,
        'recentTrades',
      ).map((final e) => _tradeFromMap(_asMap(e))).toList();
      final MarketStats stats = _statsFromMap(_asMap(_json['stats']));
      final List<double> chart = _list(
        _json,
        'chartCloses',
      ).map((final e) => (e as num).toDouble()).toList();
      final int updatedAtMs = _num(_json, 'updatedAtMs').toInt();
      return MarketFeedSnapshot(
        pairId: pairId,
        lastPrice: lastPrice,
        changePct24h: changePct24h,
        connection: connection,
        bids: bids,
        asks: asks,
        recentTrades: trades,
        stats: stats,
        chartCloses: chart,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          updatedAtMs,
          isUtc: true,
        ),
      );
    } on Object {
      throw const FormatException('invalid market snapshot dto');
    }
  }
}

Never _bad() => throw const FormatException('invalid market snapshot dto');

String _string(final Map<String, Object?> m, final String key) {
  final Object? v = m[key];
  if (v is String) {
    return v;
  }
  _bad();
}

num _num(final Map<String, Object?> m, final String key) {
  final Object? v = m[key];
  if (v is num) {
    return v;
  }
  _bad();
}

List<dynamic> _list(final Map<String, Object?> m, final String key) {
  final Object? v = m[key];
  if (v is List) {
    return List<dynamic>.from(v);
  }
  _bad();
}

Map<dynamic, dynamic> _asMap(final Object? v) {
  if (v is Map) {
    return Map<dynamic, dynamic>.from(v);
  }
  _bad();
}

Map<String, Object?> _orderBookToMap(final OrderBookLevel b) =>
    <String, Object?>{
      'price': b.price,
      'quantity': b.quantity,
      'side': b.side.name,
    };

OrderBookLevel _orderBookFromMap(final Map<dynamic, dynamic> m) {
  final Object? price = m['price'];
  final Object? quantity = m['quantity'];
  final Object? side = m['side'];
  if (price is! num || quantity is! num || side is! String) {
    _bad();
  }
  return OrderBookLevel(
    price: price.toDouble(),
    quantity: quantity.toDouble(),
    side: OrderBookSide.values.byName(side),
  );
}

Map<String, Object?> _tradeToMap(final RecentTrade t) => <String, Object?>{
  'id': t.id,
  'price': t.price,
  'quantity': t.quantity,
  'isBuy': t.isBuy,
  'atMs': t.at.millisecondsSinceEpoch,
};

RecentTrade _tradeFromMap(final Map<dynamic, dynamic> m) {
  final Object? id = m['id'];
  final Object? price = m['price'];
  final Object? quantity = m['quantity'];
  final Object? isBuy = m['isBuy'];
  final Object? atMs = m['atMs'];
  if (id is! String ||
      price is! num ||
      quantity is! num ||
      isBuy is! bool ||
      atMs is! num) {
    _bad();
  }
  return RecentTrade(
    id: id,
    price: price.toDouble(),
    quantity: quantity.toDouble(),
    isBuy: isBuy,
    at: DateTime.fromMillisecondsSinceEpoch(
      atMs.toInt(),
      isUtc: true,
    ),
  );
}

Map<String, Object?> _statsToMap(final MarketStats s) => <String, Object?>{
  'high24h': s.high24h,
  'low24h': s.low24h,
  'volume24h': s.volume24h,
};

MarketStats _statsFromMap(final Map<dynamic, dynamic> m) {
  final Object? high = m['high24h'];
  final Object? low = m['low24h'];
  final Object? vol = m['volume24h'];
  if (high is! num || low is! num || vol is! num) {
    _bad();
  }
  return MarketStats(
    high24h: high.toDouble(),
    low24h: low.toDouble(),
    volume24h: vol.toDouble(),
  );
}
