// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_book_level.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderBookLevel {

 double get price; double get quantity; OrderBookSide get side;
/// Create a copy of OrderBookLevel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderBookLevelCopyWith<OrderBookLevel> get copyWith => _$OrderBookLevelCopyWithImpl<OrderBookLevel>(this as OrderBookLevel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderBookLevel&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.side, side) || other.side == side));
}


@override
int get hashCode => Object.hash(runtimeType,price,quantity,side);

@override
String toString() {
  return 'OrderBookLevel(price: $price, quantity: $quantity, side: $side)';
}


}

/// @nodoc
abstract mixin class $OrderBookLevelCopyWith<$Res>  {
  factory $OrderBookLevelCopyWith(OrderBookLevel value, $Res Function(OrderBookLevel) _then) = _$OrderBookLevelCopyWithImpl;
@useResult
$Res call({
 double price, double quantity, OrderBookSide side
});




}
/// @nodoc
class _$OrderBookLevelCopyWithImpl<$Res>
    implements $OrderBookLevelCopyWith<$Res> {
  _$OrderBookLevelCopyWithImpl(this._self, this._then);

  final OrderBookLevel _self;
  final $Res Function(OrderBookLevel) _then;

/// Create a copy of OrderBookLevel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? price = null,Object? quantity = null,Object? side = null,}) {
  return _then(_self.copyWith(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as OrderBookSide,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderBookLevel].
extension OrderBookLevelPatterns on OrderBookLevel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderBookLevel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderBookLevel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderBookLevel value)  $default,){
final _that = this;
switch (_that) {
case _OrderBookLevel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderBookLevel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderBookLevel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double price,  double quantity,  OrderBookSide side)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderBookLevel() when $default != null:
return $default(_that.price,_that.quantity,_that.side);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double price,  double quantity,  OrderBookSide side)  $default,) {final _that = this;
switch (_that) {
case _OrderBookLevel():
return $default(_that.price,_that.quantity,_that.side);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double price,  double quantity,  OrderBookSide side)?  $default,) {final _that = this;
switch (_that) {
case _OrderBookLevel() when $default != null:
return $default(_that.price,_that.quantity,_that.side);case _:
  return null;

}
}

}

/// @nodoc


class _OrderBookLevel implements OrderBookLevel {
  const _OrderBookLevel({required this.price, required this.quantity, required this.side});
  

@override final  double price;
@override final  double quantity;
@override final  OrderBookSide side;

/// Create a copy of OrderBookLevel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderBookLevelCopyWith<_OrderBookLevel> get copyWith => __$OrderBookLevelCopyWithImpl<_OrderBookLevel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderBookLevel&&(identical(other.price, price) || other.price == price)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.side, side) || other.side == side));
}


@override
int get hashCode => Object.hash(runtimeType,price,quantity,side);

@override
String toString() {
  return 'OrderBookLevel(price: $price, quantity: $quantity, side: $side)';
}


}

/// @nodoc
abstract mixin class _$OrderBookLevelCopyWith<$Res> implements $OrderBookLevelCopyWith<$Res> {
  factory _$OrderBookLevelCopyWith(_OrderBookLevel value, $Res Function(_OrderBookLevel) _then) = __$OrderBookLevelCopyWithImpl;
@override @useResult
$Res call({
 double price, double quantity, OrderBookSide side
});




}
/// @nodoc
class __$OrderBookLevelCopyWithImpl<$Res>
    implements _$OrderBookLevelCopyWith<$Res> {
  __$OrderBookLevelCopyWithImpl(this._self, this._then);

  final _OrderBookLevel _self;
  final $Res Function(_OrderBookLevel) _then;

/// Create a copy of OrderBookLevel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? price = null,Object? quantity = null,Object? side = null,}) {
  return _then(_OrderBookLevel(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as OrderBookSide,
  ));
}


}

// dart format on
