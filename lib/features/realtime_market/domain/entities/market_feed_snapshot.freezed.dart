// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_feed_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarketFeedSnapshot {

 String get pairId; double get lastPrice; double get changePct24h; MarketConnectionStatus get connection; List<OrderBookLevel> get bids; List<OrderBookLevel> get asks; List<RecentTrade> get recentTrades; MarketStats get stats; List<double> get chartCloses; DateTime get updatedAt;
/// Create a copy of MarketFeedSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketFeedSnapshotCopyWith<MarketFeedSnapshot> get copyWith => _$MarketFeedSnapshotCopyWithImpl<MarketFeedSnapshot>(this as MarketFeedSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketFeedSnapshot&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.lastPrice, lastPrice) || other.lastPrice == lastPrice)&&(identical(other.changePct24h, changePct24h) || other.changePct24h == changePct24h)&&(identical(other.connection, connection) || other.connection == connection)&&const DeepCollectionEquality().equals(other.bids, bids)&&const DeepCollectionEquality().equals(other.asks, asks)&&const DeepCollectionEquality().equals(other.recentTrades, recentTrades)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.chartCloses, chartCloses)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,pairId,lastPrice,changePct24h,connection,const DeepCollectionEquality().hash(bids),const DeepCollectionEquality().hash(asks),const DeepCollectionEquality().hash(recentTrades),stats,const DeepCollectionEquality().hash(chartCloses),updatedAt);

