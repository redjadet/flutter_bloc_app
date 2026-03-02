// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_round_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameRoundResult {

 int get betAmount; int get payoutAmount; bool get isWin;
/// Create a copy of GameRoundResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameRoundResultCopyWith<GameRoundResult> get copyWith => _$GameRoundResultCopyWithImpl<GameRoundResult>(this as GameRoundResult, _$identity);

  /// Serializes this GameRoundResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameRoundResult&&(identical(other.betAmount, betAmount) || other.betAmount == betAmount)&&(identical(other.payoutAmount, payoutAmount) || other.payoutAmount == payoutAmount)&&(identical(other.isWin, isWin) || other.isWin == isWin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,betAmount,payoutAmount,isWin);

@override
String toString() {
  return 'GameRoundResult(betAmount: $betAmount, payoutAmount: $payoutAmount, isWin: $isWin)';
}


}

/// @nodoc
abstract mixin class $GameRoundResultCopyWith<$Res>  {
  factory $GameRoundResultCopyWith(GameRoundResult value, $Res Function(GameRoundResult) _then) = _$GameRoundResultCopyWithImpl;
@useResult
$Res call({
 int betAmount, int payoutAmount, bool isWin
});




}
/// @nodoc
class _$GameRoundResultCopyWithImpl<$Res>
    implements $GameRoundResultCopyWith<$Res> {
  _$GameRoundResultCopyWithImpl(this._self, this._then);

  final GameRoundResult _self;
  final $Res Function(GameRoundResult) _then;

/// Create a copy of GameRoundResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? betAmount = null,Object? payoutAmount = null,Object? isWin = null,}) {
  return _then(_self.copyWith(
betAmount: null == betAmount ? _self.betAmount : betAmount // ignore: cast_nullable_to_non_nullable
as int,payoutAmount: null == payoutAmount ? _self.payoutAmount : payoutAmount // ignore: cast_nullable_to_non_nullable
as int,isWin: null == isWin ? _self.isWin : isWin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GameRoundResult].
extension GameRoundResultPatterns on GameRoundResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameRoundResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameRoundResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameRoundResult value)  $default,){
final _that = this;
switch (_that) {
case _GameRoundResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameRoundResult value)?  $default,){
final _that = this;
switch (_that) {
case _GameRoundResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int betAmount,  int payoutAmount,  bool isWin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameRoundResult() when $default != null:
return $default(_that.betAmount,_that.payoutAmount,_that.isWin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int betAmount,  int payoutAmount,  bool isWin)  $default,) {final _that = this;
switch (_that) {
case _GameRoundResult():
return $default(_that.betAmount,_that.payoutAmount,_that.isWin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int betAmount,  int payoutAmount,  bool isWin)?  $default,) {final _that = this;
switch (_that) {
case _GameRoundResult() when $default != null:
return $default(_that.betAmount,_that.payoutAmount,_that.isWin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameRoundResult extends GameRoundResult {
  const _GameRoundResult({required this.betAmount, required this.payoutAmount, required this.isWin}): super._();
  factory _GameRoundResult.fromJson(Map<String, dynamic> json) => _$GameRoundResultFromJson(json);

@override final  int betAmount;
@override final  int payoutAmount;
@override final  bool isWin;

/// Create a copy of GameRoundResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameRoundResultCopyWith<_GameRoundResult> get copyWith => __$GameRoundResultCopyWithImpl<_GameRoundResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameRoundResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameRoundResult&&(identical(other.betAmount, betAmount) || other.betAmount == betAmount)&&(identical(other.payoutAmount, payoutAmount) || other.payoutAmount == payoutAmount)&&(identical(other.isWin, isWin) || other.isWin == isWin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,betAmount,payoutAmount,isWin);

@override
String toString() {
  return 'GameRoundResult(betAmount: $betAmount, payoutAmount: $payoutAmount, isWin: $isWin)';
}


}

/// @nodoc
abstract mixin class _$GameRoundResultCopyWith<$Res> implements $GameRoundResultCopyWith<$Res> {
  factory _$GameRoundResultCopyWith(_GameRoundResult value, $Res Function(_GameRoundResult) _then) = __$GameRoundResultCopyWithImpl;
@override @useResult
$Res call({
 int betAmount, int payoutAmount, bool isWin
});




}
/// @nodoc
class __$GameRoundResultCopyWithImpl<$Res>
    implements _$GameRoundResultCopyWith<$Res> {
  __$GameRoundResultCopyWithImpl(this._self, this._then);

  final _GameRoundResult _self;
  final $Res Function(_GameRoundResult) _then;

/// Create a copy of GameRoundResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? betAmount = null,Object? payoutAmount = null,Object? isWin = null,}) {
  return _then(_GameRoundResult(
betAmount: null == betAmount ? _self.betAmount : betAmount // ignore: cast_nullable_to_non_nullable
as int,payoutAmount: null == payoutAmount ? _self.payoutAmount : payoutAmount // ignore: cast_nullable_to_non_nullable
as int,isWin: null == isWin ? _self.isWin : isWin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
