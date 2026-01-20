// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'genui_demo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenUiDemoState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenUiDemoState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GenUiDemoState()';
}


}

/// @nodoc
class $GenUiDemoStateCopyWith<$Res>  {
$GenUiDemoStateCopyWith(GenUiDemoState _, $Res Function(GenUiDemoState) __);
}


/// Adds pattern-matching-related methods to [GenUiDemoState].
extension GenUiDemoStatePatterns on GenUiDemoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Ready value)?  ready,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Ready value)  ready,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Ready():
return ready(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Ready value)?  ready,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( List<String> surfaceIds,  bool isSending,  genui.GenUiManager? hostHandle)?  loading,TResult Function( List<String> surfaceIds,  genui.GenUiManager? hostHandle,  bool isSending)?  ready,TResult Function( String message,  List<String> surfaceIds,  genui.GenUiManager? hostHandle)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading(_that.surfaceIds,_that.isSending,_that.hostHandle);case _Ready() when ready != null:
return ready(_that.surfaceIds,_that.hostHandle,_that.isSending);case _Error() when error != null:
return error(_that.message,_that.surfaceIds,_that.hostHandle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( List<String> surfaceIds,  bool isSending,  genui.GenUiManager? hostHandle)  loading,required TResult Function( List<String> surfaceIds,  genui.GenUiManager? hostHandle,  bool isSending)  ready,required TResult Function( String message,  List<String> surfaceIds,  genui.GenUiManager? hostHandle)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading(_that.surfaceIds,_that.isSending,_that.hostHandle);case _Ready():
return ready(_that.surfaceIds,_that.hostHandle,_that.isSending);case _Error():
return error(_that.message,_that.surfaceIds,_that.hostHandle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( List<String> surfaceIds,  bool isSending,  genui.GenUiManager? hostHandle)?  loading,TResult? Function( List<String> surfaceIds,  genui.GenUiManager? hostHandle,  bool isSending)?  ready,TResult? Function( String message,  List<String> surfaceIds,  genui.GenUiManager? hostHandle)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading(_that.surfaceIds,_that.isSending,_that.hostHandle);case _Ready() when ready != null:
return ready(_that.surfaceIds,_that.hostHandle,_that.isSending);case _Error() when error != null:
return error(_that.message,_that.surfaceIds,_that.hostHandle);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements GenUiDemoState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GenUiDemoState.initial()';
}


}




/// @nodoc


class _Loading implements GenUiDemoState {
  const _Loading({final  List<String> surfaceIds = const <String>[], this.isSending = false, this.hostHandle}): _surfaceIds = surfaceIds;
  

 final  List<String> _surfaceIds;
@JsonKey() List<String> get surfaceIds {
  if (_surfaceIds is EqualUnmodifiableListView) return _surfaceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surfaceIds);
}

@JsonKey() final  bool isSending;
 final  genui.GenUiManager? hostHandle;

/// Create a copy of GenUiDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadingCopyWith<_Loading> get copyWith => __$LoadingCopyWithImpl<_Loading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading&&const DeepCollectionEquality().equals(other._surfaceIds, _surfaceIds)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.hostHandle, hostHandle) || other.hostHandle == hostHandle));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_surfaceIds),isSending,hostHandle);

@override
String toString() {
  return 'GenUiDemoState.loading(surfaceIds: $surfaceIds, isSending: $isSending, hostHandle: $hostHandle)';
}


}

/// @nodoc
abstract mixin class _$LoadingCopyWith<$Res> implements $GenUiDemoStateCopyWith<$Res> {
  factory _$LoadingCopyWith(_Loading value, $Res Function(_Loading) _then) = __$LoadingCopyWithImpl;
@useResult
$Res call({
 List<String> surfaceIds, bool isSending, genui.GenUiManager? hostHandle
});




}
/// @nodoc
class __$LoadingCopyWithImpl<$Res>
    implements _$LoadingCopyWith<$Res> {
  __$LoadingCopyWithImpl(this._self, this._then);

  final _Loading _self;
  final $Res Function(_Loading) _then;

/// Create a copy of GenUiDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? surfaceIds = null,Object? isSending = null,Object? hostHandle = freezed,}) {
  return _then(_Loading(
surfaceIds: null == surfaceIds ? _self._surfaceIds : surfaceIds // ignore: cast_nullable_to_non_nullable
as List<String>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,hostHandle: freezed == hostHandle ? _self.hostHandle : hostHandle // ignore: cast_nullable_to_non_nullable
as genui.GenUiManager?,
  ));
}


}