@override
String toString() {
  return 'MarketFeedSnapshot(pairId: $pairId, lastPrice: $lastPrice, changePct24h: $changePct24h, connection: $connection, bids: $bids, asks: $asks, recentTrades: $recentTrades, stats: $stats, chartCloses: $chartCloses, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MarketFeedSnapshotCopyWith<$Res>  {
  factory $MarketFeedSnapshotCopyWith(MarketFeedSnapshot value, $Res Function(MarketFeedSnapshot) _then) = _$MarketFeedSnapshotCopyWithImpl;
@useResult
$Res call({
 String pairId, double lastPrice, double changePct24h, MarketConnectionStatus connection, List<OrderBookLevel> bids, List<OrderBookLevel> asks, List<RecentTrade> recentTrades, MarketStats stats, List<double> chartCloses, DateTime updatedAt
});


$MarketStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$MarketFeedSnapshotCopyWithImpl<$Res>
    implements $MarketFeedSnapshotCopyWith<$Res> {
  _$MarketFeedSnapshotCopyWithImpl(this._self, this._then);

  final MarketFeedSnapshot _self;
  final $Res Function(MarketFeedSnapshot) _then;

/// Create a copy of MarketFeedSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pairId = null,Object? lastPrice = null,Object? changePct24h = null,Object? connection = null,Object? bids = null,Object? asks = null,Object? recentTrades = null,Object? stats = null,Object? chartCloses = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,lastPrice: null == lastPrice ? _self.lastPrice : lastPrice // ignore: cast_nullable_to_non_nullable
as double,changePct24h: null == changePct24h ? _self.changePct24h : changePct24h // ignore: cast_nullable_to_non_nullable
as double,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as MarketConnectionStatus,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as List<OrderBookLevel>,asks: null == asks ? _self.asks : asks // ignore: cast_nullable_to_non_nullable
as List<OrderBookLevel>,recentTrades: null == recentTrades ? _self.recentTrades : recentTrades // ignore: cast_nullable_to_non_nullable
as List<RecentTrade>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as MarketStats,chartCloses: null == chartCloses ? _self.chartCloses : chartCloses // ignore: cast_nullable_to_non_nullable
as List<double>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of MarketFeedSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketStatsCopyWith<$Res> get stats {
  
  return $MarketStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [MarketFeedSnapshot].
extension MarketFeedSnapshotPatterns on MarketFeedSnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketFeedSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketFeedSnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketFeedSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _MarketFeedSnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketFeedSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _MarketFeedSnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pairId,  double lastPrice,  double changePct24h,  MarketConnectionStatus connection,  List<OrderBookLevel> bids,  List<OrderBookLevel> asks,  List<RecentTrade> recentTrades,  MarketStats stats,  List<double> chartCloses,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketFeedSnapshot() when $default != null:
return $default(_that.pairId,_that.lastPrice,_that.changePct24h,_that.connection,_that.bids,_that.asks,_that.recentTrades,_that.stats,_that.chartCloses,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pairId,  double lastPrice,  double changePct24h,  MarketConnectionStatus connection,  List<OrderBookLevel> bids,  List<OrderBookLevel> asks,  List<RecentTrade> recentTrades,  MarketStats stats,  List<double> chartCloses,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MarketFeedSnapshot():
return $default(_that.pairId,_that.lastPrice,_that.changePct24h,_that.connection,_that.bids,_that.asks,_that.recentTrades,_that.stats,_that.chartCloses,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pairId,  double lastPrice,  double changePct24h,  MarketConnectionStatus connection,  List<OrderBookLevel> bids,  List<OrderBookLevel> asks,  List<RecentTrade> recentTrades,  MarketStats stats,  List<double> chartCloses,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketFeedSnapshot() when $default != null:
return $default(_that.pairId,_that.lastPrice,_that.changePct24h,_that.connection,_that.bids,_that.asks,_that.recentTrades,_that.stats,_that.chartCloses,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MarketFeedSnapshot implements MarketFeedSnapshot {
  const _MarketFeedSnapshot({required this.pairId, required this.lastPrice, required this.changePct24h, required this.connection, required final  List<OrderBookLevel> bids, required final  List<OrderBookLevel> asks, required final  List<RecentTrade> recentTrades, required this.stats, required final  List<double> chartCloses, required this.updatedAt}): _bids = bids,_asks = asks,_recentTrades = recentTrades,_chartCloses = chartCloses;
  

@override final  String pairId;
@override final  double lastPrice;
@override final  double changePct24h;
@override final  MarketConnectionStatus connection;
 final  List<OrderBookLevel> _bids;
@override List<OrderBookLevel> get bids {
  if (_bids is EqualUnmodifiableListView) return _bids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bids);
}

 final  List<OrderBookLevel> _asks;
@override List<OrderBookLevel> get asks {
  if (_asks is EqualUnmodifiableListView) return _asks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_asks);
}

 final  List<RecentTrade> _recentTrades;
@override List<RecentTrade> get recentTrades {
  if (_recentTrades is EqualUnmodifiableListView) return _recentTrades;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTrades);
}

@override final  MarketStats stats;
 final  List<double> _chartCloses;
@override List<double> get chartCloses {
  if (_chartCloses is EqualUnmodifiableListView) return _chartCloses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chartCloses);
}

@override final  DateTime updatedAt;

/// Create a copy of MarketFeedSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketFeedSnapshotCopyWith<_MarketFeedSnapshot> get copyWith => __$MarketFeedSnapshotCopyWithImpl<_MarketFeedSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketFeedSnapshot&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.lastPrice, lastPrice) || other.lastPrice == lastPrice)&&(identical(other.changePct24h, changePct24h) || other.changePct24h == changePct24h)&&(identical(other.connection, connection) || other.connection == connection)&&const DeepCollectionEquality().equals(other._bids, _bids)&&const DeepCollectionEquality().equals(other._asks, _asks)&&const DeepCollectionEquality().equals(other._recentTrades, _recentTrades)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._chartCloses, _chartCloses)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,pairId,lastPrice,changePct24h,connection,const DeepCollectionEquality().hash(_bids),const DeepCollectionEquality().hash(_asks),const DeepCollectionEquality().hash(_recentTrades),stats,const DeepCollectionEquality().hash(_chartCloses),updatedAt);

@override
String toString() {
  return 'MarketFeedSnapshot(pairId: $pairId, lastPrice: $lastPrice, changePct24h: $changePct24h, connection: $connection, bids: $bids, asks: $asks, recentTrades: $recentTrades, stats: $stats, chartCloses: $chartCloses, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MarketFeedSnapshotCopyWith<$Res> implements $MarketFeedSnapshotCopyWith<$Res> {
  factory _$MarketFeedSnapshotCopyWith(_MarketFeedSnapshot value, $Res Function(_MarketFeedSnapshot) _then) = __$MarketFeedSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String pairId, double lastPrice, double changePct24h, MarketConnectionStatus connection, List<OrderBookLevel> bids, List<OrderBookLevel> asks, List<RecentTrade> recentTrades, MarketStats stats, List<double> chartCloses, DateTime updatedAt
});


@override $MarketStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$MarketFeedSnapshotCopyWithImpl<$Res>
    implements _$MarketFeedSnapshotCopyWith<$Res> {
  __$MarketFeedSnapshotCopyWithImpl(this._self, this._then);

  final _MarketFeedSnapshot _self;
  final $Res Function(_MarketFeedSnapshot) _then;

/// Create a copy of MarketFeedSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pairId = null,Object? lastPrice = null,Object? changePct24h = null,Object? connection = null,Object? bids = null,Object? asks = null,Object? recentTrades = null,Object? stats = null,Object? chartCloses = null,Object? updatedAt = null,}) {
  return _then(_MarketFeedSnapshot(
pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,lastPrice: null == lastPrice ? _self.lastPrice : lastPrice // ignore: cast_nullable_to_non_nullable
as double,changePct24h: null == changePct24h ? _self.changePct24h : changePct24h // ignore: cast_nullable_to_non_nullable
as double,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as MarketConnectionStatus,bids: null == bids ? _self._bids : bids // ignore: cast_nullable_to_non_nullable
as List<OrderBookLevel>,asks: null == asks ? _self._asks : asks // ignore: cast_nullable_to_non_nullable
as List<OrderBookLevel>,recentTrades: null == recentTrades ? _self._recentTrades : recentTrades // ignore: cast_nullable_to_non_nullable
as List<RecentTrade>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as MarketStats,chartCloses: null == chartCloses ? _self._chartCloses : chartCloses // ignore: cast_nullable_to_non_nullable
as List<double>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of MarketFeedSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketStatsCopyWith<$Res> get stats {
  
  return $MarketStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
