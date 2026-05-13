// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_trade.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentTrade {

 String get id; double get price; double get quantity; bool get isBuy; DateTime get at;
/// Create a copy of RecentTrade
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentTradeCopyWith<RecentTrade> get copyWith => _$RecentTradeCopyWithImpl<RecentTrade>(this as RecentTrade, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentTrade&&(identical(other.id, id) || other.id == id)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.isBuy, isBuy) || other.isBuy == isBuy)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,id,price,quantity,isBuy,at);

@override
String toString() {
  return 'RecentTrade(id: $id, price: $price, quantity: $quantity, isBuy: $isBuy, at: $at)';
}


}

/// @nodoc
abstract mixin class $RecentTradeCopyWith<$Res>  {
  factory $RecentTradeCopyWith(RecentTrade value, $Res Function(RecentTrade) _then) = _$RecentTradeCopyWithImpl;
@useResult
$Res call({
 String id, double price, double quantity, bool isBuy, DateTime at
});




}
/// @nodoc
class _$RecentTradeCopyWithImpl<$Res>
    implements $RecentTradeCopyWith<$Res> {
  _$RecentTradeCopyWithImpl(this._self, this._then);

  final RecentTrade _self;
  final $Res Function(RecentTrade) _then;

/// Create a copy of RecentTrade
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? price = null,Object? quantity = null,Object? isBuy = null,Object? at = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,isBuy: null == isBuy ? _self.isBuy : isBuy // ignore: cast_nullable_to_non_nullable
as bool,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentTrade].
extension RecentTradePatterns on RecentTrade {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentTrade value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentTrade() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentTrade value)  $default,){
final _that = this;
switch (_that) {
case _RecentTrade():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentTrade value)?  $default,){
final _that = this;
switch (_that) {
case _RecentTrade() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double price,  double quantity,  bool isBuy,  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentTrade() when $default != null:
return $default(_that.id,_that.price,_that.quantity,_that.isBuy,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double price,  double quantity,  bool isBuy,  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _RecentTrade():
return $default(_that.id,_that.price,_that.quantity,_that.isBuy,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double price,  double quantity,  bool isBuy,  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _RecentTrade() when $default != null:
return $default(_that.id,_that.price,_that.quantity,_that.isBuy,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _RecentTrade implements RecentTrade {
  const _RecentTrade({required this.id, required this.price, required this.quantity, required this.isBuy, required this.at});
  

@override final  String id;
@override final  double price;
@override final  double quantity;
@override final  bool isBuy;
@override final  DateTime at;

/// Create a copy of RecentTrade
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentTradeCopyWith<_RecentTrade> get copyWith => __$RecentTradeCopyWithImpl<_RecentTrade>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentTrade&&(identical(other.id, id) || other.id == id)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.isBuy, isBuy) || other.isBuy == isBuy)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,id,price,quantity,isBuy,at);

@override
String toString() {
  return 'RecentTrade(id: $id, price: $price, quantity: $quantity, isBuy: $isBuy, at: $at)';
}


}

/// @nodoc
abstract mixin class _$RecentTradeCopyWith<$Res> implements $RecentTradeCopyWith<$Res> {
  factory _$RecentTradeCopyWith(_RecentTrade value, $Res Function(_RecentTrade) _then) = __$RecentTradeCopyWithImpl;
@override @useResult
$Res call({
 String id, double price, double quantity, bool isBuy, DateTime at
});




}
/// @nodoc
class __$RecentTradeCopyWithImpl<$Res>
    implements _$RecentTradeCopyWith<$Res> {
  __$RecentTradeCopyWithImpl(this._self, this._then);

  final _RecentTrade _self;
  final $Res Function(_RecentTrade) _then;

/// Create a copy of RecentTrade
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? price = null,Object? quantity = null,Object? isBuy = null,Object? at = null,}) {
  return _then(_RecentTrade(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,isBuy: null == isBuy ? _self.isBuy : isBuy // ignore: cast_nullable_to_non_nullable
as bool,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
