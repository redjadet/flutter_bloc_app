// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_demo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IotDemoState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotDemoState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IotDemoState()';
}


}

/// @nodoc
class $IotDemoStateCopyWith<$Res>  {
$IotDemoStateCopyWith(IotDemoState _, $Res Function(IotDemoState) __);
}


/// Adds pattern-matching-related methods to [IotDemoState].
extension IotDemoStatePatterns on IotDemoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _IotDemoInitial value)?  initial,TResult Function( _IotDemoLoading value)?  loading,TResult Function( _IotDemoLoaded value)?  loaded,TResult Function( _IotDemoError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IotDemoInitial() when initial != null:
return initial(_that);case _IotDemoLoading() when loading != null:
return loading(_that);case _IotDemoLoaded() when loaded != null:
return loaded(_that);case _IotDemoError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _IotDemoInitial value)  initial,required TResult Function( _IotDemoLoading value)  loading,required TResult Function( _IotDemoLoaded value)  loaded,required TResult Function( _IotDemoError value)  error,}){
final _that = this;
switch (_that) {
case _IotDemoInitial():
return initial(_that);case _IotDemoLoading():
return loading(_that);case _IotDemoLoaded():
return loaded(_that);case _IotDemoError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _IotDemoInitial value)?  initial,TResult? Function( _IotDemoLoading value)?  loading,TResult? Function( _IotDemoLoaded value)?  loaded,TResult? Function( _IotDemoError value)?  error,}){
final _that = this;
switch (_that) {
case _IotDemoInitial() when initial != null:
return initial(_that);case _IotDemoLoading() when loading != null:
return loading(_that);case _IotDemoLoaded() when loaded != null:
return loaded(_that);case _IotDemoError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<IotDevice> devices,  String? selectedDeviceId,  IotDemoDeviceFilter filter)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IotDemoInitial() when initial != null:
return initial();case _IotDemoLoading() when loading != null:
return loading();case _IotDemoLoaded() when loaded != null:
return loaded(_that.devices,_that.selectedDeviceId,_that.filter);case _IotDemoError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<IotDevice> devices,  String? selectedDeviceId,  IotDemoDeviceFilter filter)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _IotDemoInitial():
return initial();case _IotDemoLoading():
return loading();case _IotDemoLoaded():
return loaded(_that.devices,_that.selectedDeviceId,_that.filter);case _IotDemoError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<IotDevice> devices,  String? selectedDeviceId,  IotDemoDeviceFilter filter)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _IotDemoInitial() when initial != null:
return initial();case _IotDemoLoading() when loading != null:
return loading();case _IotDemoLoaded() when loaded != null:
return loaded(_that.devices,_that.selectedDeviceId,_that.filter);case _IotDemoError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _IotDemoInitial implements IotDemoState {
  const _IotDemoInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IotDemoInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IotDemoState.initial()';
}


}




/// @nodoc


class _IotDemoLoading implements IotDemoState {
  const _IotDemoLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IotDemoLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IotDemoState.loading()';
}


}




/// @nodoc


class _IotDemoLoaded implements IotDemoState {
  const _IotDemoLoaded(final  List<IotDevice> devices, {this.selectedDeviceId, this.filter = IotDemoDeviceFilter.all}): _devices = devices;
  

 final  List<IotDevice> _devices;
 List<IotDevice> get devices {
  if (_devices is EqualUnmodifiableListView) return _devices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_devices);
}

 final  String? selectedDeviceId;
@JsonKey() final  IotDemoDeviceFilter filter;

/// Create a copy of IotDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IotDemoLoadedCopyWith<_IotDemoLoaded> get copyWith => __$IotDemoLoadedCopyWithImpl<_IotDemoLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IotDemoLoaded&&const DeepCollectionEquality().equals(other._devices, _devices)&&(identical(other.selectedDeviceId, selectedDeviceId) || other.selectedDeviceId == selectedDeviceId)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_devices),selectedDeviceId,filter);

@override
String toString() {
  return 'IotDemoState.loaded(devices: $devices, selectedDeviceId: $selectedDeviceId, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$IotDemoLoadedCopyWith<$Res> implements $IotDemoStateCopyWith<$Res> {
  factory _$IotDemoLoadedCopyWith(_IotDemoLoaded value, $Res Function(_IotDemoLoaded) _then) = __$IotDemoLoadedCopyWithImpl;
@useResult
$Res call({
 List<IotDevice> devices, String? selectedDeviceId, IotDemoDeviceFilter filter
});




}
/// @nodoc
class __$IotDemoLoadedCopyWithImpl<$Res>
    implements _$IotDemoLoadedCopyWith<$Res> {
  __$IotDemoLoadedCopyWithImpl(this._self, this._then);

  final _IotDemoLoaded _self;
  final $Res Function(_IotDemoLoaded) _then;

/// Create a copy of IotDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? devices = null,Object? selectedDeviceId = freezed,Object? filter = null,}) {
  return _then(_IotDemoLoaded(
null == devices ? _self._devices : devices // ignore: cast_nullable_to_non_nullable
as List<IotDevice>,selectedDeviceId: freezed == selectedDeviceId ? _self.selectedDeviceId : selectedDeviceId // ignore: cast_nullable_to_non_nullable
as String?,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as IotDemoDeviceFilter,
  ));
}


}

/// @nodoc


class _IotDemoError implements IotDemoState {
  const _IotDemoError(this.message);
  

 final  String message;

/// Create a copy of IotDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IotDemoErrorCopyWith<_IotDemoError> get copyWith => __$IotDemoErrorCopyWithImpl<_IotDemoError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IotDemoError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'IotDemoState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$IotDemoErrorCopyWith<$Res> implements $IotDemoStateCopyWith<$Res> {
  factory _$IotDemoErrorCopyWith(_IotDemoError value, $Res Function(_IotDemoError) _then) = __$IotDemoErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$IotDemoErrorCopyWithImpl<$Res>
    implements _$IotDemoErrorCopyWith<$Res> {
  __$IotDemoErrorCopyWithImpl(this._self, this._then);

  final _IotDemoError _self;
  final $Res Function(_IotDemoError) _then;

/// Create a copy of IotDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_IotDemoError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
