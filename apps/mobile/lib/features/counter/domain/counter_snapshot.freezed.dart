// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CounterSnapshot {

 int get count; String? get userId; DateTime? get lastChanged; String? get changeId; DateTime? get lastSyncedAt; bool get synchronized;
/// Create a copy of CounterSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterSnapshotCopyWith<CounterSnapshot> get copyWith => _$CounterSnapshotCopyWithImpl<CounterSnapshot>(this as CounterSnapshot, _$identity);

  /// Serializes this CounterSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterSnapshot&&(identical(other.count, count) || other.count == count)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastChanged, lastChanged) || other.lastChanged == lastChanged)&&(identical(other.changeId, changeId) || other.changeId == changeId)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.synchronized, synchronized) || other.synchronized == synchronized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,userId,lastChanged,changeId,lastSyncedAt,synchronized);

@override
String toString() {
  return 'CounterSnapshot(count: $count, userId: $userId, lastChanged: $lastChanged, changeId: $changeId, lastSyncedAt: $lastSyncedAt, synchronized: $synchronized)';
}


}

/// @nodoc
abstract mixin class $CounterSnapshotCopyWith<$Res>  {
  factory $CounterSnapshotCopyWith(CounterSnapshot value, $Res Function(CounterSnapshot) _then) = _$CounterSnapshotCopyWithImpl;
@useResult
$Res call({
 int count, String? userId, DateTime? lastChanged, String? changeId, DateTime? lastSyncedAt, bool synchronized
});




}
/// @nodoc
class _$CounterSnapshotCopyWithImpl<$Res>
    implements $CounterSnapshotCopyWith<$Res> {
  _$CounterSnapshotCopyWithImpl(this._self, this._then);

  final CounterSnapshot _self;
  final $Res Function(CounterSnapshot) _then;

/// Create a copy of CounterSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? userId = freezed,Object? lastChanged = freezed,Object? changeId = freezed,Object? lastSyncedAt = freezed,Object? synchronized = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,lastChanged: freezed == lastChanged ? _self.lastChanged : lastChanged // ignore: cast_nullable_to_non_nullable
as DateTime?,changeId: freezed == changeId ? _self.changeId : changeId // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,synchronized: null == synchronized ? _self.synchronized : synchronized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CounterSnapshot].
extension CounterSnapshotPatterns on CounterSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CounterSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CounterSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CounterSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _CounterSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CounterSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _CounterSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  String? userId,  DateTime? lastChanged,  String? changeId,  DateTime? lastSyncedAt,  bool synchronized)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CounterSnapshot() when $default != null:
return $default(_that.count,_that.userId,_that.lastChanged,_that.changeId,_that.lastSyncedAt,_that.synchronized);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  String? userId,  DateTime? lastChanged,  String? changeId,  DateTime? lastSyncedAt,  bool synchronized)  $default,) {final _that = this;
switch (_that) {
case _CounterSnapshot():
return $default(_that.count,_that.userId,_that.lastChanged,_that.changeId,_that.lastSyncedAt,_that.synchronized);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  String? userId,  DateTime? lastChanged,  String? changeId,  DateTime? lastSyncedAt,  bool synchronized)?  $default,) {final _that = this;
switch (_that) {
case _CounterSnapshot() when $default != null:
return $default(_that.count,_that.userId,_that.lastChanged,_that.changeId,_that.lastSyncedAt,_that.synchronized);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CounterSnapshot implements CounterSnapshot {
  const _CounterSnapshot({required this.count, this.userId, this.lastChanged, this.changeId, this.lastSyncedAt, this.synchronized = false});
  factory _CounterSnapshot.fromJson(Map<String, dynamic> json) => _$CounterSnapshotFromJson(json);

@override final  int count;
@override final  String? userId;
@override final  DateTime? lastChanged;
@override final  String? changeId;
@override final  DateTime? lastSyncedAt;
@override@JsonKey() final  bool synchronized;

/// Create a copy of CounterSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CounterSnapshotCopyWith<_CounterSnapshot> get copyWith => __$CounterSnapshotCopyWithImpl<_CounterSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CounterSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CounterSnapshot&&(identical(other.count, count) || other.count == count)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastChanged, lastChanged) || other.lastChanged == lastChanged)&&(identical(other.changeId, changeId) || other.changeId == changeId)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.synchronized, synchronized) || other.synchronized == synchronized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,userId,lastChanged,changeId,lastSyncedAt,synchronized);

@override
String toString() {
  return 'CounterSnapshot(count: $count, userId: $userId, lastChanged: $lastChanged, changeId: $changeId, lastSyncedAt: $lastSyncedAt, synchronized: $synchronized)';
}


}

/// @nodoc
abstract mixin class _$CounterSnapshotCopyWith<$Res> implements $CounterSnapshotCopyWith<$Res> {
  factory _$CounterSnapshotCopyWith(_CounterSnapshot value, $Res Function(_CounterSnapshot) _then) = __$CounterSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int count, String? userId, DateTime? lastChanged, String? changeId, DateTime? lastSyncedAt, bool synchronized
});




}
/// @nodoc
class __$CounterSnapshotCopyWithImpl<$Res>
    implements _$CounterSnapshotCopyWith<$Res> {
  __$CounterSnapshotCopyWithImpl(this._self, this._then);

  final _CounterSnapshot _self;
  final $Res Function(_CounterSnapshot) _then;

/// Create a copy of CounterSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? userId = freezed,Object? lastChanged = freezed,Object? changeId = freezed,Object? lastSyncedAt = freezed,Object? synchronized = null,}) {
  return _then(_CounterSnapshot(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,lastChanged: freezed == lastChanged ? _self.lastChanged : lastChanged // ignore: cast_nullable_to_non_nullable
as DateTime?,changeId: freezed == changeId ? _self.changeId : changeId // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,synchronized: null == synchronized ? _self.synchronized : synchronized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
