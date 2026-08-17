// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_showcase_telemetry_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NativeShowcaseTelemetrySnapshot {

 NativeShowcaseTelemetryStatus get status; int get schemaVersion; String get sessionId; int get sequence; int get acceptedCount; int get sourceReceivedCount; double get averageValue; int get sourceRateHz; int get deliveredRateHz; int get droppedBeforeBridgeCount; DateTime get windowStartedAt; DateTime get emittedAt; String? get message;
/// Create a copy of NativeShowcaseTelemetrySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeShowcaseTelemetrySnapshotCopyWith<NativeShowcaseTelemetrySnapshot> get copyWith => _$NativeShowcaseTelemetrySnapshotCopyWithImpl<NativeShowcaseTelemetrySnapshot>(this as NativeShowcaseTelemetrySnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeShowcaseTelemetrySnapshot&&(identical(other.status, status) || other.status == status)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.acceptedCount, acceptedCount) || other.acceptedCount == acceptedCount)&&(identical(other.sourceReceivedCount, sourceReceivedCount) || other.sourceReceivedCount == sourceReceivedCount)&&(identical(other.averageValue, averageValue) || other.averageValue == averageValue)&&(identical(other.sourceRateHz, sourceRateHz) || other.sourceRateHz == sourceRateHz)&&(identical(other.deliveredRateHz, deliveredRateHz) || other.deliveredRateHz == deliveredRateHz)&&(identical(other.droppedBeforeBridgeCount, droppedBeforeBridgeCount) || other.droppedBeforeBridgeCount == droppedBeforeBridgeCount)&&(identical(other.windowStartedAt, windowStartedAt) || other.windowStartedAt == windowStartedAt)&&(identical(other.emittedAt, emittedAt) || other.emittedAt == emittedAt)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,schemaVersion,sessionId,sequence,acceptedCount,sourceReceivedCount,averageValue,sourceRateHz,deliveredRateHz,droppedBeforeBridgeCount,windowStartedAt,emittedAt,message);

@override
String toString() {
  return 'NativeShowcaseTelemetrySnapshot(status: $status, schemaVersion: $schemaVersion, sessionId: $sessionId, sequence: $sequence, acceptedCount: $acceptedCount, sourceReceivedCount: $sourceReceivedCount, averageValue: $averageValue, sourceRateHz: $sourceRateHz, deliveredRateHz: $deliveredRateHz, droppedBeforeBridgeCount: $droppedBeforeBridgeCount, windowStartedAt: $windowStartedAt, emittedAt: $emittedAt, message: $message)';
}


}

