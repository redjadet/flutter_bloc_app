// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_showcase_telemetry_stream_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NativeShowcaseTelemetryStreamConfig {

 int get schemaVersion; NativeShowcaseTelemetryMode get mode; int get maxDeliveryHz; NativeShowcaseTelemetryAggregation get aggregation; String get sessionId;
/// Create a copy of NativeShowcaseTelemetryStreamConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeShowcaseTelemetryStreamConfigCopyWith<NativeShowcaseTelemetryStreamConfig> get copyWith => _$NativeShowcaseTelemetryStreamConfigCopyWithImpl<NativeShowcaseTelemetryStreamConfig>(this as NativeShowcaseTelemetryStreamConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeShowcaseTelemetryStreamConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.maxDeliveryHz, maxDeliveryHz) || other.maxDeliveryHz == maxDeliveryHz)&&(identical(other.aggregation, aggregation) || other.aggregation == aggregation)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,mode,maxDeliveryHz,aggregation,sessionId);

@override
String toString() {
  return 'NativeShowcaseTelemetryStreamConfig(schemaVersion: $schemaVersion, mode: $mode, maxDeliveryHz: $maxDeliveryHz, aggregation: $aggregation, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $NativeShowcaseTelemetryStreamConfigCopyWith<$Res>  {
  factory $NativeShowcaseTelemetryStreamConfigCopyWith(NativeShowcaseTelemetryStreamConfig value, $Res Function(NativeShowcaseTelemetryStreamConfig) _then) = _$NativeShowcaseTelemetryStreamConfigCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, NativeShowcaseTelemetryMode mode, int maxDeliveryHz, NativeShowcaseTelemetryAggregation aggregation, String sessionId
});




}
/// @nodoc
class _$NativeShowcaseTelemetryStreamConfigCopyWithImpl<$Res>
    implements $NativeShowcaseTelemetryStreamConfigCopyWith<$Res> {
  _$NativeShowcaseTelemetryStreamConfigCopyWithImpl(this._self, this._then);

  final NativeShowcaseTelemetryStreamConfig _self;
  final $Res Function(NativeShowcaseTelemetryStreamConfig) _then;

/// Create a copy of NativeShowcaseTelemetryStreamConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? mode = null,Object? maxDeliveryHz = null,Object? aggregation = null,Object? sessionId = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryMode,maxDeliveryHz: null == maxDeliveryHz ? _self.maxDeliveryHz : maxDeliveryHz // ignore: cast_nullable_to_non_nullable
as int,aggregation: null == aggregation ? _self.aggregation : aggregation // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryAggregation,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NativeShowcaseTelemetryStreamConfig].
extension NativeShowcaseTelemetryStreamConfigPatterns on NativeShowcaseTelemetryStreamConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeShowcaseTelemetryStreamConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NativeShowcaseTelemetryStreamConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeShowcaseTelemetryStreamConfig value)  $default,){
final _that = this;
switch (_that) {
case _NativeShowcaseTelemetryStreamConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeShowcaseTelemetryStreamConfig value)?  $default,){
final _that = this;
switch (_that) {
case _NativeShowcaseTelemetryStreamConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  NativeShowcaseTelemetryMode mode,  int maxDeliveryHz,  NativeShowcaseTelemetryAggregation aggregation,  String sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetryStreamConfig() when $default != null:
return $default(_that.schemaVersion,_that.mode,_that.maxDeliveryHz,_that.aggregation,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  NativeShowcaseTelemetryMode mode,  int maxDeliveryHz,  NativeShowcaseTelemetryAggregation aggregation,  String sessionId)  $default,) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetryStreamConfig():
return $default(_that.schemaVersion,_that.mode,_that.maxDeliveryHz,_that.aggregation,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  NativeShowcaseTelemetryMode mode,  int maxDeliveryHz,  NativeShowcaseTelemetryAggregation aggregation,  String sessionId)?  $default,) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetryStreamConfig() when $default != null:
return $default(_that.schemaVersion,_that.mode,_that.maxDeliveryHz,_that.aggregation,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc


class _NativeShowcaseTelemetryStreamConfig extends NativeShowcaseTelemetryStreamConfig {
  const _NativeShowcaseTelemetryStreamConfig({required this.schemaVersion, required this.mode, required this.maxDeliveryHz, required this.aggregation, required this.sessionId}): super._();
  

@override final  int schemaVersion;
@override final  NativeShowcaseTelemetryMode mode;
@override final  int maxDeliveryHz;
@override final  NativeShowcaseTelemetryAggregation aggregation;
@override final  String sessionId;

/// Create a copy of NativeShowcaseTelemetryStreamConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeShowcaseTelemetryStreamConfigCopyWith<_NativeShowcaseTelemetryStreamConfig> get copyWith => __$NativeShowcaseTelemetryStreamConfigCopyWithImpl<_NativeShowcaseTelemetryStreamConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeShowcaseTelemetryStreamConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.maxDeliveryHz, maxDeliveryHz) || other.maxDeliveryHz == maxDeliveryHz)&&(identical(other.aggregation, aggregation) || other.aggregation == aggregation)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,mode,maxDeliveryHz,aggregation,sessionId);

@override
String toString() {
  return 'NativeShowcaseTelemetryStreamConfig(schemaVersion: $schemaVersion, mode: $mode, maxDeliveryHz: $maxDeliveryHz, aggregation: $aggregation, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$NativeShowcaseTelemetryStreamConfigCopyWith<$Res> implements $NativeShowcaseTelemetryStreamConfigCopyWith<$Res> {
  factory _$NativeShowcaseTelemetryStreamConfigCopyWith(_NativeShowcaseTelemetryStreamConfig value, $Res Function(_NativeShowcaseTelemetryStreamConfig) _then) = __$NativeShowcaseTelemetryStreamConfigCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, NativeShowcaseTelemetryMode mode, int maxDeliveryHz, NativeShowcaseTelemetryAggregation aggregation, String sessionId
});




}
/// @nodoc
class __$NativeShowcaseTelemetryStreamConfigCopyWithImpl<$Res>
    implements _$NativeShowcaseTelemetryStreamConfigCopyWith<$Res> {
  __$NativeShowcaseTelemetryStreamConfigCopyWithImpl(this._self, this._then);

  final _NativeShowcaseTelemetryStreamConfig _self;
  final $Res Function(_NativeShowcaseTelemetryStreamConfig) _then;

/// Create a copy of NativeShowcaseTelemetryStreamConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? mode = null,Object? maxDeliveryHz = null,Object? aggregation = null,Object? sessionId = null,}) {
  return _then(_NativeShowcaseTelemetryStreamConfig(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryMode,maxDeliveryHz: null == maxDeliveryHz ? _self.maxDeliveryHz : maxDeliveryHz // ignore: cast_nullable_to_non_nullable
as int,aggregation: null == aggregation ? _self.aggregation : aggregation // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryAggregation,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
