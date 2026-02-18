// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_config_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RemoteConfigSnapshot {

 Map<String, dynamic> get values; DateTime? get lastFetchedAt; String? get templateVersion; String? get dataSource; DateTime? get lastSyncedAt;
/// Create a copy of RemoteConfigSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteConfigSnapshotCopyWith<RemoteConfigSnapshot> get copyWith => _$RemoteConfigSnapshotCopyWithImpl<RemoteConfigSnapshot>(this as RemoteConfigSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteConfigSnapshot&&const DeepCollectionEquality().equals(other.values, values)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.templateVersion, templateVersion) || other.templateVersion == templateVersion)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(values),lastFetchedAt,templateVersion,dataSource,lastSyncedAt);

@override
String toString() {
  return 'RemoteConfigSnapshot(values: $values, lastFetchedAt: $lastFetchedAt, templateVersion: $templateVersion, dataSource: $dataSource, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $RemoteConfigSnapshotCopyWith<$Res>  {
  factory $RemoteConfigSnapshotCopyWith(RemoteConfigSnapshot value, $Res Function(RemoteConfigSnapshot) _then) = _$RemoteConfigSnapshotCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> values, DateTime? lastFetchedAt, String? templateVersion, String? dataSource, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$RemoteConfigSnapshotCopyWithImpl<$Res>
    implements $RemoteConfigSnapshotCopyWith<$Res> {
  _$RemoteConfigSnapshotCopyWithImpl(this._self, this._then);

  final RemoteConfigSnapshot _self;
  final $Res Function(RemoteConfigSnapshot) _then;

/// Create a copy of RemoteConfigSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? values = null,Object? lastFetchedAt = freezed,Object? templateVersion = freezed,Object? dataSource = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,templateVersion: freezed == templateVersion ? _self.templateVersion : templateVersion // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteConfigSnapshot].
extension RemoteConfigSnapshotPatterns on RemoteConfigSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteConfigSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteConfigSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteConfigSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RemoteConfigSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteConfigSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteConfigSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> values,  DateTime? lastFetchedAt,  String? templateVersion,  String? dataSource,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteConfigSnapshot() when $default != null:
return $default(_that.values,_that.lastFetchedAt,_that.templateVersion,_that.dataSource,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> values,  DateTime? lastFetchedAt,  String? templateVersion,  String? dataSource,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _RemoteConfigSnapshot():
return $default(_that.values,_that.lastFetchedAt,_that.templateVersion,_that.dataSource,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> values,  DateTime? lastFetchedAt,  String? templateVersion,  String? dataSource,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _RemoteConfigSnapshot() when $default != null:
return $default(_that.values,_that.lastFetchedAt,_that.templateVersion,_that.dataSource,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RemoteConfigSnapshot extends RemoteConfigSnapshot {
   _RemoteConfigSnapshot({required final  Map<String, dynamic> values, this.lastFetchedAt, this.templateVersion, this.dataSource, this.lastSyncedAt}): _values = values,super._();
  

 final  Map<String, dynamic> _values;
@override Map<String, dynamic> get values {
  if (_values is EqualUnmodifiableMapView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_values);
}

@override final  DateTime? lastFetchedAt;
@override final  String? templateVersion;
@override final  String? dataSource;
@override final  DateTime? lastSyncedAt;

/// Create a copy of RemoteConfigSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteConfigSnapshotCopyWith<_RemoteConfigSnapshot> get copyWith => __$RemoteConfigSnapshotCopyWithImpl<_RemoteConfigSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteConfigSnapshot&&const DeepCollectionEquality().equals(other._values, _values)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.templateVersion, templateVersion) || other.templateVersion == templateVersion)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_values),lastFetchedAt,templateVersion,dataSource,lastSyncedAt);

@override
String toString() {
  return 'RemoteConfigSnapshot(values: $values, lastFetchedAt: $lastFetchedAt, templateVersion: $templateVersion, dataSource: $dataSource, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$RemoteConfigSnapshotCopyWith<$Res> implements $RemoteConfigSnapshotCopyWith<$Res> {
  factory _$RemoteConfigSnapshotCopyWith(_RemoteConfigSnapshot value, $Res Function(_RemoteConfigSnapshot) _then) = __$RemoteConfigSnapshotCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> values, DateTime? lastFetchedAt, String? templateVersion, String? dataSource, DateTime? lastSyncedAt
});




}
/// @nodoc
class __$RemoteConfigSnapshotCopyWithImpl<$Res>
    implements _$RemoteConfigSnapshotCopyWith<$Res> {
  __$RemoteConfigSnapshotCopyWithImpl(this._self, this._then);

  final _RemoteConfigSnapshot _self;
  final $Res Function(_RemoteConfigSnapshot) _then;

/// Create a copy of RemoteConfigSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? values = null,Object? lastFetchedAt = freezed,Object? templateVersion = freezed,Object? dataSource = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_RemoteConfigSnapshot(
values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,templateVersion: freezed == templateVersion ? _self.templateVersion : templateVersion // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