/// @nodoc
abstract mixin class $NativeShowcaseTelemetrySnapshotCopyWith<$Res>  {
  factory $NativeShowcaseTelemetrySnapshotCopyWith(NativeShowcaseTelemetrySnapshot value, $Res Function(NativeShowcaseTelemetrySnapshot) _then) = _$NativeShowcaseTelemetrySnapshotCopyWithImpl;
@useResult
$Res call({
 NativeShowcaseTelemetryStatus status, int schemaVersion, String sessionId, int sequence, int acceptedCount, int sourceReceivedCount, double averageValue, int sourceRateHz, int deliveredRateHz, int droppedBeforeBridgeCount, DateTime windowStartedAt, DateTime emittedAt, String? message
});




}
/// @nodoc
class _$NativeShowcaseTelemetrySnapshotCopyWithImpl<$Res>
    implements $NativeShowcaseTelemetrySnapshotCopyWith<$Res> {
  _$NativeShowcaseTelemetrySnapshotCopyWithImpl(this._self, this._then);

  final NativeShowcaseTelemetrySnapshot _self;
  final $Res Function(NativeShowcaseTelemetrySnapshot) _then;

/// Create a copy of NativeShowcaseTelemetrySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? schemaVersion = null,Object? sessionId = null,Object? sequence = null,Object? acceptedCount = null,Object? sourceReceivedCount = null,Object? averageValue = null,Object? sourceRateHz = null,Object? deliveredRateHz = null,Object? droppedBeforeBridgeCount = null,Object? windowStartedAt = null,Object? emittedAt = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryStatus,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,acceptedCount: null == acceptedCount ? _self.acceptedCount : acceptedCount // ignore: cast_nullable_to_non_nullable
as int,sourceReceivedCount: null == sourceReceivedCount ? _self.sourceReceivedCount : sourceReceivedCount // ignore: cast_nullable_to_non_nullable
as int,averageValue: null == averageValue ? _self.averageValue : averageValue // ignore: cast_nullable_to_non_nullable
as double,sourceRateHz: null == sourceRateHz ? _self.sourceRateHz : sourceRateHz // ignore: cast_nullable_to_non_nullable
as int,deliveredRateHz: null == deliveredRateHz ? _self.deliveredRateHz : deliveredRateHz // ignore: cast_nullable_to_non_nullable
as int,droppedBeforeBridgeCount: null == droppedBeforeBridgeCount ? _self.droppedBeforeBridgeCount : droppedBeforeBridgeCount // ignore: cast_nullable_to_non_nullable
as int,windowStartedAt: null == windowStartedAt ? _self.windowStartedAt : windowStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,emittedAt: null == emittedAt ? _self.emittedAt : emittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NativeShowcaseTelemetrySnapshot].
extension NativeShowcaseTelemetrySnapshotPatterns on NativeShowcaseTelemetrySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeShowcaseTelemetrySnapshot value)?  $default,{required TResult orElse(),}){final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeShowcaseTelemetrySnapshot value)  $default,){final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeShowcaseTelemetrySnapshot value)?  $default,){final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NativeShowcaseTelemetryStatus status,  int schemaVersion,  String sessionId,  int sequence,  int acceptedCount,  int sourceReceivedCount,  double averageValue,  int sourceRateHz,  int deliveredRateHz,  int droppedBeforeBridgeCount,  DateTime windowStartedAt,  DateTime emittedAt,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot() when $default != null:
return $default(_that.status,_that.schemaVersion,_that.sessionId,_that.sequence,_that.acceptedCount,_that.sourceReceivedCount,_that.averageValue,_that.sourceRateHz,_that.deliveredRateHz,_that.droppedBeforeBridgeCount,_that.windowStartedAt,_that.emittedAt,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NativeShowcaseTelemetryStatus status,  int schemaVersion,  String sessionId,  int sequence,  int acceptedCount,  int sourceReceivedCount,  double averageValue,  int sourceRateHz,  int deliveredRateHz,  int droppedBeforeBridgeCount,  DateTime windowStartedAt,  DateTime emittedAt,  String? message)  $default,) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot():
return $default(_that.status,_that.schemaVersion,_that.sessionId,_that.sequence,_that.acceptedCount,_that.sourceReceivedCount,_that.averageValue,_that.sourceRateHz,_that.deliveredRateHz,_that.droppedBeforeBridgeCount,_that.windowStartedAt,_that.emittedAt,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NativeShowcaseTelemetryStatus status,  int schemaVersion,  String sessionId,  int sequence,  int acceptedCount,  int sourceReceivedCount,  double averageValue,  int sourceRateHz,  int deliveredRateHz,  int droppedBeforeBridgeCount,  DateTime windowStartedAt,  DateTime emittedAt,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot() when $default != null:
return $default(_that.status,_that.schemaVersion,_that.sessionId,_that.sequence,_that.acceptedCount,_that.sourceReceivedCount,_that.averageValue,_that.sourceRateHz,_that.deliveredRateHz,_that.droppedBeforeBridgeCount,_that.windowStartedAt,_that.emittedAt,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _NativeShowcaseTelemetrySnapshot implements NativeShowcaseTelemetrySnapshot {
  const _NativeShowcaseTelemetrySnapshot({required this.status, required this.schemaVersion, required this.sessionId, required this.sequence, required this.acceptedCount, required this.sourceReceivedCount, required this.averageValue, required this.sourceRateHz, required this.deliveredRateHz, required this.droppedBeforeBridgeCount, required this.windowStartedAt, required this.emittedAt, this.message});
  

@override final  NativeShowcaseTelemetryStatus status;
@override final  int schemaVersion;
@override final  String sessionId;
@override final  int sequence;
@override final  int acceptedCount;
@override final  int sourceReceivedCount;
@override final  double averageValue;
@override final  int sourceRateHz;
@override final  int deliveredRateHz;
@override final  int droppedBeforeBridgeCount;
@override final  DateTime windowStartedAt;
@override final  DateTime emittedAt;
@override final  String? message;

/// Create a copy of NativeShowcaseTelemetrySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeShowcaseTelemetrySnapshotCopyWith<_NativeShowcaseTelemetrySnapshot> get copyWith => __$NativeShowcaseTelemetrySnapshotCopyWithImpl<_NativeShowcaseTelemetrySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeShowcaseTelemetrySnapshot&&(identical(other.status, status) || other.status == status)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.acceptedCount, acceptedCount) || other.acceptedCount == acceptedCount)&&(identical(other.sourceReceivedCount, sourceReceivedCount) || other.sourceReceivedCount == sourceReceivedCount)&&(identical(other.averageValue, averageValue) || other.averageValue == averageValue)&&(identical(other.sourceRateHz, sourceRateHz) || other.sourceRateHz == sourceRateHz)&&(identical(other.deliveredRateHz, deliveredRateHz) || other.deliveredRateHz == deliveredRateHz)&&(identical(other.droppedBeforeBridgeCount, droppedBeforeBridgeCount) || other.droppedBeforeBridgeCount == droppedBeforeBridgeCount)&&(identical(other.windowStartedAt, windowStartedAt) || other.windowStartedAt == windowStartedAt)&&(identical(other.emittedAt, emittedAt) || other.emittedAt == emittedAt)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,schemaVersion,sessionId,sequence,acceptedCount,sourceReceivedCount,averageValue,sourceRateHz,deliveredRateHz,droppedBeforeBridgeCount,windowStartedAt,emittedAt,message);

@override
String toString() {
  return 'NativeShowcaseTelemetrySnapshot(status: $status, schemaVersion: $schemaVersion, sessionId: $sessionId, sequence: $sequence, acceptedCount: $acceptedCount, sourceReceivedCount: $sourceReceivedCount, averageValue: $averageValue, sourceRateHz: $sourceRateHz, deliveredRateHz: $deliveredRateHz, droppedBeforeBridgeCount: $droppedBeforeBridgeCount, windowStartedAt: $windowStartedAt, emittedAt: $emittedAt, message: $message)';
}


}

/// @nodoc
abstract mixin class _$NativeShowcaseTelemetrySnapshotCopyWith<$Res> implements $NativeShowcaseTelemetrySnapshotCopyWith<$Res> {
  factory _$NativeShowcaseTelemetrySnapshotCopyWith(_NativeShowcaseTelemetrySnapshot value, $Res Function(_NativeShowcaseTelemetrySnapshot) _then) = __$NativeShowcaseTelemetrySnapshotCopyWithImpl;
@override @useResult
$Res call({
 NativeShowcaseTelemetryStatus status, int schemaVersion, String sessionId, int sequence, int acceptedCount, int sourceReceivedCount, double averageValue, int sourceRateHz, int deliveredRateHz, int droppedBeforeBridgeCount, DateTime windowStartedAt, DateTime emittedAt, String? message
});




}
/// @nodoc
class __$NativeShowcaseTelemetrySnapshotCopyWithImpl<$Res>
    implements _$NativeShowcaseTelemetrySnapshotCopyWith<$Res> {
  __$NativeShowcaseTelemetrySnapshotCopyWithImpl(this._self, this._then);

  final _NativeShowcaseTelemetrySnapshot _self;
  final $Res Function(_NativeShowcaseTelemetrySnapshot) _then;

/// Create a copy of NativeShowcaseTelemetrySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? schemaVersion = null,Object? sessionId = null,Object? sequence = null,Object? acceptedCount = null,Object? sourceReceivedCount = null,Object? averageValue = null,Object? sourceRateHz = null,Object? deliveredRateHz = null,Object? droppedBeforeBridgeCount = null,Object? windowStartedAt = null,Object? emittedAt = null,Object? message = freezed,}) {
  return _then(_NativeShowcaseTelemetrySnapshot(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryStatus,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,acceptedCount: null == acceptedCount ? _self.acceptedCount : acceptedCount // ignore: cast_nullable_to_non_nullable
as int,sourceReceivedCount: null == sourceReceivedCount ? _self.sourceReceivedCount : sourceReceivedCount // ignore: cast_nullable_to_non_nullable
as int,averageValue: null == averageValue ? _self.averageValue : averageValue // ignore: cast_nullable_to_non_nullable
as double,sourceRateHz: null == sourceRateHz ? _self.sourceRateHz : sourceRateHz // ignore: cast_nullable_to_non_nullable
as int,deliveredRateHz: null == deliveredRateHz ? _self.deliveredRateHz : deliveredRateHz // ignore: cast_nullable_to_non_nullable
as int,droppedBeforeBridgeCount: null == droppedBeforeBridgeCount ? _self.droppedBeforeBridgeCount : droppedBeforeBridgeCount // ignore: cast_nullable_to_non_nullable
as int,windowStartedAt: null == windowStartedAt ? _self.windowStartedAt : windowStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime,emittedAt: null == emittedAt ? _self.emittedAt : emittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
