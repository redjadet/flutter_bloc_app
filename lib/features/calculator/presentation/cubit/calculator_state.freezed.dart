// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calculator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalculatorState {

 String get display; double? get accumulator; CalculatorOperation? get operation; CalculatorOperation? get lastOperation; double? get lastOperand; bool get replaceInput; double get taxRate; double get tipRate; double get settledAmount; String get history;
/// Create a copy of CalculatorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalculatorStateCopyWith<CalculatorState> get copyWith => _$CalculatorStateCopyWithImpl<CalculatorState>(this as CalculatorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalculatorState&&(identical(other.display, display) || other.display == display)&&(identical(other.accumulator, accumulator) || other.accumulator == accumulator)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.lastOperation, lastOperation) || other.lastOperation == lastOperation)&&(identical(other.lastOperand, lastOperand) || other.lastOperand == lastOperand)&&(identical(other.replaceInput, replaceInput) || other.replaceInput == replaceInput)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.tipRate, tipRate) || other.tipRate == tipRate)&&(identical(other.settledAmount, settledAmount) || other.settledAmount == settledAmount)&&(identical(other.history, history) || other.history == history));
}


@override
int get hashCode => Object.hash(runtimeType,display,accumulator,operation,lastOperation,lastOperand,replaceInput,taxRate,tipRate,settledAmount,history);

@override
String toString() {
  return 'CalculatorState(display: $display, accumulator: $accumulator, operation: $operation, lastOperation: $lastOperation, lastOperand: $lastOperand, replaceInput: $replaceInput, taxRate: $taxRate, tipRate: $tipRate, settledAmount: $settledAmount, history: $history)';
}


}

