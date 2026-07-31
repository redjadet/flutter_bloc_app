// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production_readiness_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductionReadinessState {

 ProductionReadinessStatus get status; ProductionReadinessMode get mode; bool get analyticsConsentEnabled; int get localEventCount; bool get releaseFlagEnabled; String get releaseVariant; String get configSource; bool get crashlyticsAvailable; FcmDemoMode get fcmMode; FcmPermissionState? get fcmPermission; int get fcmDataKeyCount; bool get fcmHasTitle; bool get fcmHasBody; String? get fcmLastSource; int get frameSampleCount; double get frameP90Ms; double get frameP99Ms; int get framesMissedOver16_7Ms; String? get errorMessage;
/// Create a copy of ProductionReadinessState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductionReadinessStateCopyWith<ProductionReadinessState> get copyWith => _$ProductionReadinessStateCopyWithImpl<ProductionReadinessState>(this as ProductionReadinessState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductionReadinessState&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.analyticsConsentEnabled, analyticsConsentEnabled) || other.analyticsConsentEnabled == analyticsConsentEnabled)&&(identical(other.localEventCount, localEventCount) || other.localEventCount == localEventCount)&&(identical(other.releaseFlagEnabled, releaseFlagEnabled) || other.releaseFlagEnabled == releaseFlagEnabled)&&(identical(other.releaseVariant, releaseVariant) || other.releaseVariant == releaseVariant)&&(identical(other.configSource, configSource) || other.configSource == configSource)&&(identical(other.crashlyticsAvailable, crashlyticsAvailable) || other.crashlyticsAvailable == crashlyticsAvailable)&&(identical(other.fcmMode, fcmMode) || other.fcmMode == fcmMode)&&(identical(other.fcmPermission, fcmPermission) || other.fcmPermission == fcmPermission)&&(identical(other.fcmDataKeyCount, fcmDataKeyCount) || other.fcmDataKeyCount == fcmDataKeyCount)&&(identical(other.fcmHasTitle, fcmHasTitle) || other.fcmHasTitle == fcmHasTitle)&&(identical(other.fcmHasBody, fcmHasBody) || other.fcmHasBody == fcmHasBody)&&(identical(other.fcmLastSource, fcmLastSource) || other.fcmLastSource == fcmLastSource)&&(identical(other.frameSampleCount, frameSampleCount) || other.frameSampleCount == frameSampleCount)&&(identical(other.frameP90Ms, frameP90Ms) || other.frameP90Ms == frameP90Ms)&&(identical(other.frameP99Ms, frameP99Ms) || other.frameP99Ms == frameP99Ms)&&(identical(other.framesMissedOver16_7Ms, framesMissedOver16_7Ms) || other.framesMissedOver16_7Ms == framesMissedOver16_7Ms)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,mode,analyticsConsentEnabled,localEventCount,releaseFlagEnabled,releaseVariant,configSource,crashlyticsAvailable,fcmMode,fcmPermission,fcmDataKeyCount,fcmHasTitle,fcmHasBody,fcmLastSource,frameSampleCount,frameP90Ms,frameP99Ms,framesMissedOver16_7Ms,errorMessage]);

