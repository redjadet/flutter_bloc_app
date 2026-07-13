// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'certificate_pinning_demo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CertificatePinningDemoState {

 CertificatePinningMode get mode; MockCertificateScenario get scenario; CertificatePinningDemoStatus get status; CertificatePinMatchKind? get matchKind; CertificatePinningDemoFailure? get failure; List<String> get logLines;
/// Create a copy of CertificatePinningDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CertificatePinningDemoStateCopyWith<CertificatePinningDemoState> get copyWith => _$CertificatePinningDemoStateCopyWithImpl<CertificatePinningDemoState>(this as CertificatePinningDemoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CertificatePinningDemoState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&(identical(other.status, status) || other.status == status)&&(identical(other.matchKind, matchKind) || other.matchKind == matchKind)&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other.logLines, logLines));
}


@override
int get hashCode => Object.hash(runtimeType,mode,scenario,status,matchKind,failure,const DeepCollectionEquality().hash(logLines));

@override
String toString() {
  return 'CertificatePinningDemoState(mode: $mode, scenario: $scenario, status: $status, matchKind: $matchKind, failure: $failure, logLines: $logLines)';
}


}

/// @nodoc
abstract mixin class $CertificatePinningDemoStateCopyWith<$Res>  {
  factory $CertificatePinningDemoStateCopyWith(CertificatePinningDemoState value, $Res Function(CertificatePinningDemoState) _then) = _$CertificatePinningDemoStateCopyWithImpl;
@useResult
$Res call({
 CertificatePinningMode mode, MockCertificateScenario scenario, CertificatePinningDemoStatus status, CertificatePinMatchKind? matchKind, CertificatePinningDemoFailure? failure, List<String> logLines
});




}
/// @nodoc
class _$CertificatePinningDemoStateCopyWithImpl<$Res>
    implements $CertificatePinningDemoStateCopyWith<$Res> {
  _$CertificatePinningDemoStateCopyWithImpl(this._self, this._then);

  final CertificatePinningDemoState _self;
  final $Res Function(CertificatePinningDemoState) _then;

/// Create a copy of CertificatePinningDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? scenario = null,Object? status = null,Object? matchKind = freezed,Object? failure = freezed,Object? logLines = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CertificatePinningMode,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as MockCertificateScenario,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CertificatePinningDemoStatus,matchKind: freezed == matchKind ? _self.matchKind : matchKind // ignore: cast_nullable_to_non_nullable
as CertificatePinMatchKind?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as CertificatePinningDemoFailure?,logLines: null == logLines ? _self.logLines : logLines // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CertificatePinningDemoState].
extension CertificatePinningDemoStatePatterns on CertificatePinningDemoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CertificatePinningDemoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CertificatePinningDemoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CertificatePinningDemoState value)  $default,){
final _that = this;
switch (_that) {
case _CertificatePinningDemoState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CertificatePinningDemoState value)?  $default,){
final _that = this;
switch (_that) {
case _CertificatePinningDemoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CertificatePinningMode mode,  MockCertificateScenario scenario,  CertificatePinningDemoStatus status,  CertificatePinMatchKind? matchKind,  CertificatePinningDemoFailure? failure,  List<String> logLines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CertificatePinningDemoState() when $default != null:
return $default(_that.mode,_that.scenario,_that.status,_that.matchKind,_that.failure,_that.logLines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CertificatePinningMode mode,  MockCertificateScenario scenario,  CertificatePinningDemoStatus status,  CertificatePinMatchKind? matchKind,  CertificatePinningDemoFailure? failure,  List<String> logLines)  $default,) {final _that = this;
switch (_that) {
case _CertificatePinningDemoState():
return $default(_that.mode,_that.scenario,_that.status,_that.matchKind,_that.failure,_that.logLines);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CertificatePinningMode mode,  MockCertificateScenario scenario,  CertificatePinningDemoStatus status,  CertificatePinMatchKind? matchKind,  CertificatePinningDemoFailure? failure,  List<String> logLines)?  $default,) {final _that = this;
switch (_that) {
case _CertificatePinningDemoState() when $default != null:
return $default(_that.mode,_that.scenario,_that.status,_that.matchKind,_that.failure,_that.logLines);case _:
  return null;

}
}

}

/// @nodoc


class _CertificatePinningDemoState implements CertificatePinningDemoState {
  const _CertificatePinningDemoState({required this.mode, required this.scenario, this.status = CertificatePinningDemoStatus.initial, this.matchKind, this.failure, final  List<String> logLines = const <String>[]}): _logLines = logLines;
  

@override final  CertificatePinningMode mode;
@override final  MockCertificateScenario scenario;
@override@JsonKey() final  CertificatePinningDemoStatus status;
@override final  CertificatePinMatchKind? matchKind;
@override final  CertificatePinningDemoFailure? failure;
 final  List<String> _logLines;
@override@JsonKey() List<String> get logLines {
  if (_logLines is EqualUnmodifiableListView) return _logLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logLines);
}


/// Create a copy of CertificatePinningDemoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CertificatePinningDemoStateCopyWith<_CertificatePinningDemoState> get copyWith => __$CertificatePinningDemoStateCopyWithImpl<_CertificatePinningDemoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CertificatePinningDemoState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.scenario, scenario) || other.scenario == scenario)&&(identical(other.status, status) || other.status == status)&&(identical(other.matchKind, matchKind) || other.matchKind == matchKind)&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other._logLines, _logLines));
}


@override
int get hashCode => Object.hash(runtimeType,mode,scenario,status,matchKind,failure,const DeepCollectionEquality().hash(_logLines));

@override
String toString() {
  return 'CertificatePinningDemoState(mode: $mode, scenario: $scenario, status: $status, matchKind: $matchKind, failure: $failure, logLines: $logLines)';
}


}

/// @nodoc
abstract mixin class _$CertificatePinningDemoStateCopyWith<$Res> implements $CertificatePinningDemoStateCopyWith<$Res> {
  factory _$CertificatePinningDemoStateCopyWith(_CertificatePinningDemoState value, $Res Function(_CertificatePinningDemoState) _then) = __$CertificatePinningDemoStateCopyWithImpl;
@override @useResult
$Res call({
 CertificatePinningMode mode, MockCertificateScenario scenario, CertificatePinningDemoStatus status, CertificatePinMatchKind? matchKind, CertificatePinningDemoFailure? failure, List<String> logLines
});




}
/// @nodoc
class __$CertificatePinningDemoStateCopyWithImpl<$Res>
    implements _$CertificatePinningDemoStateCopyWith<$Res> {
  __$CertificatePinningDemoStateCopyWithImpl(this._self, this._then);

  final _CertificatePinningDemoState _self;
  final $Res Function(_CertificatePinningDemoState) _then;

/// Create a copy of CertificatePinningDemoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? scenario = null,Object? status = null,Object? matchKind = freezed,Object? failure = freezed,Object? logLines = null,}) {
  return _then(_CertificatePinningDemoState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CertificatePinningMode,scenario: null == scenario ? _self.scenario : scenario // ignore: cast_nullable_to_non_nullable
as MockCertificateScenario,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CertificatePinningDemoStatus,matchKind: freezed == matchKind ? _self.matchKind : matchKind // ignore: cast_nullable_to_non_nullable
as CertificatePinMatchKind?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as CertificatePinningDemoFailure?,logLines: null == logLines ? _self._logLines : logLines // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
