// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_device_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IotDeviceCommand {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotDeviceCommand);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IotDeviceCommand()';
}


}

/// @nodoc
class $IotDeviceCommandCopyWith<$Res>  {
$IotDeviceCommandCopyWith(IotDeviceCommand _, $Res Function(IotDeviceCommand) __);
}


/// Adds pattern-matching-related methods to [IotDeviceCommand].
extension IotDeviceCommandPatterns on IotDeviceCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( IotDeviceCommandToggle value)?  toggle,TResult Function( IotDeviceCommandSetValue value)?  setValue,required TResult orElse(),}){
final _that = this;
switch (_that) {
case IotDeviceCommandToggle() when toggle != null:
return toggle(_that);case IotDeviceCommandSetValue() when setValue != null:
return setValue(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( IotDeviceCommandToggle value)  toggle,required TResult Function( IotDeviceCommandSetValue value)  setValue,}){
final _that = this;
switch (_that) {
case IotDeviceCommandToggle():
return toggle(_that);case IotDeviceCommandSetValue():
return setValue(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( IotDeviceCommandToggle value)?  toggle,TResult? Function( IotDeviceCommandSetValue value)?  setValue,}){
final _that = this;
switch (_that) {
case IotDeviceCommandToggle() when toggle != null:
return toggle(_that);case IotDeviceCommandSetValue() when setValue != null:
return setValue(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  toggle,TResult Function( num value)?  setValue,required TResult orElse(),}) {final _that = this;
switch (_that) {
case IotDeviceCommandToggle() when toggle != null:
return toggle();case IotDeviceCommandSetValue() when setValue != null:
return setValue(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  toggle,required TResult Function( num value)  setValue,}) {final _that = this;
switch (_that) {
case IotDeviceCommandToggle():
return toggle();case IotDeviceCommandSetValue():
return setValue(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  toggle,TResult? Function( num value)?  setValue,}) {final _that = this;
switch (_that) {
case IotDeviceCommandToggle() when toggle != null:
return toggle();case IotDeviceCommandSetValue() when setValue != null:
return setValue(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class IotDeviceCommandToggle implements IotDeviceCommand {
  const IotDeviceCommandToggle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotDeviceCommandToggle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IotDeviceCommand.toggle()';
}


}




/// @nodoc


class IotDeviceCommandSetValue implements IotDeviceCommand {
  const IotDeviceCommandSetValue(this.value);
  

 final  num value;

/// Create a copy of IotDeviceCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IotDeviceCommandSetValueCopyWith<IotDeviceCommandSetValue> get copyWith => _$IotDeviceCommandSetValueCopyWithImpl<IotDeviceCommandSetValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotDeviceCommandSetValue&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'IotDeviceCommand.setValue(value: $value)';
}


}

/// @nodoc
abstract mixin class $IotDeviceCommandSetValueCopyWith<$Res> implements $IotDeviceCommandCopyWith<$Res> {
  factory $IotDeviceCommandSetValueCopyWith(IotDeviceCommandSetValue value, $Res Function(IotDeviceCommandSetValue) _then) = _$IotDeviceCommandSetValueCopyWithImpl;
@useResult
$Res call({
 num value
});




}
/// @nodoc
class _$IotDeviceCommandSetValueCopyWithImpl<$Res>
    implements $IotDeviceCommandSetValueCopyWith<$Res> {
  _$IotDeviceCommandSetValueCopyWithImpl(this._self, this._then);

  final IotDeviceCommandSetValue _self;
  final $Res Function(IotDeviceCommandSetValue) _then;

/// Create a copy of IotDeviceCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(IotDeviceCommandSetValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
