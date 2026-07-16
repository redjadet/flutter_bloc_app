// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_security_showcase_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NativeSecurityShowcaseState {

 CertificatePinPolicySummary get certificateSummary; NativeSecurityOperation? get inFlight; bool get appCheckInFlight; NativeSecurityOperationResult? get p256Result; NativeSecurityOperationResult? get aesResult; NativeSecurityOperationResult? get storageResult; NativeSecurityOperationResult? get biometricResult; AppCheckAttestationResult? get appCheckResult;
/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeSecurityShowcaseStateCopyWith<NativeSecurityShowcaseState> get copyWith => _$NativeSecurityShowcaseStateCopyWithImpl<NativeSecurityShowcaseState>(this as NativeSecurityShowcaseState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeSecurityShowcaseState&&(identical(other.certificateSummary, certificateSummary) || other.certificateSummary == certificateSummary)&&(identical(other.inFlight, inFlight) || other.inFlight == inFlight)&&(identical(other.appCheckInFlight, appCheckInFlight) || other.appCheckInFlight == appCheckInFlight)&&(identical(other.p256Result, p256Result) || other.p256Result == p256Result)&&(identical(other.aesResult, aesResult) || other.aesResult == aesResult)&&(identical(other.storageResult, storageResult) || other.storageResult == storageResult)&&(identical(other.biometricResult, biometricResult) || other.biometricResult == biometricResult)&&(identical(other.appCheckResult, appCheckResult) || other.appCheckResult == appCheckResult));
}


@override
int get hashCode => Object.hash(runtimeType,certificateSummary,inFlight,appCheckInFlight,p256Result,aesResult,storageResult,biometricResult,appCheckResult);

@override
String toString() {
  return 'NativeSecurityShowcaseState(certificateSummary: $certificateSummary, inFlight: $inFlight, appCheckInFlight: $appCheckInFlight, p256Result: $p256Result, aesResult: $aesResult, storageResult: $storageResult, biometricResult: $biometricResult, appCheckResult: $appCheckResult)';
}


}

