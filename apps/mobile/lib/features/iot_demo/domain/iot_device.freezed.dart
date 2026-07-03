// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IotDevice {

 String get id; String get name; IotDeviceType get type; DateTime? get lastSeen; IotConnectionState get connectionState; bool get toggledOn; double get value;
/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IotDeviceCopyWith<IotDevice> get copyWith => _$IotDeviceCopyWithImpl<IotDevice>(this as IotDevice, _$identity);

  /// Serializes this IotDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.connectionState, connectionState) || other.connectionState == connectionState)&&(identical(other.toggledOn, toggledOn) || other.toggledOn == toggledOn)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,lastSeen,connectionState,toggledOn,value);

@override
String toString() {
  return 'IotDevice(id: $id, name: $name, type: $type, lastSeen: $lastSeen, connectionState: $connectionState, toggledOn: $toggledOn, value: $value)';
}


}

/// @nodoc
abstract mixin class $IotDeviceCopyWith<$Res>  {
  factory $IotDeviceCopyWith(IotDevice value, $Res Function(IotDevice) _then) = _$IotDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String name, IotDeviceType type, DateTime? lastSeen, IotConnectionState connectionState, bool toggledOn, double value
});




}
/// @nodoc
class _$IotDeviceCopyWithImpl<$Res>
    implements $IotDeviceCopyWith<$Res> {
  _$IotDeviceCopyWithImpl(this._self, this._then);

  final IotDevice _self;
  final $Res Function(IotDevice) _then;

/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? lastSeen = freezed,Object? connectionState = null,Object? toggledOn = null,Object? value = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IotDeviceType,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,connectionState: null == connectionState ? _self.connectionState : connectionState // ignore: cast_nullable_to_non_nullable
as IotConnectionState,toggledOn: null == toggledOn ? _self.toggledOn : toggledOn // ignore: cast_nullable_to_non_nullable
as bool,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [IotDevice].
extension IotDevicePatterns on IotDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IotDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IotDevice value)  $default,){
final _that = this;
switch (_that) {
case _IotDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IotDevice value)?  $default,){
final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  IotDeviceType type,  DateTime? lastSeen,  IotConnectionState connectionState,  bool toggledOn,  double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.lastSeen,_that.connectionState,_that.toggledOn,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  IotDeviceType type,  DateTime? lastSeen,  IotConnectionState connectionState,  bool toggledOn,  double value)  $default,) {final _that = this;
switch (_that) {
case _IotDevice():
return $default(_that.id,_that.name,_that.type,_that.lastSeen,_that.connectionState,_that.toggledOn,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  IotDeviceType type,  DateTime? lastSeen,  IotConnectionState connectionState,  bool toggledOn,  double value)?  $default,) {final _that = this;
switch (_that) {
case _IotDevice() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.lastSeen,_that.connectionState,_that.toggledOn,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IotDevice extends IotDevice {
  const _IotDevice({required this.id, required this.name, required this.type, this.lastSeen, this.connectionState = IotConnectionState.disconnected, this.toggledOn = false, this.value = 0.0}): super._();
  factory _IotDevice.fromJson(Map<String, dynamic> json) => _$IotDeviceFromJson(json);

@override final  String id;
@override final  String name;
@override final  IotDeviceType type;
@override final  DateTime? lastSeen;
@override@JsonKey() final  IotConnectionState connectionState;
@override@JsonKey() final  bool toggledOn;
@override@JsonKey() final  double value;

/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IotDeviceCopyWith<_IotDevice> get copyWith => __$IotDeviceCopyWithImpl<_IotDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IotDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IotDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.connectionState, connectionState) || other.connectionState == connectionState)&&(identical(other.toggledOn, toggledOn) || other.toggledOn == toggledOn)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,lastSeen,connectionState,toggledOn,value);

@override
String toString() {
  return 'IotDevice(id: $id, name: $name, type: $type, lastSeen: $lastSeen, connectionState: $connectionState, toggledOn: $toggledOn, value: $value)';
}


}

/// @nodoc
abstract mixin class _$IotDeviceCopyWith<$Res> implements $IotDeviceCopyWith<$Res> {
  factory _$IotDeviceCopyWith(_IotDevice value, $Res Function(_IotDevice) _then) = __$IotDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, IotDeviceType type, DateTime? lastSeen, IotConnectionState connectionState, bool toggledOn, double value
});




}
/// @nodoc
class __$IotDeviceCopyWithImpl<$Res>
    implements _$IotDeviceCopyWith<$Res> {
  __$IotDeviceCopyWithImpl(this._self, this._then);

  final _IotDevice _self;
  final $Res Function(_IotDevice) _then;

/// Create a copy of IotDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? lastSeen = freezed,Object? connectionState = null,Object? toggledOn = null,Object? value = null,}) {
  return _then(_IotDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IotDeviceType,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,connectionState: null == connectionState ? _self.connectionState : connectionState // ignore: cast_nullable_to_non_nullable
as IotConnectionState,toggledOn: null == toggledOn ? _self.toggledOn : toggledOn // ignore: cast_nullable_to_non_nullable
as bool,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
