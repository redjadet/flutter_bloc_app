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

 NativeShowcaseTelemetryStatus get status; int get sequence; int get sampleCount; double get averageValue; int get sourceRateHz; int get deliveredRateHz; int get droppedCount; DateTime get emittedAt; String? get message;
/// Create a copy of NativeShowcaseTelemetrySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeShowcaseTelemetrySnapshotCopyWith<NativeShowcaseTelemetrySnapshot> get copyWith => _$NativeShowcaseTelemetrySnapshotCopyWithImpl<NativeShowcaseTelemetrySnapshot>(this as NativeShowcaseTelemetrySnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeShowcaseTelemetrySnapshot&&(identical(other.status, status) || other.status == status)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount)&&(identical(other.averageValue, averageValue) || other.averageValue == averageValue)&&(identical(other.sourceRateHz, sourceRateHz) || other.sourceRateHz == sourceRateHz)&&(identical(other.deliveredRateHz, deliveredRateHz) || other.deliveredRateHz == deliveredRateHz)&&(identical(other.droppedCount, droppedCount) || other.droppedCount == droppedCount)&&(identical(other.emittedAt, emittedAt) || other.emittedAt == emittedAt)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,sequence,sampleCount,averageValue,sourceRateHz,deliveredRateHz,droppedCount,emittedAt,message);

@override
String toString() {
  return 'NativeShowcaseTelemetrySnapshot(status: $status, sequence: $sequence, sampleCount: $sampleCount, averageValue: $averageValue, sourceRateHz: $sourceRateHz, deliveredRateHz: $deliveredRateHz, droppedCount: $droppedCount, emittedAt: $emittedAt, message: $message)';
}


}

