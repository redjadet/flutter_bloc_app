// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_hint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CounterHintData {

 int get count; bool get isLoading;
/// Create a copy of _CounterHintData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CounterHintDataCopyWith<_CounterHintData> get copyWith => __$CounterHintDataCopyWithImpl<_CounterHintData>(this as _CounterHintData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CounterHintData&&(identical(other.count, count) || other.count == count)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,count,isLoading);

@override
String toString() {
  return '_CounterHintData(count: $count, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$CounterHintDataCopyWith<$Res>  {
  factory _$CounterHintDataCopyWith(_CounterHintData value, $Res Function(_CounterHintData) _then) = __$CounterHintDataCopyWithImpl;
@useResult
$Res call({
 int count, bool isLoading
});




}
/// @nodoc
class __$CounterHintDataCopyWithImpl<$Res>
    implements _$CounterHintDataCopyWith<$Res> {
  __$CounterHintDataCopyWithImpl(this._self, this._then);

  final _CounterHintData _self;
  final $Res Function(_CounterHintData) _then;

/// Create a copy of _CounterHintData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [_CounterHintData].
extension _CounterHintDataPatterns on _CounterHintData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __CounterHintData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __CounterHintData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __CounterHintData value)  $default,){
final _that = this;
switch (_that) {
case __CounterHintData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __CounterHintData value)?  $default,){
final _that = this;
switch (_that) {
case __CounterHintData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __CounterHintData() when $default != null:
return $default(_that.count,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case __CounterHintData():
return $default(_that.count,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case __CounterHintData() when $default != null:
return $default(_that.count,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class __CounterHintData implements _CounterHintData {
  const __CounterHintData({required this.count, required this.isLoading});
  

@override final  int count;
@override final  bool isLoading;

/// Create a copy of _CounterHintData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_CounterHintDataCopyWith<__CounterHintData> get copyWith => __$_CounterHintDataCopyWithImpl<__CounterHintData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __CounterHintData&&(identical(other.count, count) || other.count == count)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,count,isLoading);

@override
String toString() {
  return '_CounterHintData(count: $count, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$_CounterHintDataCopyWith<$Res> implements _$CounterHintDataCopyWith<$Res> {
  factory _$_CounterHintDataCopyWith(__CounterHintData value, $Res Function(__CounterHintData) _then) = __$_CounterHintDataCopyWithImpl;
@override @useResult
$Res call({
 int count, bool isLoading
});




}
/// @nodoc
class __$_CounterHintDataCopyWithImpl<$Res>
    implements _$_CounterHintDataCopyWith<$Res> {
  __$_CounterHintDataCopyWithImpl(this._self, this._then);

  final __CounterHintData _self;
  final $Res Function(__CounterHintData) _then;

/// Create a copy of _CounterHintData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? isLoading = null,}) {
  return _then(__CounterHintData(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