/// @nodoc
abstract mixin class $NativeSecurityShowcaseStateCopyWith<$Res>  {
  factory $NativeSecurityShowcaseStateCopyWith(NativeSecurityShowcaseState value, $Res Function(NativeSecurityShowcaseState) _then) = _$NativeSecurityShowcaseStateCopyWithImpl;
@useResult
$Res call({
 CertificatePinPolicySummary certificateSummary, NativeSecurityOperation? inFlight, bool appCheckInFlight, NativeSecurityOperationResult? p256Result, NativeSecurityOperationResult? aesResult, NativeSecurityOperationResult? storageResult, NativeSecurityOperationResult? biometricResult, AppCheckAttestationResult? appCheckResult
});


$CertificatePinPolicySummaryCopyWith<$Res> get certificateSummary;$NativeSecurityOperationResultCopyWith<$Res>? get p256Result;$NativeSecurityOperationResultCopyWith<$Res>? get aesResult;$NativeSecurityOperationResultCopyWith<$Res>? get storageResult;$NativeSecurityOperationResultCopyWith<$Res>? get biometricResult;$AppCheckAttestationResultCopyWith<$Res>? get appCheckResult;

}
/// @nodoc
class _$NativeSecurityShowcaseStateCopyWithImpl<$Res>
    implements $NativeSecurityShowcaseStateCopyWith<$Res> {
  _$NativeSecurityShowcaseStateCopyWithImpl(this._self, this._then);

  final NativeSecurityShowcaseState _self;
  final $Res Function(NativeSecurityShowcaseState) _then;

/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? certificateSummary = null,Object? inFlight = freezed,Object? appCheckInFlight = null,Object? p256Result = freezed,Object? aesResult = freezed,Object? storageResult = freezed,Object? biometricResult = freezed,Object? appCheckResult = freezed,}) {
  return _then(_self.copyWith(
certificateSummary: null == certificateSummary ? _self.certificateSummary : certificateSummary // ignore: cast_nullable_to_non_nullable
as CertificatePinPolicySummary,inFlight: freezed == inFlight ? _self.inFlight : inFlight // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperation?,appCheckInFlight: null == appCheckInFlight ? _self.appCheckInFlight : appCheckInFlight // ignore: cast_nullable_to_non_nullable
as bool,p256Result: freezed == p256Result ? _self.p256Result : p256Result // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,aesResult: freezed == aesResult ? _self.aesResult : aesResult // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,storageResult: freezed == storageResult ? _self.storageResult : storageResult // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,biometricResult: freezed == biometricResult ? _self.biometricResult : biometricResult // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,appCheckResult: freezed == appCheckResult ? _self.appCheckResult : appCheckResult // ignore: cast_nullable_to_non_nullable
as AppCheckAttestationResult?,
  ));
}
/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CertificatePinPolicySummaryCopyWith<$Res> get certificateSummary {
  
  return $CertificatePinPolicySummaryCopyWith<$Res>(_self.certificateSummary, (value) {
    return _then(_self.copyWith(certificateSummary: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get p256Result {
    if (_self.p256Result == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.p256Result!, (value) {
    return _then(_self.copyWith(p256Result: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get aesResult {
    if (_self.aesResult == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.aesResult!, (value) {
    return _then(_self.copyWith(aesResult: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get storageResult {
    if (_self.storageResult == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.storageResult!, (value) {
    return _then(_self.copyWith(storageResult: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get biometricResult {
    if (_self.biometricResult == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.biometricResult!, (value) {
    return _then(_self.copyWith(biometricResult: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppCheckAttestationResultCopyWith<$Res>? get appCheckResult {
    if (_self.appCheckResult == null) {
    return null;
  }

  return $AppCheckAttestationResultCopyWith<$Res>(_self.appCheckResult!, (value) {
    return _then(_self.copyWith(appCheckResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [NativeSecurityShowcaseState].
extension NativeSecurityShowcaseStatePatterns on NativeSecurityShowcaseState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeSecurityShowcaseState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NativeSecurityShowcaseState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeSecurityShowcaseState value)  $default,){
final _that = this;
switch (_that) {
case _NativeSecurityShowcaseState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeSecurityShowcaseState value)?  $default,){
final _that = this;
switch (_that) {
case _NativeSecurityShowcaseState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CertificatePinPolicySummary certificateSummary,  NativeSecurityOperation? inFlight,  bool appCheckInFlight,  NativeSecurityOperationResult? p256Result,  NativeSecurityOperationResult? aesResult,  NativeSecurityOperationResult? storageResult,  NativeSecurityOperationResult? biometricResult,  AppCheckAttestationResult? appCheckResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeSecurityShowcaseState() when $default != null:
return $default(_that.certificateSummary,_that.inFlight,_that.appCheckInFlight,_that.p256Result,_that.aesResult,_that.storageResult,_that.biometricResult,_that.appCheckResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CertificatePinPolicySummary certificateSummary,  NativeSecurityOperation? inFlight,  bool appCheckInFlight,  NativeSecurityOperationResult? p256Result,  NativeSecurityOperationResult? aesResult,  NativeSecurityOperationResult? storageResult,  NativeSecurityOperationResult? biometricResult,  AppCheckAttestationResult? appCheckResult)  $default,) {final _that = this;
switch (_that) {
case _NativeSecurityShowcaseState():
return $default(_that.certificateSummary,_that.inFlight,_that.appCheckInFlight,_that.p256Result,_that.aesResult,_that.storageResult,_that.biometricResult,_that.appCheckResult);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CertificatePinPolicySummary certificateSummary,  NativeSecurityOperation? inFlight,  bool appCheckInFlight,  NativeSecurityOperationResult? p256Result,  NativeSecurityOperationResult? aesResult,  NativeSecurityOperationResult? storageResult,  NativeSecurityOperationResult? biometricResult,  AppCheckAttestationResult? appCheckResult)?  $default,) {final _that = this;
switch (_that) {
case _NativeSecurityShowcaseState() when $default != null:
return $default(_that.certificateSummary,_that.inFlight,_that.appCheckInFlight,_that.p256Result,_that.aesResult,_that.storageResult,_that.biometricResult,_that.appCheckResult);case _:
  return null;

}
}

}

/// @nodoc


class _NativeSecurityShowcaseState extends NativeSecurityShowcaseState {
  const _NativeSecurityShowcaseState({required this.certificateSummary, this.inFlight, this.appCheckInFlight = false, this.p256Result, this.aesResult, this.storageResult, this.biometricResult, this.appCheckResult}): super._();
  

@override final  CertificatePinPolicySummary certificateSummary;
@override final  NativeSecurityOperation? inFlight;
@override@JsonKey() final  bool appCheckInFlight;
@override final  NativeSecurityOperationResult? p256Result;
@override final  NativeSecurityOperationResult? aesResult;
@override final  NativeSecurityOperationResult? storageResult;
@override final  NativeSecurityOperationResult? biometricResult;
@override final  AppCheckAttestationResult? appCheckResult;

/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeSecurityShowcaseStateCopyWith<_NativeSecurityShowcaseState> get copyWith => __$NativeSecurityShowcaseStateCopyWithImpl<_NativeSecurityShowcaseState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeSecurityShowcaseState&&(identical(other.certificateSummary, certificateSummary) || other.certificateSummary == certificateSummary)&&(identical(other.inFlight, inFlight) || other.inFlight == inFlight)&&(identical(other.appCheckInFlight, appCheckInFlight) || other.appCheckInFlight == appCheckInFlight)&&(identical(other.p256Result, p256Result) || other.p256Result == p256Result)&&(identical(other.aesResult, aesResult) || other.aesResult == aesResult)&&(identical(other.storageResult, storageResult) || other.storageResult == storageResult)&&(identical(other.biometricResult, biometricResult) || other.biometricResult == biometricResult)&&(identical(other.appCheckResult, appCheckResult) || other.appCheckResult == appCheckResult));
}


@override
int get hashCode => Object.hash(runtimeType,certificateSummary,inFlight,appCheckInFlight,p256Result,aesResult,storageResult,biometricResult,appCheckResult);

@override
String toString() {
  return 'NativeSecurityShowcaseState(certificateSummary: $certificateSummary, inFlight: $inFlight, appCheckInFlight: $appCheckInFlight, p256Result: $p256Result, aesResult: $aesResult, storageResult: $storageResult, biometricResult: $biometricResult, appCheckResult: $appCheckResult)';
}


}

/// @nodoc
abstract mixin class _$NativeSecurityShowcaseStateCopyWith<$Res> implements $NativeSecurityShowcaseStateCopyWith<$Res> {
  factory _$NativeSecurityShowcaseStateCopyWith(_NativeSecurityShowcaseState value, $Res Function(_NativeSecurityShowcaseState) _then) = __$NativeSecurityShowcaseStateCopyWithImpl;
@override @useResult
$Res call({
 CertificatePinPolicySummary certificateSummary, NativeSecurityOperation? inFlight, bool appCheckInFlight, NativeSecurityOperationResult? p256Result, NativeSecurityOperationResult? aesResult, NativeSecurityOperationResult? storageResult, NativeSecurityOperationResult? biometricResult, AppCheckAttestationResult? appCheckResult
});


@override $CertificatePinPolicySummaryCopyWith<$Res> get certificateSummary;@override $NativeSecurityOperationResultCopyWith<$Res>? get p256Result;@override $NativeSecurityOperationResultCopyWith<$Res>? get aesResult;@override $NativeSecurityOperationResultCopyWith<$Res>? get storageResult;@override $NativeSecurityOperationResultCopyWith<$Res>? get biometricResult;@override $AppCheckAttestationResultCopyWith<$Res>? get appCheckResult;

}
/// @nodoc
class __$NativeSecurityShowcaseStateCopyWithImpl<$Res>
    implements _$NativeSecurityShowcaseStateCopyWith<$Res> {
  __$NativeSecurityShowcaseStateCopyWithImpl(this._self, this._then);

  final _NativeSecurityShowcaseState _self;
  final $Res Function(_NativeSecurityShowcaseState) _then;

/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? certificateSummary = null,Object? inFlight = freezed,Object? appCheckInFlight = null,Object? p256Result = freezed,Object? aesResult = freezed,Object? storageResult = freezed,Object? biometricResult = freezed,Object? appCheckResult = freezed,}) {
  return _then(_NativeSecurityShowcaseState(
certificateSummary: null == certificateSummary ? _self.certificateSummary : certificateSummary // ignore: cast_nullable_to_non_nullable
as CertificatePinPolicySummary,inFlight: freezed == inFlight ? _self.inFlight : inFlight // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperation?,appCheckInFlight: null == appCheckInFlight ? _self.appCheckInFlight : appCheckInFlight // ignore: cast_nullable_to_non_nullable
as bool,p256Result: freezed == p256Result ? _self.p256Result : p256Result // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,aesResult: freezed == aesResult ? _self.aesResult : aesResult // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,storageResult: freezed == storageResult ? _self.storageResult : storageResult // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,biometricResult: freezed == biometricResult ? _self.biometricResult : biometricResult // ignore: cast_nullable_to_non_nullable
as NativeSecurityOperationResult?,appCheckResult: freezed == appCheckResult ? _self.appCheckResult : appCheckResult // ignore: cast_nullable_to_non_nullable
as AppCheckAttestationResult?,
  ));
}

/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CertificatePinPolicySummaryCopyWith<$Res> get certificateSummary {
  
  return $CertificatePinPolicySummaryCopyWith<$Res>(_self.certificateSummary, (value) {
    return _then(_self.copyWith(certificateSummary: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get p256Result {
    if (_self.p256Result == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.p256Result!, (value) {
    return _then(_self.copyWith(p256Result: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get aesResult {
    if (_self.aesResult == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.aesResult!, (value) {
    return _then(_self.copyWith(aesResult: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get storageResult {
    if (_self.storageResult == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.storageResult!, (value) {
    return _then(_self.copyWith(storageResult: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<$Res>? get biometricResult {
    if (_self.biometricResult == null) {
    return null;
  }

  return $NativeSecurityOperationResultCopyWith<$Res>(_self.biometricResult!, (value) {
    return _then(_self.copyWith(biometricResult: value));
  });
}/// Create a copy of NativeSecurityShowcaseState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppCheckAttestationResultCopyWith<$Res>? get appCheckResult {
    if (_self.appCheckResult == null) {
    return null;
  }

  return $AppCheckAttestationResultCopyWith<$Res>(_self.appCheckResult!, (value) {
    return _then(_self.copyWith(appCheckResult: value));
  });
}
}

// dart format on