@override
String toString() {
  return 'ProductionReadinessState(status: $status, mode: $mode, analyticsConsentEnabled: $analyticsConsentEnabled, localEventCount: $localEventCount, releaseFlagEnabled: $releaseFlagEnabled, releaseVariant: $releaseVariant, configSource: $configSource, crashlyticsAvailable: $crashlyticsAvailable, fcmMode: $fcmMode, fcmPermission: $fcmPermission, fcmDataKeyCount: $fcmDataKeyCount, fcmHasTitle: $fcmHasTitle, fcmHasBody: $fcmHasBody, fcmLastSource: $fcmLastSource, frameSampleCount: $frameSampleCount, frameP90Ms: $frameP90Ms, frameP99Ms: $frameP99Ms, framesMissedOver16_7Ms: $framesMissedOver16_7Ms, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProductionReadinessStateCopyWith<$Res>  {
  factory $ProductionReadinessStateCopyWith(ProductionReadinessState value, $Res Function(ProductionReadinessState) _then) = _$ProductionReadinessStateCopyWithImpl;
@useResult
$Res call({
 ProductionReadinessStatus status, ProductionReadinessMode mode, bool analyticsConsentEnabled, int localEventCount, bool releaseFlagEnabled, String releaseVariant, String configSource, bool crashlyticsAvailable, FcmDemoMode fcmMode, FcmPermissionState? fcmPermission, int fcmDataKeyCount, bool fcmHasTitle, bool fcmHasBody, String? fcmLastSource, int frameSampleCount, double frameP90Ms, double frameP99Ms, int framesMissedOver16_7Ms, String? errorMessage
});




}
/// @nodoc
class _$ProductionReadinessStateCopyWithImpl<$Res>
    implements $ProductionReadinessStateCopyWith<$Res> {
  _$ProductionReadinessStateCopyWithImpl(this._self, this._then);

  final ProductionReadinessState _self;
  final $Res Function(ProductionReadinessState) _then;

/// Create a copy of ProductionReadinessState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? mode = null,Object? analyticsConsentEnabled = null,Object? localEventCount = null,Object? releaseFlagEnabled = null,Object? releaseVariant = null,Object? configSource = null,Object? crashlyticsAvailable = null,Object? fcmMode = null,Object? fcmPermission = freezed,Object? fcmDataKeyCount = null,Object? fcmHasTitle = null,Object? fcmHasBody = null,Object? fcmLastSource = freezed,Object? frameSampleCount = null,Object? frameP90Ms = null,Object? frameP99Ms = null,Object? framesMissedOver16_7Ms = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductionReadinessStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ProductionReadinessMode,analyticsConsentEnabled: null == analyticsConsentEnabled ? _self.analyticsConsentEnabled : analyticsConsentEnabled // ignore: cast_nullable_to_non_nullable
as bool,localEventCount: null == localEventCount ? _self.localEventCount : localEventCount // ignore: cast_nullable_to_non_nullable
as int,releaseFlagEnabled: null == releaseFlagEnabled ? _self.releaseFlagEnabled : releaseFlagEnabled // ignore: cast_nullable_to_non_nullable
as bool,releaseVariant: null == releaseVariant ? _self.releaseVariant : releaseVariant // ignore: cast_nullable_to_non_nullable
as String,configSource: null == configSource ? _self.configSource : configSource // ignore: cast_nullable_to_non_nullable
as String,crashlyticsAvailable: null == crashlyticsAvailable ? _self.crashlyticsAvailable : crashlyticsAvailable // ignore: cast_nullable_to_non_nullable
as bool,fcmMode: null == fcmMode ? _self.fcmMode : fcmMode // ignore: cast_nullable_to_non_nullable
as FcmDemoMode,fcmPermission: freezed == fcmPermission ? _self.fcmPermission : fcmPermission // ignore: cast_nullable_to_non_nullable
as FcmPermissionState?,fcmDataKeyCount: null == fcmDataKeyCount ? _self.fcmDataKeyCount : fcmDataKeyCount // ignore: cast_nullable_to_non_nullable
as int,fcmHasTitle: null == fcmHasTitle ? _self.fcmHasTitle : fcmHasTitle // ignore: cast_nullable_to_non_nullable
as bool,fcmHasBody: null == fcmHasBody ? _self.fcmHasBody : fcmHasBody // ignore: cast_nullable_to_non_nullable
as bool,fcmLastSource: freezed == fcmLastSource ? _self.fcmLastSource : fcmLastSource // ignore: cast_nullable_to_non_nullable
as String?,frameSampleCount: null == frameSampleCount ? _self.frameSampleCount : frameSampleCount // ignore: cast_nullable_to_non_nullable
as int,frameP90Ms: null == frameP90Ms ? _self.frameP90Ms : frameP90Ms // ignore: cast_nullable_to_non_nullable
as double,frameP99Ms: null == frameP99Ms ? _self.frameP99Ms : frameP99Ms // ignore: cast_nullable_to_non_nullable
as double,framesMissedOver16_7Ms: null == framesMissedOver16_7Ms ? _self.framesMissedOver16_7Ms : framesMissedOver16_7Ms // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductionReadinessState].
extension ProductionReadinessStatePatterns on ProductionReadinessState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductionReadinessState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductionReadinessState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductionReadinessState value)  $default,){
final _that = this;
switch (_that) {
case _ProductionReadinessState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductionReadinessState value)?  $default,){
final _that = this;
switch (_that) {
case _ProductionReadinessState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductionReadinessStatus status,  ProductionReadinessMode mode,  bool analyticsConsentEnabled,  int localEventCount,  bool releaseFlagEnabled,  String releaseVariant,  String configSource,  bool crashlyticsAvailable,  FcmDemoMode fcmMode,  FcmPermissionState? fcmPermission,  int fcmDataKeyCount,  bool fcmHasTitle,  bool fcmHasBody,  String? fcmLastSource,  int frameSampleCount,  double frameP90Ms,  double frameP99Ms,  int framesMissedOver16_7Ms,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductionReadinessState() when $default != null:
return $default(_that.status,_that.mode,_that.analyticsConsentEnabled,_that.localEventCount,_that.releaseFlagEnabled,_that.releaseVariant,_that.configSource,_that.crashlyticsAvailable,_that.fcmMode,_that.fcmPermission,_that.fcmDataKeyCount,_that.fcmHasTitle,_that.fcmHasBody,_that.fcmLastSource,_that.frameSampleCount,_that.frameP90Ms,_that.frameP99Ms,_that.framesMissedOver16_7Ms,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductionReadinessStatus status,  ProductionReadinessMode mode,  bool analyticsConsentEnabled,  int localEventCount,  bool releaseFlagEnabled,  String releaseVariant,  String configSource,  bool crashlyticsAvailable,  FcmDemoMode fcmMode,  FcmPermissionState? fcmPermission,  int fcmDataKeyCount,  bool fcmHasTitle,  bool fcmHasBody,  String? fcmLastSource,  int frameSampleCount,  double frameP90Ms,  double frameP99Ms,  int framesMissedOver16_7Ms,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ProductionReadinessState():
return $default(_that.status,_that.mode,_that.analyticsConsentEnabled,_that.localEventCount,_that.releaseFlagEnabled,_that.releaseVariant,_that.configSource,_that.crashlyticsAvailable,_that.fcmMode,_that.fcmPermission,_that.fcmDataKeyCount,_that.fcmHasTitle,_that.fcmHasBody,_that.fcmLastSource,_that.frameSampleCount,_that.frameP90Ms,_that.frameP99Ms,_that.framesMissedOver16_7Ms,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductionReadinessStatus status,  ProductionReadinessMode mode,  bool analyticsConsentEnabled,  int localEventCount,  bool releaseFlagEnabled,  String releaseVariant,  String configSource,  bool crashlyticsAvailable,  FcmDemoMode fcmMode,  FcmPermissionState? fcmPermission,  int fcmDataKeyCount,  bool fcmHasTitle,  bool fcmHasBody,  String? fcmLastSource,  int frameSampleCount,  double frameP90Ms,  double frameP99Ms,  int framesMissedOver16_7Ms,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ProductionReadinessState() when $default != null:
return $default(_that.status,_that.mode,_that.analyticsConsentEnabled,_that.localEventCount,_that.releaseFlagEnabled,_that.releaseVariant,_that.configSource,_that.crashlyticsAvailable,_that.fcmMode,_that.fcmPermission,_that.fcmDataKeyCount,_that.fcmHasTitle,_that.fcmHasBody,_that.fcmLastSource,_that.frameSampleCount,_that.frameP90Ms,_that.frameP99Ms,_that.framesMissedOver16_7Ms,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ProductionReadinessState implements ProductionReadinessState {
  const _ProductionReadinessState({this.status = ProductionReadinessStatus.initial, this.mode = ProductionReadinessMode.simulated, this.analyticsConsentEnabled = false, this.localEventCount = 0, this.releaseFlagEnabled = true, this.releaseVariant = 'control', this.configSource = 'defaults', this.crashlyticsAvailable = false, this.fcmMode = FcmDemoMode.simulated, this.fcmPermission, this.fcmDataKeyCount = 0, this.fcmHasTitle = false, this.fcmHasBody = false, this.fcmLastSource, this.frameSampleCount = 0, this.frameP90Ms = 0, this.frameP99Ms = 0, this.framesMissedOver16_7Ms = 0, this.errorMessage});


@override@JsonKey() final  ProductionReadinessStatus status;
@override@JsonKey() final  ProductionReadinessMode mode;
@override@JsonKey() final  bool analyticsConsentEnabled;
@override@JsonKey() final  int localEventCount;
@override@JsonKey() final  bool releaseFlagEnabled;
@override@JsonKey() final  String releaseVariant;
@override@JsonKey() final  String configSource;
@override@JsonKey() final  bool crashlyticsAvailable;
@override@JsonKey() final  FcmDemoMode fcmMode;
@override final  FcmPermissionState? fcmPermission;
@override@JsonKey() final  int fcmDataKeyCount;
@override@JsonKey() final  bool fcmHasTitle;
@override@JsonKey() final  bool fcmHasBody;
@override final  String? fcmLastSource;
@override@JsonKey() final  int frameSampleCount;
@override@JsonKey() final  double frameP90Ms;
@override@JsonKey() final  double frameP99Ms;
@override@JsonKey() final  int framesMissedOver16_7Ms;
@override final  String? errorMessage;

/// Create a copy of ProductionReadinessState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductionReadinessStateCopyWith<_ProductionReadinessState> get copyWith => __$ProductionReadinessStateCopyWithImpl<_ProductionReadinessState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductionReadinessState&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.analyticsConsentEnabled, analyticsConsentEnabled) || other.analyticsConsentEnabled == analyticsConsentEnabled)&&(identical(other.localEventCount, localEventCount) || other.localEventCount == localEventCount)&&(identical(other.releaseFlagEnabled, releaseFlagEnabled) || other.releaseFlagEnabled == releaseFlagEnabled)&&(identical(other.releaseVariant, releaseVariant) || other.releaseVariant == releaseVariant)&&(identical(other.configSource, configSource) || other.configSource == configSource)&&(identical(other.crashlyticsAvailable, crashlyticsAvailable) || other.crashlyticsAvailable == crashlyticsAvailable)&&(identical(other.fcmMode, fcmMode) || other.fcmMode == fcmMode)&&(identical(other.fcmPermission, fcmPermission) || other.fcmPermission == fcmPermission)&&(identical(other.fcmDataKeyCount, fcmDataKeyCount) || other.fcmDataKeyCount == fcmDataKeyCount)&&(identical(other.fcmHasTitle, fcmHasTitle) || other.fcmHasTitle == fcmHasTitle)&&(identical(other.fcmHasBody, fcmHasBody) || other.fcmHasBody == fcmHasBody)&&(identical(other.fcmLastSource, fcmLastSource) || other.fcmLastSource == fcmLastSource)&&(identical(other.frameSampleCount, frameSampleCount) || other.frameSampleCount == frameSampleCount)&&(identical(other.frameP90Ms, frameP90Ms) || other.frameP90Ms == frameP90Ms)&&(identical(other.frameP99Ms, frameP99Ms) || other.frameP99Ms == frameP99Ms)&&(identical(other.framesMissedOver16_7Ms, framesMissedOver16_7Ms) || other.framesMissedOver16_7Ms == framesMissedOver16_7Ms)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,status,mode,analyticsConsentEnabled,localEventCount,releaseFlagEnabled,releaseVariant,configSource,crashlyticsAvailable,fcmMode,fcmPermission,fcmDataKeyCount,fcmHasTitle,fcmHasBody,fcmLastSource,frameSampleCount,frameP90Ms,frameP99Ms,framesMissedOver16_7Ms,errorMessage]);

@override
String toString() {
  return 'ProductionReadinessState(status: $status, mode: $mode, analyticsConsentEnabled: $analyticsConsentEnabled, localEventCount: $localEventCount, releaseFlagEnabled: $releaseFlagEnabled, releaseVariant: $releaseVariant, configSource: $configSource, crashlyticsAvailable: $crashlyticsAvailable, fcmMode: $fcmMode, fcmPermission: $fcmPermission, fcmDataKeyCount: $fcmDataKeyCount, fcmHasTitle: $fcmHasTitle, fcmHasBody: $fcmHasBody, fcmLastSource: $fcmLastSource, frameSampleCount: $frameSampleCount, frameP90Ms: $frameP90Ms, frameP99Ms: $frameP99Ms, framesMissedOver16_7Ms: $framesMissedOver16_7Ms, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ProductionReadinessStateCopyWith<$Res> implements $ProductionReadinessStateCopyWith<$Res> {
  factory _$ProductionReadinessStateCopyWith(_ProductionReadinessState value, $Res Function(_ProductionReadinessState) _then) = __$ProductionReadinessStateCopyWithImpl;
@override @useResult
$Res call({
 ProductionReadinessStatus status, ProductionReadinessMode mode, bool analyticsConsentEnabled, int localEventCount, bool releaseFlagEnabled, String releaseVariant, String configSource, bool crashlyticsAvailable, FcmDemoMode fcmMode, FcmPermissionState? fcmPermission, int fcmDataKeyCount, bool fcmHasTitle, bool fcmHasBody, String? fcmLastSource, int frameSampleCount, double frameP90Ms, double frameP99Ms, int framesMissedOver16_7Ms, String? errorMessage
});




}
/// @nodoc
class __$ProductionReadinessStateCopyWithImpl<$Res>
    implements _$ProductionReadinessStateCopyWith<$Res> {
  __$ProductionReadinessStateCopyWithImpl(this._self, this._then);

  final _ProductionReadinessState _self;
  final $Res Function(_ProductionReadinessState) _then;

/// Create a copy of ProductionReadinessState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? mode = null,Object? analyticsConsentEnabled = null,Object? localEventCount = null,Object? releaseFlagEnabled = null,Object? releaseVariant = null,Object? configSource = null,Object? crashlyticsAvailable = null,Object? fcmMode = null,Object? fcmPermission = freezed,Object? fcmDataKeyCount = null,Object? fcmHasTitle = null,Object? fcmHasBody = null,Object? fcmLastSource = freezed,Object? frameSampleCount = null,Object? frameP90Ms = null,Object? frameP99Ms = null,Object? framesMissedOver16_7Ms = null,Object? errorMessage = freezed,}) {
  return _then(_ProductionReadinessState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProductionReadinessStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ProductionReadinessMode,analyticsConsentEnabled: null == analyticsConsentEnabled ? _self.analyticsConsentEnabled : analyticsConsentEnabled // ignore: cast_nullable_to_non_nullable
as bool,localEventCount: null == localEventCount ? _self.localEventCount : localEventCount // ignore: cast_nullable_to_non_nullable
as int,releaseFlagEnabled: null == releaseFlagEnabled ? _self.releaseFlagEnabled : releaseFlagEnabled // ignore: cast_nullable_to_non_nullable
as bool,releaseVariant: null == releaseVariant ? _self.releaseVariant : releaseVariant // ignore: cast_nullable_to_non_nullable
as String,configSource: null == configSource ? _self.configSource : configSource // ignore: cast_nullable_to_non_nullable
as String,crashlyticsAvailable: null == crashlyticsAvailable ? _self.crashlyticsAvailable : crashlyticsAvailable // ignore: cast_nullable_to_non_nullable
as bool,fcmMode: null == fcmMode ? _self.fcmMode : fcmMode // ignore: cast_nullable_to_non_nullable
as FcmDemoMode,fcmPermission: freezed == fcmPermission ? _self.fcmPermission : fcmPermission // ignore: cast_nullable_to_non_nullable
as FcmPermissionState?,fcmDataKeyCount: null == fcmDataKeyCount ? _self.fcmDataKeyCount : fcmDataKeyCount // ignore: cast_nullable_to_non_nullable
as int,fcmHasTitle: null == fcmHasTitle ? _self.fcmHasTitle : fcmHasTitle // ignore: cast_nullable_to_non_nullable
as bool,fcmHasBody: null == fcmHasBody ? _self.fcmHasBody : fcmHasBody // ignore: cast_nullable_to_non_nullable
as bool,fcmLastSource: freezed == fcmLastSource ? _self.fcmLastSource : fcmLastSource // ignore: cast_nullable_to_non_nullable
as String?,frameSampleCount: null == frameSampleCount ? _self.frameSampleCount : frameSampleCount // ignore: cast_nullable_to_non_nullable
as int,frameP90Ms: null == frameP90Ms ? _self.frameP90Ms : frameP90Ms // ignore: cast_nullable_to_non_nullable
as double,frameP99Ms: null == frameP99Ms ? _self.frameP99Ms : frameP99Ms // ignore: cast_nullable_to_non_nullable
as double,framesMissedOver16_7Ms: null == framesMissedOver16_7Ms ? _self.framesMissedOver16_7Ms : framesMissedOver16_7Ms // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
