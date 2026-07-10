// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_platform_showcase_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NativePlatformShowcaseState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativePlatformShowcaseState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NativePlatformShowcaseState()';
}


}

/// @nodoc
class $NativePlatformShowcaseStateCopyWith<$Res>  {
$NativePlatformShowcaseStateCopyWith(NativePlatformShowcaseState _, $Res Function(NativePlatformShowcaseState) __);
}


/// Adds pattern-matching-related methods to [NativePlatformShowcaseState].
extension NativePlatformShowcaseStatePatterns on NativePlatformShowcaseState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( PlatformShowcaseData data,  NativeShowcaseTelemetrySnapshot? telemetry,  NativePlatformShowcaseAction? lastAction,  NativeInteropCallResult? lastActionResult,  NativePlatformShowcaseAction? actionInFlight)?  loaded,TResult Function( NativePlatformShowcaseFailureKind failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.data,_that.telemetry,_that.lastAction,_that.lastActionResult,_that.actionInFlight);case _Error() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( PlatformShowcaseData data,  NativeShowcaseTelemetrySnapshot? telemetry,  NativePlatformShowcaseAction? lastAction,  NativeInteropCallResult? lastActionResult,  NativePlatformShowcaseAction? actionInFlight)  loaded,required TResult Function( NativePlatformShowcaseFailureKind failure)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.data,_that.telemetry,_that.lastAction,_that.lastActionResult,_that.actionInFlight);case _Error():
return error(_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( PlatformShowcaseData data,  NativeShowcaseTelemetrySnapshot? telemetry,  NativePlatformShowcaseAction? lastAction,  NativeInteropCallResult? lastActionResult,  NativePlatformShowcaseAction? actionInFlight)?  loaded,TResult? Function( NativePlatformShowcaseFailureKind failure)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.data,_that.telemetry,_that.lastAction,_that.lastActionResult,_that.actionInFlight);case _Error() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements NativePlatformShowcaseState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NativePlatformShowcaseState.initial()';
}


}




/// @nodoc


class _Loading implements NativePlatformShowcaseState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NativePlatformShowcaseState.loading()';
}


}




/// @nodoc


class _Loaded implements NativePlatformShowcaseState {
  const _Loaded(this.data, {this.telemetry, this.lastAction, this.lastActionResult, this.actionInFlight});
  

 final  PlatformShowcaseData data;
 final  NativeShowcaseTelemetrySnapshot? telemetry;
 final  NativePlatformShowcaseAction? lastAction;
 final  NativeInteropCallResult? lastActionResult;
 final  NativePlatformShowcaseAction? actionInFlight;

/// Create a copy of NativePlatformShowcaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.data, data) || other.data == data)&&(identical(other.telemetry, telemetry) || other.telemetry == telemetry)&&(identical(other.lastAction, lastAction) || other.lastAction == lastAction)&&(identical(other.lastActionResult, lastActionResult) || other.lastActionResult == lastActionResult)&&(identical(other.actionInFlight, actionInFlight) || other.actionInFlight == actionInFlight));
}


@override
int get hashCode => Object.hash(runtimeType,data,telemetry,lastAction,lastActionResult,actionInFlight);

@override
String toString() {
  return 'NativePlatformShowcaseState.loaded(data: $data, telemetry: $telemetry, lastAction: $lastAction, lastActionResult: $lastActionResult, actionInFlight: $actionInFlight)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $NativePlatformShowcaseStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 PlatformShowcaseData data, NativeShowcaseTelemetrySnapshot? telemetry, NativePlatformShowcaseAction? lastAction, NativeInteropCallResult? lastActionResult, NativePlatformShowcaseAction? actionInFlight
});


$PlatformShowcaseDataCopyWith<$Res> get data;$NativeShowcaseTelemetrySnapshotCopyWith<$Res>? get telemetry;$NativeInteropCallResultCopyWith<$Res>? get lastActionResult;

}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of NativePlatformShowcaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,Object? telemetry = freezed,Object? lastAction = freezed,Object? lastActionResult = freezed,Object? actionInFlight = freezed,}) {
  return _then(_Loaded(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PlatformShowcaseData,telemetry: freezed == telemetry ? _self.telemetry : telemetry // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetrySnapshot?,lastAction: freezed == lastAction ? _self.lastAction : lastAction // ignore: cast_nullable_to_non_nullable
as NativePlatformShowcaseAction?,lastActionResult: freezed == lastActionResult ? _self.lastActionResult : lastActionResult // ignore: cast_nullable_to_non_nullable
as NativeInteropCallResult?,actionInFlight: freezed == actionInFlight ? _self.actionInFlight : actionInFlight // ignore: cast_nullable_to_non_nullable
as NativePlatformShowcaseAction?,
  ));
}

/// Create a copy of NativePlatformShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformShowcaseDataCopyWith<$Res> get data {
  
  return $PlatformShowcaseDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of NativePlatformShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeShowcaseTelemetrySnapshotCopyWith<$Res>? get telemetry {
    if (_self.telemetry == null) {
    return null;
  }

  return $NativeShowcaseTelemetrySnapshotCopyWith<$Res>(_self.telemetry!, (value) {
    return _then(_self.copyWith(telemetry: value));
  });
}/// Create a copy of NativePlatformShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeInteropCallResultCopyWith<$Res>? get lastActionResult {
    if (_self.lastActionResult == null) {
    return null;
  }

  return $NativeInteropCallResultCopyWith<$Res>(_self.lastActionResult!, (value) {
    return _then(_self.copyWith(lastActionResult: value));
  });
}
}

/// @nodoc


class _Error implements NativePlatformShowcaseState {
  const _Error({required this.failure});
  

 final  NativePlatformShowcaseFailureKind failure;

/// Create a copy of NativePlatformShowcaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'NativePlatformShowcaseState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $NativePlatformShowcaseStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 NativePlatformShowcaseFailureKind failure
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of NativePlatformShowcaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(_Error(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as NativePlatformShowcaseFailureKind,
  ));
}


}

// dart format on
