// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CounterState {

 int get count; DateTime? get lastChanged; int get countdownSeconds; bool get isAutoDecrementActive; CounterError? get error; CounterStatus get status;
/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterStateCopyWith<CounterState> get copyWith => _$CounterStateCopyWithImpl<CounterState>(this as CounterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterState&&(identical(other.count, count) || other.count == count)&&(identical(other.lastChanged, lastChanged) || other.lastChanged == lastChanged)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.isAutoDecrementActive, isAutoDecrementActive) || other.isAutoDecrementActive == isAutoDecrementActive)&&(identical(other.error, error) || other.error == error)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,count,lastChanged,countdownSeconds,isAutoDecrementActive,error,status);

@override
String toString() {
  return 'CounterState(count: $count, lastChanged: $lastChanged, countdownSeconds: $countdownSeconds, isAutoDecrementActive: $isAutoDecrementActive, error: $error, status: $status)';
}


}

/// @nodoc
abstract mixin class $CounterStateCopyWith<$Res>  {
  factory $CounterStateCopyWith(CounterState value, $Res Function(CounterState) _then) = _$CounterStateCopyWithImpl;
@useResult
$Res call({
 int count, DateTime? lastChanged, int countdownSeconds, bool isAutoDecrementActive, CounterError? error, CounterStatus status
});


$CounterErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$CounterStateCopyWithImpl<$Res>
    implements $CounterStateCopyWith<$Res> {
  _$CounterStateCopyWithImpl(this._self, this._then);

  final CounterState _self;
  final $Res Function(CounterState) _then;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? lastChanged = freezed,Object? countdownSeconds = null,Object? isAutoDecrementActive = null,Object? error = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastChanged: freezed == lastChanged ? _self.lastChanged : lastChanged // ignore: cast_nullable_to_non_nullable
as DateTime?,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,isAutoDecrementActive: null == isAutoDecrementActive ? _self.isAutoDecrementActive : isAutoDecrementActive // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as CounterError?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CounterStatus,
  ));
}
/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $CounterErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [CounterState].
extension CounterStatePatterns on CounterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CounterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CounterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CounterState value)  $default,){
final _that = this;
switch (_that) {
case _CounterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CounterState value)?  $default,){
final _that = this;
switch (_that) {
case _CounterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  DateTime? lastChanged,  int countdownSeconds,  bool isAutoDecrementActive,  CounterError? error,  CounterStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CounterState() when $default != null:
return $default(_that.count,_that.lastChanged,_that.countdownSeconds,_that.isAutoDecrementActive,_that.error,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  DateTime? lastChanged,  int countdownSeconds,  bool isAutoDecrementActive,  CounterError? error,  CounterStatus status)  $default,) {final _that = this;
switch (_that) {
case _CounterState():
return $default(_that.count,_that.lastChanged,_that.countdownSeconds,_that.isAutoDecrementActive,_that.error,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  DateTime? lastChanged,  int countdownSeconds,  bool isAutoDecrementActive,  CounterError? error,  CounterStatus status)?  $default,) {final _that = this;
switch (_that) {
case _CounterState() when $default != null:
return $default(_that.count,_that.lastChanged,_that.countdownSeconds,_that.isAutoDecrementActive,_that.error,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _CounterState extends CounterState {
  const _CounterState({required this.count, this.lastChanged, this.countdownSeconds = 5, this.isAutoDecrementActive = true, this.error, this.status = CounterStatus.idle}): super._();
  

@override final  int count;
@override final  DateTime? lastChanged;
@override@JsonKey() final  int countdownSeconds;
@override@JsonKey() final  bool isAutoDecrementActive;
@override final  CounterError? error;
@override@JsonKey() final  CounterStatus status;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CounterStateCopyWith<_CounterState> get copyWith => __$CounterStateCopyWithImpl<_CounterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CounterState&&(identical(other.count, count) || other.count == count)&&(identical(other.lastChanged, lastChanged) || other.lastChanged == lastChanged)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.isAutoDecrementActive, isAutoDecrementActive) || other.isAutoDecrementActive == isAutoDecrementActive)&&(identical(other.error, error) || other.error == error)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,count,lastChanged,countdownSeconds,isAutoDecrementActive,error,status);

@override
String toString() {
  return 'CounterState(count: $count, lastChanged: $lastChanged, countdownSeconds: $countdownSeconds, isAutoDecrementActive: $isAutoDecrementActive, error: $error, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CounterStateCopyWith<$Res> implements $CounterStateCopyWith<$Res> {
  factory _$CounterStateCopyWith(_CounterState value, $Res Function(_CounterState) _then) = __$CounterStateCopyWithImpl;
@override @useResult
$Res call({
 int count, DateTime? lastChanged, int countdownSeconds, bool isAutoDecrementActive, CounterError? error, CounterStatus status
});


@override $CounterErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$CounterStateCopyWithImpl<$Res>
    implements _$CounterStateCopyWith<$Res> {
  __$CounterStateCopyWithImpl(this._self, this._then);

  final _CounterState _self;
  final $Res Function(_CounterState) _then;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? lastChanged = freezed,Object? countdownSeconds = null,Object? isAutoDecrementActive = null,Object? error = freezed,Object? status = null,}) {
  return _then(_CounterState(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastChanged: freezed == lastChanged ? _self.lastChanged : lastChanged // ignore: cast_nullable_to_non_nullable
as DateTime?,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,isAutoDecrementActive: null == isAutoDecrementActive ? _self.isAutoDecrementActive : isAutoDecrementActive // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as CounterError?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CounterStatus,
  ));
}

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $CounterErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
