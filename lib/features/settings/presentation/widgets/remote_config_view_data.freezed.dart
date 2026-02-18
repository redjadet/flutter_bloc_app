// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_config_view_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RemoteConfigViewData {

 RemoteConfigViewStatus get status; String? get errorMessage; bool get isAwesomeFeatureEnabled; String? get testValue; String? get dataSource; DateTime? get lastSyncedAt;
/// Create a copy of RemoteConfigViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteConfigViewDataCopyWith<RemoteConfigViewData> get copyWith => _$RemoteConfigViewDataCopyWithImpl<RemoteConfigViewData>(this as RemoteConfigViewData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteConfigViewData&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isAwesomeFeatureEnabled, isAwesomeFeatureEnabled) || other.isAwesomeFeatureEnabled == isAwesomeFeatureEnabled)&&(identical(other.testValue, testValue) || other.testValue == testValue)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,isAwesomeFeatureEnabled,testValue,dataSource,lastSyncedAt);

@override
String toString() {
  return 'RemoteConfigViewData(status: $status, errorMessage: $errorMessage, isAwesomeFeatureEnabled: $isAwesomeFeatureEnabled, testValue: $testValue, dataSource: $dataSource, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $RemoteConfigViewDataCopyWith<$Res>  {
  factory $RemoteConfigViewDataCopyWith(RemoteConfigViewData value, $Res Function(RemoteConfigViewData) _then) = _$RemoteConfigViewDataCopyWithImpl;
@useResult
$Res call({
 RemoteConfigViewStatus status, String? errorMessage, bool isAwesomeFeatureEnabled, String? testValue, String? dataSource, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$RemoteConfigViewDataCopyWithImpl<$Res>
    implements $RemoteConfigViewDataCopyWith<$Res> {
  _$RemoteConfigViewDataCopyWithImpl(this._self, this._then);

  final RemoteConfigViewData _self;
  final $Res Function(RemoteConfigViewData) _then;

/// Create a copy of RemoteConfigViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? isAwesomeFeatureEnabled = null,Object? testValue = freezed,Object? dataSource = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RemoteConfigViewStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isAwesomeFeatureEnabled: null == isAwesomeFeatureEnabled ? _self.isAwesomeFeatureEnabled : isAwesomeFeatureEnabled // ignore: cast_nullable_to_non_nullable
as bool,testValue: freezed == testValue ? _self.testValue : testValue // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteConfigViewData].
extension RemoteConfigViewDataPatterns on RemoteConfigViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteConfigViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteConfigViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteConfigViewData value)  $default,){
final _that = this;
switch (_that) {
case _RemoteConfigViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteConfigViewData value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteConfigViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RemoteConfigViewStatus status,  String? errorMessage,  bool isAwesomeFeatureEnabled,  String? testValue,  String? dataSource,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteConfigViewData() when $default != null:
return $default(_that.status,_that.errorMessage,_that.isAwesomeFeatureEnabled,_that.testValue,_that.dataSource,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RemoteConfigViewStatus status,  String? errorMessage,  bool isAwesomeFeatureEnabled,  String? testValue,  String? dataSource,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _RemoteConfigViewData():
return $default(_that.status,_that.errorMessage,_that.isAwesomeFeatureEnabled,_that.testValue,_that.dataSource,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RemoteConfigViewStatus status,  String? errorMessage,  bool isAwesomeFeatureEnabled,  String? testValue,  String? dataSource,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _RemoteConfigViewData() when $default != null:
return $default(_that.status,_that.errorMessage,_that.isAwesomeFeatureEnabled,_that.testValue,_that.dataSource,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RemoteConfigViewData extends RemoteConfigViewData {
  const _RemoteConfigViewData({required this.status, this.errorMessage, this.isAwesomeFeatureEnabled = false, this.testValue, this.dataSource, this.lastSyncedAt}): super._();
  

@override final  RemoteConfigViewStatus status;
@override final  String? errorMessage;
@override@JsonKey() final  bool isAwesomeFeatureEnabled;
@override final  String? testValue;
@override final  String? dataSource;
@override final  DateTime? lastSyncedAt;

/// Create a copy of RemoteConfigViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteConfigViewDataCopyWith<_RemoteConfigViewData> get copyWith => __$RemoteConfigViewDataCopyWithImpl<_RemoteConfigViewData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteConfigViewData&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isAwesomeFeatureEnabled, isAwesomeFeatureEnabled) || other.isAwesomeFeatureEnabled == isAwesomeFeatureEnabled)&&(identical(other.testValue, testValue) || other.testValue == testValue)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,isAwesomeFeatureEnabled,testValue,dataSource,lastSyncedAt);

@override
String toString() {
  return 'RemoteConfigViewData(status: $status, errorMessage: $errorMessage, isAwesomeFeatureEnabled: $isAwesomeFeatureEnabled, testValue: $testValue, dataSource: $dataSource, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$RemoteConfigViewDataCopyWith<$Res> implements $RemoteConfigViewDataCopyWith<$Res> {
  factory _$RemoteConfigViewDataCopyWith(_RemoteConfigViewData value, $Res Function(_RemoteConfigViewData) _then) = __$RemoteConfigViewDataCopyWithImpl;
@override @useResult
$Res call({
 RemoteConfigViewStatus status, String? errorMessage, bool isAwesomeFeatureEnabled, String? testValue, String? dataSource, DateTime? lastSyncedAt
});




}
/// @nodoc
class __$RemoteConfigViewDataCopyWithImpl<$Res>
    implements _$RemoteConfigViewDataCopyWith<$Res> {
  __$RemoteConfigViewDataCopyWithImpl(this._self, this._then);

  final _RemoteConfigViewData _self;
  final $Res Function(_RemoteConfigViewData) _then;

/// Create a copy of RemoteConfigViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? isAwesomeFeatureEnabled = null,Object? testValue = freezed,Object? dataSource = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_RemoteConfigViewData(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RemoteConfigViewStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isAwesomeFeatureEnabled: null == isAwesomeFeatureEnabled ? _self.isAwesomeFeatureEnabled : isAwesomeFeatureEnabled // ignore: cast_nullable_to_non_nullable
as bool,testValue: freezed == testValue ? _self.testValue : testValue // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
