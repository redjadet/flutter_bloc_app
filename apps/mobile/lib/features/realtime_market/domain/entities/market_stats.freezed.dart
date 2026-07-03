// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarketStats {

 double get high24h; double get low24h; double get volume24h;
/// Create a copy of MarketStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketStatsCopyWith<MarketStats> get copyWith => _$MarketStatsCopyWithImpl<MarketStats>(this as MarketStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketStats&&(identical(other.high24h, high24h) || other.high24h == high24h)&&(identical(other.low24h, low24h) || other.low24h == low24h)&&(identical(other.volume24h, volume24h) || other.volume24h == volume24h));
}


@override
int get hashCode => Object.hash(runtimeType,high24h,low24h,volume24h);

@override
String toString() {
  return 'MarketStats(high24h: $high24h, low24h: $low24h, volume24h: $volume24h)';
}


}

/// @nodoc
abstract mixin class $MarketStatsCopyWith<$Res>  {
  factory $MarketStatsCopyWith(MarketStats value, $Res Function(MarketStats) _then) = _$MarketStatsCopyWithImpl;
@useResult
$Res call({
 double high24h, double low24h, double volume24h
});




}
/// @nodoc
class _$MarketStatsCopyWithImpl<$Res>
    implements $MarketStatsCopyWith<$Res> {
  _$MarketStatsCopyWithImpl(this._self, this._then);

  final MarketStats _self;
  final $Res Function(MarketStats) _then;

/// Create a copy of MarketStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? high24h = null,Object? low24h = null,Object? volume24h = null,}) {
  return _then(_self.copyWith(
high24h: null == high24h ? _self.high24h : high24h // ignore: cast_nullable_to_non_nullable
as double,low24h: null == low24h ? _self.low24h : low24h // ignore: cast_nullable_to_non_nullable
as double,volume24h: null == volume24h ? _self.volume24h : volume24h // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketStats].
extension MarketStatsPatterns on MarketStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketStats value)  $default,){
final _that = this;
switch (_that) {
case _MarketStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketStats value)?  $default,){
final _that = this;
switch (_that) {
case _MarketStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double high24h,  double low24h,  double volume24h)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketStats() when $default != null:
return $default(_that.high24h,_that.low24h,_that.volume24h);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double high24h,  double low24h,  double volume24h)  $default,) {final _that = this;
switch (_that) {
case _MarketStats():
return $default(_that.high24h,_that.low24h,_that.volume24h);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double high24h,  double low24h,  double volume24h)?  $default,) {final _that = this;
switch (_that) {
case _MarketStats() when $default != null:
return $default(_that.high24h,_that.low24h,_that.volume24h);case _:
  return null;

}
}

}

/// @nodoc


class _MarketStats implements MarketStats {
  const _MarketStats({required this.high24h, required this.low24h, required this.volume24h});
  

@override final  double high24h;
@override final  double low24h;
@override final  double volume24h;

/// Create a copy of MarketStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketStatsCopyWith<_MarketStats> get copyWith => __$MarketStatsCopyWithImpl<_MarketStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketStats&&(identical(other.high24h, high24h) || other.high24h == high24h)&&(identical(other.low24h, low24h) || other.low24h == low24h)&&(identical(other.volume24h, volume24h) || other.volume24h == volume24h));
}


@override
int get hashCode => Object.hash(runtimeType,high24h,low24h,volume24h);

@override
String toString() {
  return 'MarketStats(high24h: $high24h, low24h: $low24h, volume24h: $volume24h)';
}


}

/// @nodoc
abstract mixin class _$MarketStatsCopyWith<$Res> implements $MarketStatsCopyWith<$Res> {
  factory _$MarketStatsCopyWith(_MarketStats value, $Res Function(_MarketStats) _then) = __$MarketStatsCopyWithImpl;
@override @useResult
$Res call({
 double high24h, double low24h, double volume24h
});




}
/// @nodoc
class __$MarketStatsCopyWithImpl<$Res>
    implements _$MarketStatsCopyWith<$Res> {
  __$MarketStatsCopyWithImpl(this._self, this._then);

  final _MarketStats _self;
  final $Res Function(_MarketStats) _then;

/// Create a copy of MarketStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? high24h = null,Object? low24h = null,Object? volume24h = null,}) {
  return _then(_MarketStats(
high24h: null == high24h ? _self.high24h : high24h // ignore: cast_nullable_to_non_nullable
as double,low24h: null == low24h ? _self.low24h : low24h // ignore: cast_nullable_to_non_nullable
as double,volume24h: null == volume24h ? _self.volume24h : volume24h // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