/// @nodoc


class _Ready implements GenUiDemoState {
  const _Ready({required final  List<String> surfaceIds, required this.hostHandle, this.isSending = false}): _surfaceIds = surfaceIds;
  

 final  List<String> _surfaceIds;
 List<String> get surfaceIds {
  if (_surfaceIds is EqualUnmodifiableListView) return _surfaceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surfaceIds);
}

 final  genui.GenUiManager? hostHandle;
@JsonKey() final  bool isSending;

/// Create a copy of GenUiDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadyCopyWith<_Ready> get copyWith => __$ReadyCopyWithImpl<_Ready>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ready&&const DeepCollectionEquality().equals(other._surfaceIds, _surfaceIds)&&(identical(other.hostHandle, hostHandle) || other.hostHandle == hostHandle)&&(identical(other.isSending, isSending) || other.isSending == isSending));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_surfaceIds),hostHandle,isSending);

@override
String toString() {
  return 'GenUiDemoState.ready(surfaceIds: $surfaceIds, hostHandle: $hostHandle, isSending: $isSending)';
}


}

/// @nodoc
abstract mixin class _$ReadyCopyWith<$Res> implements $GenUiDemoStateCopyWith<$Res> {
  factory _$ReadyCopyWith(_Ready value, $Res Function(_Ready) _then) = __$ReadyCopyWithImpl;
@useResult
$Res call({
 List<String> surfaceIds, genui.GenUiManager? hostHandle, bool isSending
});




}
/// @nodoc
class __$ReadyCopyWithImpl<$Res>
    implements _$ReadyCopyWith<$Res> {
  __$ReadyCopyWithImpl(this._self, this._then);

  final _Ready _self;
  final $Res Function(_Ready) _then;

/// Create a copy of GenUiDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? surfaceIds = null,Object? hostHandle = freezed,Object? isSending = null,}) {
  return _then(_Ready(
surfaceIds: null == surfaceIds ? _self._surfaceIds : surfaceIds // ignore: cast_nullable_to_non_nullable
as List<String>,hostHandle: freezed == hostHandle ? _self.hostHandle : hostHandle // ignore: cast_nullable_to_non_nullable
as genui.GenUiManager?,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Error implements GenUiDemoState {
  const _Error({required this.message, final  List<String> surfaceIds = const <String>[], this.hostHandle}): _surfaceIds = surfaceIds;
  

 final  String message;
 final  List<String> _surfaceIds;
@JsonKey() List<String> get surfaceIds {
  if (_surfaceIds is EqualUnmodifiableListView) return _surfaceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_surfaceIds);
}

 final  genui.GenUiManager? hostHandle;

/// Create a copy of GenUiDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._surfaceIds, _surfaceIds)&&(identical(other.hostHandle, hostHandle) || other.hostHandle == hostHandle));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(_surfaceIds),hostHandle);

@override
String toString() {
  return 'GenUiDemoState.error(message: $message, surfaceIds: $surfaceIds, hostHandle: $hostHandle)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $GenUiDemoStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message, List<String> surfaceIds, genui.GenUiManager? hostHandle
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of GenUiDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? surfaceIds = null,Object? hostHandle = freezed,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,surfaceIds: null == surfaceIds ? _self._surfaceIds : surfaceIds // ignore: cast_nullable_to_non_nullable
as List<String>,hostHandle: freezed == hostHandle ? _self.hostHandle : hostHandle // ignore: cast_nullable_to_non_nullable
as genui.GenUiManager?,
  ));
}


}

// dart format on