/// @nodoc
abstract mixin class $NativeShowcaseTelemetrySnapshotCopyWith<$Res>  {
  factory $NativeShowcaseTelemetrySnapshotCopyWith(NativeShowcaseTelemetrySnapshot value, $Res Function(NativeShowcaseTelemetrySnapshot) _then) = _$NativeShowcaseTelemetrySnapshotCopyWithImpl;
@useResult
$Res call({
 NativeShowcaseTelemetryStatus status, int sequence, int sampleCount, double averageValue, int sourceRateHz, int deliveredRateHz, int droppedCount, DateTime emittedAt, String? message
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
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? sequence = null,Object? sampleCount = null,Object? averageValue = null,Object? sourceRateHz = null,Object? deliveredRateHz = null,Object? droppedCount = null,Object? emittedAt = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryStatus,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,averageValue: null == averageValue ? _self.averageValue : averageValue // ignore: cast_nullable_to_non_nullable
as double,sourceRateHz: null == sourceRateHz ? _self.sourceRateHz : sourceRateHz // ignore: cast_nullable_to_non_nullable
as int,deliveredRateHz: null == deliveredRateHz ? _self.deliveredRateHz : deliveredRateHz // ignore: cast_nullable_to_non_nullable
as int,droppedCount: null == droppedCount ? _self.droppedCount : droppedCount // ignore: cast_nullable_to_non_nullable
as int,emittedAt: null == emittedAt ? _self.emittedAt : emittedAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeShowcaseTelemetrySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeShowcaseTelemetrySnapshot value)  $default,){
final _that = this;
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeShowcaseTelemetrySnapshot value)?  $default,){
final _that = this;
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NativeShowcaseTelemetryStatus status,  int sequence,  int sampleCount,  double averageValue,  int sourceRateHz,  int deliveredRateHz,  int droppedCount,  DateTime emittedAt,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot() when $default != null:
return $default(_that.status,_that.sequence,_that.sampleCount,_that.averageValue,_that.sourceRateHz,_that.deliveredRateHz,_that.droppedCount,_that.emittedAt,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NativeShowcaseTelemetryStatus status,  int sequence,  int sampleCount,  double averageValue,  int sourceRateHz,  int deliveredRateHz,  int droppedCount,  DateTime emittedAt,  String? message)  $default,) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot():
return $default(_that.status,_that.sequence,_that.sampleCount,_that.averageValue,_that.sourceRateHz,_that.deliveredRateHz,_that.droppedCount,_that.emittedAt,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NativeShowcaseTelemetryStatus status,  int sequence,  int sampleCount,  double averageValue,  int sourceRateHz,  int deliveredRateHz,  int droppedCount,  DateTime emittedAt,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _NativeShowcaseTelemetrySnapshot() when $default != null:
return $default(_that.status,_that.sequence,_that.sampleCount,_that.averageValue,_that.sourceRateHz,_that.deliveredRateHz,_that.droppedCount,_that.emittedAt,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _NativeShowcaseTelemetrySnapshot implements NativeShowcaseTelemetrySnapshot {
  const _NativeShowcaseTelemetrySnapshot({required this.status, required this.sequence, required this.sampleCount, required this.averageValue, required this.sourceRateHz, required this.deliveredRateHz, required this.droppedCount, required this.emittedAt, this.message});
  

@override final  NativeShowcaseTelemetryStatus status;
@override final  int sequence;
@override final  int sampleCount;
@override final  double averageValue;
@override final  int sourceRateHz;
@override final  int deliveredRateHz;
@override final  int droppedCount;
@override final  DateTime emittedAt;
@override final  String? message;

/// Create a copy of NativeShowcaseTelemetrySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeShowcaseTelemetrySnapshotCopyWith<_NativeShowcaseTelemetrySnapshot> get copyWith => __$NativeShowcaseTelemetrySnapshotCopyWithImpl<_NativeShowcaseTelemetrySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeShowcaseTelemetrySnapshot&&(identical(other.status, status) || other.status == status)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount)&&(identical(other.averageValue, averageValue) || other.averageValue == averageValue)&&(identical(other.sourceRateHz, sourceRateHz) || other.sourceRateHz == sourceRateHz)&&(identical(other.deliveredRateHz, deliveredRateHz) || other.deliveredRateHz == deliveredRateHz)&&(identical(other.droppedCount, droppedCount) || other.droppedCount == droppedCount)&&(identical(other.emittedAt, emittedAt) || other.emittedAt == emittedAt)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,sequence,sampleCount,averageValue,sourceRateHz,deliveredRateHz,droppedCount,emittedAt,message);

@override
String toString() {
  return 'NativeShowcaseTelemetrySnapshot(status: $status, sequence: $sequence, sampleCount: $sampleCount, averageValue: $averageValue, sourceRateHz: $sourceRateHz, deliveredRateHz: $deliveredRateHz, droppedCount: $droppedCount, emittedAt: $emittedAt, message: $message)';
}


}

/// @nodoc
abstract mixin class _$NativeShowcaseTelemetrySnapshotCopyWith<$Res> implements $NativeShowcaseTelemetrySnapshotCopyWith<$Res> {
  factory _$NativeShowcaseTelemetrySnapshotCopyWith(_NativeShowcaseTelemetrySnapshot value, $Res Function(_NativeShowcaseTelemetrySnapshot) _then) = __$NativeShowcaseTelemetrySnapshotCopyWithImpl;
@override @useResult
$Res call({
 NativeShowcaseTelemetryStatus status, int sequence, int sampleCount, double averageValue, int sourceRateHz, int deliveredRateHz, int droppedCount, DateTime emittedAt, String? message
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
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? sequence = null,Object? sampleCount = null,Object? averageValue = null,Object? sourceRateHz = null,Object? deliveredRateHz = null,Object? droppedCount = null,Object? emittedAt = null,Object? message = freezed,}) {
  return _then(_NativeShowcaseTelemetrySnapshot(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeShowcaseTelemetryStatus,sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,averageValue: null == averageValue ? _self.averageValue : averageValue // ignore: cast_nullable_to_non_nullable
as double,sourceRateHz: null == sourceRateHz ? _self.sourceRateHz : sourceRateHz // ignore: cast_nullable_to_non_nullable
as int,deliveredRateHz: null == deliveredRateHz ? _self.deliveredRateHz : deliveredRateHz // ignore: cast_nullable_to_non_nullable
as int,droppedCount: null == droppedCount ? _self.droppedCount : droppedCount // ignore: cast_nullable_to_non_nullable
as int,emittedAt: null == emittedAt ? _self.emittedAt : emittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