/// @nodoc
abstract mixin class $CalculatorStateCopyWith<$Res>  {
  factory $CalculatorStateCopyWith(CalculatorState value, $Res Function(CalculatorState) _then) = _$CalculatorStateCopyWithImpl;
@useResult
$Res call({
 String display, double? accumulator, CalculatorOperation? operation, CalculatorOperation? lastOperation, double? lastOperand, bool replaceInput, double taxRate, double tipRate, double settledAmount, String history
});




}
/// @nodoc
class _$CalculatorStateCopyWithImpl<$Res>
    implements $CalculatorStateCopyWith<$Res> {
  _$CalculatorStateCopyWithImpl(this._self, this._then);

  final CalculatorState _self;
  final $Res Function(CalculatorState) _then;

/// Create a copy of CalculatorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? display = null,Object? accumulator = freezed,Object? operation = freezed,Object? lastOperation = freezed,Object? lastOperand = freezed,Object? replaceInput = null,Object? taxRate = null,Object? tipRate = null,Object? settledAmount = null,Object? history = null,}) {
  return _then(_self.copyWith(
display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,accumulator: freezed == accumulator ? _self.accumulator : accumulator // ignore: cast_nullable_to_non_nullable
as double?,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as CalculatorOperation?,lastOperation: freezed == lastOperation ? _self.lastOperation : lastOperation // ignore: cast_nullable_to_non_nullable
as CalculatorOperation?,lastOperand: freezed == lastOperand ? _self.lastOperand : lastOperand // ignore: cast_nullable_to_non_nullable
as double?,replaceInput: null == replaceInput ? _self.replaceInput : replaceInput // ignore: cast_nullable_to_non_nullable
as bool,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,tipRate: null == tipRate ? _self.tipRate : tipRate // ignore: cast_nullable_to_non_nullable
as double,settledAmount: null == settledAmount ? _self.settledAmount : settledAmount // ignore: cast_nullable_to_non_nullable
as double,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CalculatorState].
extension CalculatorStatePatterns on CalculatorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalculatorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalculatorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalculatorState value)  $default,){
final _that = this;
switch (_that) {
case _CalculatorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalculatorState value)?  $default,){
final _that = this;
switch (_that) {
case _CalculatorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String display,  double? accumulator,  CalculatorOperation? operation,  CalculatorOperation? lastOperation,  double? lastOperand,  bool replaceInput,  double taxRate,  double tipRate,  double settledAmount,  String history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalculatorState() when $default != null:
return $default(_that.display,_that.accumulator,_that.operation,_that.lastOperation,_that.lastOperand,_that.replaceInput,_that.taxRate,_that.tipRate,_that.settledAmount,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String display,  double? accumulator,  CalculatorOperation? operation,  CalculatorOperation? lastOperation,  double? lastOperand,  bool replaceInput,  double taxRate,  double tipRate,  double settledAmount,  String history)  $default,) {final _that = this;
switch (_that) {
case _CalculatorState():
return $default(_that.display,_that.accumulator,_that.operation,_that.lastOperation,_that.lastOperand,_that.replaceInput,_that.taxRate,_that.tipRate,_that.settledAmount,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String display,  double? accumulator,  CalculatorOperation? operation,  CalculatorOperation? lastOperation,  double? lastOperand,  bool replaceInput,  double taxRate,  double tipRate,  double settledAmount,  String history)?  $default,) {final _that = this;
switch (_that) {
case _CalculatorState() when $default != null:
return $default(_that.display,_that.accumulator,_that.operation,_that.lastOperation,_that.lastOperand,_that.replaceInput,_that.taxRate,_that.tipRate,_that.settledAmount,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _CalculatorState extends CalculatorState {
  const _CalculatorState({this.display = '0', this.accumulator, this.operation, this.lastOperation, this.lastOperand, this.replaceInput = true, this.taxRate = 0.0, this.tipRate = 0.0, this.settledAmount = 0.0, this.history = ''}): super._();
  

@override@JsonKey() final  String display;
@override final  double? accumulator;
@override final  CalculatorOperation? operation;
@override final  CalculatorOperation? lastOperation;
@override final  double? lastOperand;
@override@JsonKey() final  bool replaceInput;
@override@JsonKey() final  double taxRate;
@override@JsonKey() final  double tipRate;
@override@JsonKey() final  double settledAmount;
@override@JsonKey() final  String history;

/// Create a copy of CalculatorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalculatorStateCopyWith<_CalculatorState> get copyWith => __$CalculatorStateCopyWithImpl<_CalculatorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalculatorState&&(identical(other.display, display) || other.display == display)&&(identical(other.accumulator, accumulator) || other.accumulator == accumulator)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.lastOperation, lastOperation) || other.lastOperation == lastOperation)&&(identical(other.lastOperand, lastOperand) || other.lastOperand == lastOperand)&&(identical(other.replaceInput, replaceInput) || other.replaceInput == replaceInput)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.tipRate, tipRate) || other.tipRate == tipRate)&&(identical(other.settledAmount, settledAmount) || other.settledAmount == settledAmount)&&(identical(other.history, history) || other.history == history));
}


@override
int get hashCode => Object.hash(runtimeType,display,accumulator,operation,lastOperation,lastOperand,replaceInput,taxRate,tipRate,settledAmount,history);

@override
String toString() {
  return 'CalculatorState(display: $display, accumulator: $accumulator, operation: $operation, lastOperation: $lastOperation, lastOperand: $lastOperand, replaceInput: $replaceInput, taxRate: $taxRate, tipRate: $tipRate, settledAmount: $settledAmount, history: $history)';
}


}

/// @nodoc
abstract mixin class _$CalculatorStateCopyWith<$Res> implements $CalculatorStateCopyWith<$Res> {
  factory _$CalculatorStateCopyWith(_CalculatorState value, $Res Function(_CalculatorState) _then) = __$CalculatorStateCopyWithImpl;
@override @useResult
$Res call({
 String display, double? accumulator, CalculatorOperation? operation, CalculatorOperation? lastOperation, double? lastOperand, bool replaceInput, double taxRate, double tipRate, double settledAmount, String history
});




}
/// @nodoc
class __$CalculatorStateCopyWithImpl<$Res>
    implements _$CalculatorStateCopyWith<$Res> {
  __$CalculatorStateCopyWithImpl(this._self, this._then);

  final _CalculatorState _self;
  final $Res Function(_CalculatorState) _then;

/// Create a copy of CalculatorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? display = null,Object? accumulator = freezed,Object? operation = freezed,Object? lastOperation = freezed,Object? lastOperand = freezed,Object? replaceInput = null,Object? taxRate = null,Object? tipRate = null,Object? settledAmount = null,Object? history = null,}) {
  return _then(_CalculatorState(
display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,accumulator: freezed == accumulator ? _self.accumulator : accumulator // ignore: cast_nullable_to_non_nullable
as double?,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as CalculatorOperation?,lastOperation: freezed == lastOperation ? _self.lastOperation : lastOperation // ignore: cast_nullable_to_non_nullable
as CalculatorOperation?,lastOperand: freezed == lastOperand ? _self.lastOperand : lastOperand // ignore: cast_nullable_to_non_nullable
as double?,replaceInput: null == replaceInput ? _self.replaceInput : replaceInput // ignore: cast_nullable_to_non_nullable
as bool,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as double,tipRate: null == tipRate ? _self.tipRate : tipRate // ignore: cast_nullable_to_non_nullable
as double,settledAmount: null == settledAmount ? _self.settledAmount : settledAmount // ignore: cast_nullable_to_non_nullable
as double,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
