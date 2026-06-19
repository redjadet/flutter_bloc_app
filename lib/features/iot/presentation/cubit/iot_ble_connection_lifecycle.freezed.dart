// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_ble_connection_lifecycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IotBleConnectionLifecycle {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotBleConnectionLifecycle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IotBleConnectionLifecycle()';
}


}

/// @nodoc
class $IotBleConnectionLifecycleCopyWith<$Res>  {
$IotBleConnectionLifecycleCopyWith(IotBleConnectionLifecycle _, $Res Function(IotBleConnectionLifecycle) __);
}


/// Adds pattern-matching-related methods to [IotBleConnectionLifecycle].
extension IotBleConnectionLifecyclePatterns on IotBleConnectionLifecycle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( IotBleConnectionIdle value)?  idle,TResult Function( IotBleConnectionActive value)?  active,required TResult orElse(),}){
final _that = this;
switch (_that) {
case IotBleConnectionIdle() when idle != null:
return idle(_that);case IotBleConnectionActive() when active != null:
return active(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( IotBleConnectionIdle value)  idle,required TResult Function( IotBleConnectionActive value)  active,}){
final _that = this;
switch (_that) {
case IotBleConnectionIdle():
return idle(_that);case IotBleConnectionActive():
return active(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( IotBleConnectionIdle value)?  idle,TResult? Function( IotBleConnectionActive value)?  active,}){
final _that = this;
switch (_that) {
case IotBleConnectionIdle() when idle != null:
return idle(_that);case IotBleConnectionActive() when active != null:
return active(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? selectedDeviceId)?  idle,TResult Function( BleConnectionPhase phase)?  active,required TResult orElse(),}) {final _that = this;
switch (_that) {
case IotBleConnectionIdle() when idle != null:
return idle(_that.selectedDeviceId);case IotBleConnectionActive() when active != null:
return active(_that.phase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? selectedDeviceId)  idle,required TResult Function( BleConnectionPhase phase)  active,}) {final _that = this;
switch (_that) {
case IotBleConnectionIdle():
return idle(_that.selectedDeviceId);case IotBleConnectionActive():
return active(_that.phase);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? selectedDeviceId)?  idle,TResult? Function( BleConnectionPhase phase)?  active,}) {final _that = this;
switch (_that) {
case IotBleConnectionIdle() when idle != null:
return idle(_that.selectedDeviceId);case IotBleConnectionActive() when active != null:
return active(_that.phase);case _:
  return null;

}
}

}

/// @nodoc


class IotBleConnectionIdle extends IotBleConnectionLifecycle {
  const IotBleConnectionIdle({this.selectedDeviceId}): super._();


 final  String? selectedDeviceId;

/// Create a copy of IotBleConnectionLifecycle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IotBleConnectionIdleCopyWith<IotBleConnectionIdle> get copyWith => _$IotBleConnectionIdleCopyWithImpl<IotBleConnectionIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotBleConnectionIdle&&(identical(other.selectedDeviceId, selectedDeviceId) || other.selectedDeviceId == selectedDeviceId));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDeviceId);

@override
String toString() {
  return 'IotBleConnectionLifecycle.idle(selectedDeviceId: $selectedDeviceId)';
}


}

/// @nodoc
abstract mixin class $IotBleConnectionIdleCopyWith<$Res> implements $IotBleConnectionLifecycleCopyWith<$Res> {
  factory $IotBleConnectionIdleCopyWith(IotBleConnectionIdle value, $Res Function(IotBleConnectionIdle) _then) = _$IotBleConnectionIdleCopyWithImpl;
@useResult
$Res call({
 String? selectedDeviceId
});




}
/// @nodoc
class _$IotBleConnectionIdleCopyWithImpl<$Res>
    implements $IotBleConnectionIdleCopyWith<$Res> {
  _$IotBleConnectionIdleCopyWithImpl(this._self, this._then);

  final IotBleConnectionIdle _self;
  final $Res Function(IotBleConnectionIdle) _then;

/// Create a copy of IotBleConnectionLifecycle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedDeviceId = freezed,}) {
  return _then(IotBleConnectionIdle(
selectedDeviceId: freezed == selectedDeviceId ? _self.selectedDeviceId : selectedDeviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class IotBleConnectionActive extends IotBleConnectionLifecycle {
  const IotBleConnectionActive(this.phase): super._();


 final  BleConnectionPhase phase;

/// Create a copy of IotBleConnectionLifecycle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IotBleConnectionActiveCopyWith<IotBleConnectionActive> get copyWith => _$IotBleConnectionActiveCopyWithImpl<IotBleConnectionActive>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotBleConnectionActive&&(identical(other.phase, phase) || other.phase == phase));
}


@override
int get hashCode => Object.hash(runtimeType,phase);

@override
String toString() {
  return 'IotBleConnectionLifecycle.active(phase: $phase)';
}


}

/// @nodoc
abstract mixin class $IotBleConnectionActiveCopyWith<$Res> implements $IotBleConnectionLifecycleCopyWith<$Res> {
  factory $IotBleConnectionActiveCopyWith(IotBleConnectionActive value, $Res Function(IotBleConnectionActive) _then) = _$IotBleConnectionActiveCopyWithImpl;
@useResult
$Res call({
 BleConnectionPhase phase
});




}
/// @nodoc
class _$IotBleConnectionActiveCopyWithImpl<$Res>
    implements $IotBleConnectionActiveCopyWith<$Res> {
  _$IotBleConnectionActiveCopyWithImpl(this._self, this._then);

  final IotBleConnectionActive _self;
  final $Res Function(IotBleConnectionActive) _then;

/// Create a copy of IotBleConnectionLifecycle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,}) {
  return _then(IotBleConnectionActive(
null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as BleConnectionPhase,
  ));
}


}

// dart format on
