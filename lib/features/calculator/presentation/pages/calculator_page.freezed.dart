// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calculator_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DisplayData {

 String get display; String get history; CalculatorError? get error;
/// Create a copy of _DisplayData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayDataCopyWith<_DisplayData> get copyWith => __$DisplayDataCopyWithImpl<_DisplayData>(this as _DisplayData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayData&&(identical(other.display, display) || other.display == display)&&(identical(other.history, history) || other.history == history)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,display,history,error);

@override
String toString() {
  return '_DisplayData(display: $display, history: $history, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DisplayDataCopyWith<$Res>  {
  factory _$DisplayDataCopyWith(_DisplayData value, $Res Function(_DisplayData) _then) = __$DisplayDataCopyWithImpl;
@useResult
$Res call({
 String display, String history, CalculatorError? error
});




}
/// @nodoc
class __$DisplayDataCopyWithImpl<$Res>
    implements _$DisplayDataCopyWith<$Res> {
  __$DisplayDataCopyWithImpl(this._self, this._then);

  final _DisplayData _self;
  final $Res Function(_DisplayData) _then;

/// Create a copy of _DisplayData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? display = null,Object? history = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as CalculatorError?,
  ));
}

}


/// Adds pattern-matching-related methods to [_DisplayData].
extension _DisplayDataPatterns on _DisplayData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __DisplayData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __DisplayData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __DisplayData value)  $default,){
final _that = this;
switch (_that) {
case __DisplayData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __DisplayData value)?  $default,){
final _that = this;
switch (_that) {
case __DisplayData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String display,  String history,  CalculatorError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __DisplayData() when $default != null:
return $default(_that.display,_that.history,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String display,  String history,  CalculatorError? error)  $default,) {final _that = this;
switch (_that) {
case __DisplayData():
return $default(_that.display,_that.history,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String display,  String history,  CalculatorError? error)?  $default,) {final _that = this;
switch (_that) {
case __DisplayData() when $default != null:
return $default(_that.display,_that.history,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class __DisplayData implements _DisplayData {
  const __DisplayData({required this.display, required this.history, required this.error});
  

@override final  String display;
@override final  String history;
@override final  CalculatorError? error;

/// Create a copy of _DisplayData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_DisplayDataCopyWith<__DisplayData> get copyWith => __$_DisplayDataCopyWithImpl<__DisplayData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __DisplayData&&(identical(other.display, display) || other.display == display)&&(identical(other.history, history) || other.history == history)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,display,history,error);

@override
String toString() {
  return '_DisplayData(display: $display, history: $history, error: $error)';
}


}

/// @nodoc
abstract mixin class _$_DisplayDataCopyWith<$Res> implements _$DisplayDataCopyWith<$Res> {
  factory _$_DisplayDataCopyWith(__DisplayData value, $Res Function(__DisplayData) _then) = __$_DisplayDataCopyWithImpl;
@override @useResult
$Res call({
 String display, String history, CalculatorError? error
});




}
/// @nodoc
class __$_DisplayDataCopyWithImpl<$Res>
    implements _$_DisplayDataCopyWith<$Res> {
  __$_DisplayDataCopyWithImpl(this._self, this._then);

  final __DisplayData _self;
  final $Res Function(__DisplayData) _then;

/// Create a copy of _DisplayData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? display = null,Object? history = null,Object? error = freezed,}) {
  return _then(__DisplayData(
display: null == display ? _self.display : display // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as CalculatorError?,
  ));
}


}

// dart format on
