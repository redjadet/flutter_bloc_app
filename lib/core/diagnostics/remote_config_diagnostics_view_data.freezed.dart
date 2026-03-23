// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_config_diagnostics_view_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RemoteConfigDiagnosticsViewData {

 RemoteConfigDiagnosticsStatus get status; String? get errorMessage; bool get isAwesomeFeatureEnabled; String? get testValue; String? get dataSource; DateTime? get lastSyncedAt;
/// Create a copy of RemoteConfigDiagnosticsViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteConfigDiagnosticsViewDataCopyWith<RemoteConfigDiagnosticsViewData> get copyWith => _$RemoteConfigDiagnosticsViewDataCopyWithImpl<RemoteConfigDiagnosticsViewData>(this as RemoteConfigDiagnosticsViewData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteConfigDiagnosticsViewData&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isAwesomeFeatureEnabled, isAwesomeFeatureEnabled) || other.isAwesomeFeatureEnabled == isAwesomeFeatureEnabled)&&(identical(other.testValue, testValue) || other.testValue == testValue)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,isAwesomeFeatureEnabled,testValue,dataSource,lastSyncedAt);

@override
String toString() {
  return 'RemoteConfigDiagnosticsViewData(status: $status, errorMessage: $errorMessage, isAwesomeFeatureEnabled: $isAwesomeFeatureEnabled, testValue: $testValue, dataSource: $dataSource, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $RemoteConfigDiagnosticsViewDataCopyWith<$Res>  {
  factory $RemoteConfigDiagnosticsViewDataCopyWith(RemoteConfigDiagnosticsViewData value, $Res Function(RemoteConfigDiagnosticsViewData) _then) = _$RemoteConfigDiagnosticsViewDataCopyWithImpl;
@useResult
$Res call({
 RemoteConfigDiagnosticsStatus status, String? errorMessage, bool isAwesomeFeatureEnabled, String? testValue, String? dataSource, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$RemoteConfigDiagnosticsViewDataCopyWithImpl<$Res>
    implements $RemoteConfigDiagnosticsViewDataCopyWith<$Res> {
  _$RemoteConfigDiagnosticsViewDataCopyWithImpl(this._self, this._then);

  final RemoteConfigDiagnosticsViewData _self;
  final $Res Function(RemoteConfigDiagnosticsViewData) _then;

/// Create a copy of RemoteConfigDiagnosticsViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? isAwesomeFeatureEnabled = null,Object? testValue = freezed,Object? dataSource = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RemoteConfigDiagnosticsStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isAwesomeFeatureEnabled: null == isAwesomeFeatureEnabled ? _self.isAwesomeFeatureEnabled : isAwesomeFeatureEnabled // ignore: cast_nullable_to_non_nullable
as bool,testValue: freezed == testValue ? _self.testValue : testValue // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteConfigDiagnosticsViewData].
extension RemoteConfigDiagnosticsViewDataPatterns on RemoteConfigDiagnosticsViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteConfigDiagnosticsViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteConfigDiagnosticsViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteConfigDiagnosticsViewData value)  $default,){
final _that = this;
switch (_that) {
case _RemoteConfigDiagnosticsViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteConfigDiagnosticsViewData value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteConfigDiagnosticsViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RemoteConfigDiagnosticsStatus status,  String? errorMessage,  bool isAwesomeFeatureEnabled,  String? testValue,  String? dataSource,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteConfigDiagnosticsViewData() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RemoteConfigDiagnosticsStatus status,  String? errorMessage,  bool isAwesomeFeatureEnabled,  String? testValue,  String? dataSource,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _RemoteConfigDiagnosticsViewData():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RemoteConfigDiagnosticsStatus status,  String? errorMessage,  bool isAwesomeFeatureEnabled,  String? testValue,  String? dataSource,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _RemoteConfigDiagnosticsViewData() when $default != null:
return $default(_that.status,_that.errorMessage,_that.isAwesomeFeatureEnabled,_that.testValue,_that.dataSource,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RemoteConfigDiagnosticsViewData extends RemoteConfigDiagnosticsViewData {
  const _RemoteConfigDiagnosticsViewData({required this.status, this.errorMessage, this.isAwesomeFeatureEnabled = false, this.testValue, this.dataSource, this.lastSyncedAt}): super._();
  

@override final  RemoteConfigDiagnosticsStatus status;
@override final  String? errorMessage;
@override@JsonKey() final  bool isAwesomeFeatureEnabled;
@override final  String? testValue;
@override final  String? dataSource;
@override final  DateTime? lastSyncedAt;

/// Create a copy of RemoteConfigDiagnosticsViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteConfigDiagnosticsViewDataCopyWith<_RemoteConfigDiagnosticsViewData> get copyWith => __$RemoteConfigDiagnosticsViewDataCopyWithImpl<_RemoteConfigDiagnosticsViewData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteConfigDiagnosticsViewData&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isAwesomeFeatureEnabled, isAwesomeFeatureEnabled) || other.isAwesomeFeatureEnabled == isAwesomeFeatureEnabled)&&(identical(other.testValue, testValue) || other.testValue == testValue)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,isAwesomeFeatureEnabled,testValue,dataSource,lastSyncedAt);

@override
String toString() {
  return 'RemoteConfigDiagnosticsViewData(status: $status, errorMessage: $errorMessage, isAwesomeFeatureEnabled: $isAwesomeFeatureEnabled, testValue: $testValue, dataSource: $dataSource, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$RemoteConfigDiagnosticsViewDataCopyWith<$Res> implements $RemoteConfigDiagnosticsViewDataCopyWith<$Res> {
  factory _$RemoteConfigDiagnosticsViewDataCopyWith(_RemoteConfigDiagnosticsViewData value, $Res Function(_RemoteConfigDiagnosticsViewData) _then) = __$RemoteConfigDiagnosticsViewDataCopyWithImpl;
@override @useResult
$Res call({
 RemoteConfigDiagnosticsStatus status, String? errorMessage, bool isAwesomeFeatureEnabled, String? testValue, String? dataSource, DateTime? lastSyncedAt
});




}
/// @nodoc
class __$RemoteConfigDiagnosticsViewDataCopyWithImpl<$Res>
    implements _$RemoteConfigDiagnosticsViewDataCopyWith<$Res> {
  __$RemoteConfigDiagnosticsViewDataCopyWithImpl(this._self, this._then);

  final _RemoteConfigDiagnosticsViewData _self;
  final $Res Function(_RemoteConfigDiagnosticsViewData) _then;

/// Create a copy of RemoteConfigDiagnosticsViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? isAwesomeFeatureEnabled = null,Object? testValue = freezed,Object? dataSource = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_RemoteConfigDiagnosticsViewData(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RemoteConfigDiagnosticsStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isAwesomeFeatureEnabled: null == isAwesomeFeatureEnabled ? _self.isAwesomeFeatureEnabled : isAwesomeFeatureEnabled // ignore: cast_nullable_to_non_nullable
as bool,testValue: freezed == testValue ? _self.testValue : testValue // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
