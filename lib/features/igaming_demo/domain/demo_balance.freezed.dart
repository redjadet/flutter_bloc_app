// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'demo_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DemoBalance {

 int get amountUnits;
/// Create a copy of DemoBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DemoBalanceCopyWith<DemoBalance> get copyWith => _$DemoBalanceCopyWithImpl<DemoBalance>(this as DemoBalance, _$identity);

  /// Serializes this DemoBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DemoBalance&&(identical(other.amountUnits, amountUnits) || other.amountUnits == amountUnits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amountUnits);

@override
String toString() {
  return 'DemoBalance(amountUnits: $amountUnits)';
}


}

/// @nodoc
abstract mixin class $DemoBalanceCopyWith<$Res>  {
  factory $DemoBalanceCopyWith(DemoBalance value, $Res Function(DemoBalance) _then) = _$DemoBalanceCopyWithImpl;
@useResult
$Res call({
 int amountUnits
});




}
/// @nodoc
class _$DemoBalanceCopyWithImpl<$Res>
    implements $DemoBalanceCopyWith<$Res> {
  _$DemoBalanceCopyWithImpl(this._self, this._then);

  final DemoBalance _self;
  final $Res Function(DemoBalance) _then;

/// Create a copy of DemoBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amountUnits = null,}) {
  return _then(_self.copyWith(
amountUnits: null == amountUnits ? _self.amountUnits : amountUnits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DemoBalance].
extension DemoBalancePatterns on DemoBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DemoBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DemoBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DemoBalance value)  $default,){
final _that = this;
switch (_that) {
case _DemoBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DemoBalance value)?  $default,){
final _that = this;
switch (_that) {
case _DemoBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amountUnits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DemoBalance() when $default != null:
return $default(_that.amountUnits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amountUnits)  $default,) {final _that = this;
switch (_that) {
case _DemoBalance():
return $default(_that.amountUnits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amountUnits)?  $default,) {final _that = this;
switch (_that) {
case _DemoBalance() when $default != null:
return $default(_that.amountUnits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DemoBalance extends DemoBalance {
  const _DemoBalance({required this.amountUnits}): super._();
  factory _DemoBalance.fromJson(Map<String, dynamic> json) => _$DemoBalanceFromJson(json);

@override final  int amountUnits;

/// Create a copy of DemoBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DemoBalanceCopyWith<_DemoBalance> get copyWith => __$DemoBalanceCopyWithImpl<_DemoBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DemoBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DemoBalance&&(identical(other.amountUnits, amountUnits) || other.amountUnits == amountUnits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amountUnits);

@override
String toString() {
  return 'DemoBalance(amountUnits: $amountUnits)';
}


}

/// @nodoc
abstract mixin class _$DemoBalanceCopyWith<$Res> implements $DemoBalanceCopyWith<$Res> {
  factory _$DemoBalanceCopyWith(_DemoBalance value, $Res Function(_DemoBalance) _then) = __$DemoBalanceCopyWithImpl;
@override @useResult
$Res call({
 int amountUnits
});




}
/// @nodoc
class __$DemoBalanceCopyWithImpl<$Res>
    implements _$DemoBalanceCopyWith<$Res> {
  __$DemoBalanceCopyWithImpl(this._self, this._then);

  final _DemoBalance _self;
  final $Res Function(_DemoBalance) _then;

/// Create a copy of DemoBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amountUnits = null,}) {
  return _then(_DemoBalance(
amountUnits: null == amountUnits ? _self.amountUnits : amountUnits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
