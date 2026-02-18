// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_cycle_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncCycleSummary {

 DateTime get recordedAt; int get durationMs; int get pullRemoteCount; int get pullRemoteFailures; int get pendingAtStart; int get operationsProcessed; int get operationsFailed; Map<String, int> get pendingByEntity; int get prunedCount; Map<String, double> get retryAttemptsByEntity; Map<String, String> get lastErrorByEntity; double get retrySuccessRate;
/// Create a copy of SyncCycleSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncCycleSummaryCopyWith<SyncCycleSummary> get copyWith => _$SyncCycleSummaryCopyWithImpl<SyncCycleSummary>(this as SyncCycleSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncCycleSummary&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.pullRemoteCount, pullRemoteCount) || other.pullRemoteCount == pullRemoteCount)&&(identical(other.pullRemoteFailures, pullRemoteFailures) || other.pullRemoteFailures == pullRemoteFailures)&&(identical(other.pendingAtStart, pendingAtStart) || other.pendingAtStart == pendingAtStart)&&(identical(other.operationsProcessed, operationsProcessed) || other.operationsProcessed == operationsProcessed)&&(identical(other.operationsFailed, operationsFailed) || other.operationsFailed == operationsFailed)&&const DeepCollectionEquality().equals(other.pendingByEntity, pendingByEntity)&&(identical(other.prunedCount, prunedCount) || other.prunedCount == prunedCount)&&const DeepCollectionEquality().equals(other.retryAttemptsByEntity, retryAttemptsByEntity)&&const DeepCollectionEquality().equals(other.lastErrorByEntity, lastErrorByEntity)&&(identical(other.retrySuccessRate, retrySuccessRate) || other.retrySuccessRate == retrySuccessRate));
}


@override
int get hashCode => Object.hash(runtimeType,recordedAt,durationMs,pullRemoteCount,pullRemoteFailures,pendingAtStart,operationsProcessed,operationsFailed,const DeepCollectionEquality().hash(pendingByEntity),prunedCount,const DeepCollectionEquality().hash(retryAttemptsByEntity),const DeepCollectionEquality().hash(lastErrorByEntity),retrySuccessRate);

@override
String toString() {
  return 'SyncCycleSummary(recordedAt: $recordedAt, durationMs: $durationMs, pullRemoteCount: $pullRemoteCount, pullRemoteFailures: $pullRemoteFailures, pendingAtStart: $pendingAtStart, operationsProcessed: $operationsProcessed, operationsFailed: $operationsFailed, pendingByEntity: $pendingByEntity, prunedCount: $prunedCount, retryAttemptsByEntity: $retryAttemptsByEntity, lastErrorByEntity: $lastErrorByEntity, retrySuccessRate: $retrySuccessRate)';
}


}

/// @nodoc
abstract mixin class $SyncCycleSummaryCopyWith<$Res>  {
  factory $SyncCycleSummaryCopyWith(SyncCycleSummary value, $Res Function(SyncCycleSummary) _then) = _$SyncCycleSummaryCopyWithImpl;
@useResult
$Res call({
 DateTime recordedAt, int durationMs, int pullRemoteCount, int pullRemoteFailures, int pendingAtStart, int operationsProcessed, int operationsFailed, Map<String, int> pendingByEntity, int prunedCount, Map<String, double> retryAttemptsByEntity, Map<String, String> lastErrorByEntity, double retrySuccessRate
});




}
/// @nodoc
class _$SyncCycleSummaryCopyWithImpl<$Res>
    implements $SyncCycleSummaryCopyWith<$Res> {
  _$SyncCycleSummaryCopyWithImpl(this._self, this._then);

  final SyncCycleSummary _self;
  final $Res Function(SyncCycleSummary) _then;

/// Create a copy of SyncCycleSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recordedAt = null,Object? durationMs = null,Object? pullRemoteCount = null,Object? pullRemoteFailures = null,Object? pendingAtStart = null,Object? operationsProcessed = null,Object? operationsFailed = null,Object? pendingByEntity = null,Object? prunedCount = null,Object? retryAttemptsByEntity = null,Object? lastErrorByEntity = null,Object? retrySuccessRate = null,}) {
  return _then(_self.copyWith(
recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,pullRemoteCount: null == pullRemoteCount ? _self.pullRemoteCount : pullRemoteCount // ignore: cast_nullable_to_non_nullable
as int,pullRemoteFailures: null == pullRemoteFailures ? _self.pullRemoteFailures : pullRemoteFailures // ignore: cast_nullable_to_non_nullable
as int,pendingAtStart: null == pendingAtStart ? _self.pendingAtStart : pendingAtStart // ignore: cast_nullable_to_non_nullable
as int,operationsProcessed: null == operationsProcessed ? _self.operationsProcessed : operationsProcessed // ignore: cast_nullable_to_non_nullable
as int,operationsFailed: null == operationsFailed ? _self.operationsFailed : operationsFailed // ignore: cast_nullable_to_non_nullable
as int,pendingByEntity: null == pendingByEntity ? _self.pendingByEntity : pendingByEntity // ignore: cast_nullable_to_non_nullable
as Map<String, int>,prunedCount: null == prunedCount ? _self.prunedCount : prunedCount // ignore: cast_nullable_to_non_nullable
as int,retryAttemptsByEntity: null == retryAttemptsByEntity ? _self.retryAttemptsByEntity : retryAttemptsByEntity // ignore: cast_nullable_to_non_nullable
as Map<String, double>,lastErrorByEntity: null == lastErrorByEntity ? _self.lastErrorByEntity : lastErrorByEntity // ignore: cast_nullable_to_non_nullable
as Map<String, String>,retrySuccessRate: null == retrySuccessRate ? _self.retrySuccessRate : retrySuccessRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncCycleSummary].
extension SyncCycleSummaryPatterns on SyncCycleSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncCycleSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncCycleSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncCycleSummary value)  $default,){
final _that = this;
switch (_that) {
case _SyncCycleSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncCycleSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SyncCycleSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime recordedAt,  int durationMs,  int pullRemoteCount,  int pullRemoteFailures,  int pendingAtStart,  int operationsProcessed,  int operationsFailed,  Map<String, int> pendingByEntity,  int prunedCount,  Map<String, double> retryAttemptsByEntity,  Map<String, String> lastErrorByEntity,  double retrySuccessRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncCycleSummary() when $default != null:
return $default(_that.recordedAt,_that.durationMs,_that.pullRemoteCount,_that.pullRemoteFailures,_that.pendingAtStart,_that.operationsProcessed,_that.operationsFailed,_that.pendingByEntity,_that.prunedCount,_that.retryAttemptsByEntity,_that.lastErrorByEntity,_that.retrySuccessRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime recordedAt,  int durationMs,  int pullRemoteCount,  int pullRemoteFailures,  int pendingAtStart,  int operationsProcessed,  int operationsFailed,  Map<String, int> pendingByEntity,  int prunedCount,  Map<String, double> retryAttemptsByEntity,  Map<String, String> lastErrorByEntity,  double retrySuccessRate)  $default,) {final _that = this;
switch (_that) {
case _SyncCycleSummary():
return $default(_that.recordedAt,_that.durationMs,_that.pullRemoteCount,_that.pullRemoteFailures,_that.pendingAtStart,_that.operationsProcessed,_that.operationsFailed,_that.pendingByEntity,_that.prunedCount,_that.retryAttemptsByEntity,_that.lastErrorByEntity,_that.retrySuccessRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime recordedAt,  int durationMs,  int pullRemoteCount,  int pullRemoteFailures,  int pendingAtStart,  int operationsProcessed,  int operationsFailed,  Map<String, int> pendingByEntity,  int prunedCount,  Map<String, double> retryAttemptsByEntity,  Map<String, String> lastErrorByEntity,  double retrySuccessRate)?  $default,) {final _that = this;
switch (_that) {
case _SyncCycleSummary() when $default != null:
return $default(_that.recordedAt,_that.durationMs,_that.pullRemoteCount,_that.pullRemoteFailures,_that.pendingAtStart,_that.operationsProcessed,_that.operationsFailed,_that.pendingByEntity,_that.prunedCount,_that.retryAttemptsByEntity,_that.lastErrorByEntity,_that.retrySuccessRate);case _:
  return null;

}
}

}

/// @nodoc


class _SyncCycleSummary implements SyncCycleSummary {
  const _SyncCycleSummary({required this.recordedAt, required this.durationMs, required this.pullRemoteCount, required this.pullRemoteFailures, required this.pendingAtStart, required this.operationsProcessed, required this.operationsFailed, required final  Map<String, int> pendingByEntity, this.prunedCount = 0, final  Map<String, double> retryAttemptsByEntity = const <String, double>{}, final  Map<String, String> lastErrorByEntity = const <String, String>{}, this.retrySuccessRate = 0.0}): _pendingByEntity = pendingByEntity,_retryAttemptsByEntity = retryAttemptsByEntity,_lastErrorByEntity = lastErrorByEntity;
  

@override final  DateTime recordedAt;
@override final  int durationMs;
@override final  int pullRemoteCount;
@override final  int pullRemoteFailures;
@override final  int pendingAtStart;
@override final  int operationsProcessed;
@override final  int operationsFailed;
 final  Map<String, int> _pendingByEntity;
@override Map<String, int> get pendingByEntity {
  if (_pendingByEntity is EqualUnmodifiableMapView) return _pendingByEntity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pendingByEntity);
}

@override@JsonKey() final  int prunedCount;
 final  Map<String, double> _retryAttemptsByEntity;
@override@JsonKey() Map<String, double> get retryAttemptsByEntity {
  if (_retryAttemptsByEntity is EqualUnmodifiableMapView) return _retryAttemptsByEntity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_retryAttemptsByEntity);
}

 final  Map<String, String> _lastErrorByEntity;
@override@JsonKey() Map<String, String> get lastErrorByEntity {
  if (_lastErrorByEntity is EqualUnmodifiableMapView) return _lastErrorByEntity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lastErrorByEntity);
}

@override@JsonKey() final  double retrySuccessRate;

/// Create a copy of SyncCycleSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncCycleSummaryCopyWith<_SyncCycleSummary> get copyWith => __$SyncCycleSummaryCopyWithImpl<_SyncCycleSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncCycleSummary&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.pullRemoteCount, pullRemoteCount) || other.pullRemoteCount == pullRemoteCount)&&(identical(other.pullRemoteFailures, pullRemoteFailures) || other.pullRemoteFailures == pullRemoteFailures)&&(identical(other.pendingAtStart, pendingAtStart) || other.pendingAtStart == pendingAtStart)&&(identical(other.operationsProcessed, operationsProcessed) || other.operationsProcessed == operationsProcessed)&&(identical(other.operationsFailed, operationsFailed) || other.operationsFailed == operationsFailed)&&const DeepCollectionEquality().equals(other._pendingByEntity, _pendingByEntity)&&(identical(other.prunedCount, prunedCount) || other.prunedCount == prunedCount)&&const DeepCollectionEquality().equals(other._retryAttemptsByEntity, _retryAttemptsByEntity)&&const DeepCollectionEquality().equals(other._lastErrorByEntity, _lastErrorByEntity)&&(identical(other.retrySuccessRate, retrySuccessRate) || other.retrySuccessRate == retrySuccessRate));
}


@override
int get hashCode => Object.hash(runtimeType,recordedAt,durationMs,pullRemoteCount,pullRemoteFailures,pendingAtStart,operationsProcessed,operationsFailed,const DeepCollectionEquality().hash(_pendingByEntity),prunedCount,const DeepCollectionEquality().hash(_retryAttemptsByEntity),const DeepCollectionEquality().hash(_lastErrorByEntity),retrySuccessRate);

@override
String toString() {
  return 'SyncCycleSummary(recordedAt: $recordedAt, durationMs: $durationMs, pullRemoteCount: $pullRemoteCount, pullRemoteFailures: $pullRemoteFailures, pendingAtStart: $pendingAtStart, operationsProcessed: $operationsProcessed, operationsFailed: $operationsFailed, pendingByEntity: $pendingByEntity, prunedCount: $prunedCount, retryAttemptsByEntity: $retryAttemptsByEntity, lastErrorByEntity: $lastErrorByEntity, retrySuccessRate: $retrySuccessRate)';
}


}

/// @nodoc
abstract mixin class _$SyncCycleSummaryCopyWith<$Res> implements $SyncCycleSummaryCopyWith<$Res> {
  factory _$SyncCycleSummaryCopyWith(_SyncCycleSummary value, $Res Function(_SyncCycleSummary) _then) = __$SyncCycleSummaryCopyWithImpl;
@override @useResult
$Res call({
 DateTime recordedAt, int durationMs, int pullRemoteCount, int pullRemoteFailures, int pendingAtStart, int operationsProcessed, int operationsFailed, Map<String, int> pendingByEntity, int prunedCount, Map<String, double> retryAttemptsByEntity, Map<String, String> lastErrorByEntity, double retrySuccessRate
});




}
/// @nodoc
class __$SyncCycleSummaryCopyWithImpl<$Res>
    implements _$SyncCycleSummaryCopyWith<$Res> {
  __$SyncCycleSummaryCopyWithImpl(this._self, this._then);

  final _SyncCycleSummary _self;
  final $Res Function(_SyncCycleSummary) _then;

/// Create a copy of SyncCycleSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordedAt = null,Object? durationMs = null,Object? pullRemoteCount = null,Object? pullRemoteFailures = null,Object? pendingAtStart = null,Object? operationsProcessed = null,Object? operationsFailed = null,Object? pendingByEntity = null,Object? prunedCount = null,Object? retryAttemptsByEntity = null,Object? lastErrorByEntity = null,Object? retrySuccessRate = null,}) {
  return _then(_SyncCycleSummary(
recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,pullRemoteCount: null == pullRemoteCount ? _self.pullRemoteCount : pullRemoteCount // ignore: cast_nullable_to_non_nullable
as int,pullRemoteFailures: null == pullRemoteFailures ? _self.pullRemoteFailures : pullRemoteFailures // ignore: cast_nullable_to_non_nullable
as int,pendingAtStart: null == pendingAtStart ? _self.pendingAtStart : pendingAtStart // ignore: cast_nullable_to_non_nullable
as int,operationsProcessed: null == operationsProcessed ? _self.operationsProcessed : operationsProcessed // ignore: cast_nullable_to_non_nullable
as int,operationsFailed: null == operationsFailed ? _self.operationsFailed : operationsFailed // ignore: cast_nullable_to_non_nullable
as int,pendingByEntity: null == pendingByEntity ? _self._pendingByEntity : pendingByEntity // ignore: cast_nullable_to_non_nullable
as Map<String, int>,prunedCount: null == prunedCount ? _self.prunedCount : prunedCount // ignore: cast_nullable_to_non_nullable
as int,retryAttemptsByEntity: null == retryAttemptsByEntity ? _self._retryAttemptsByEntity : retryAttemptsByEntity // ignore: cast_nullable_to_non_nullable
as Map<String, double>,lastErrorByEntity: null == lastErrorByEntity ? _self._lastErrorByEntity : lastErrorByEntity // ignore: cast_nullable_to_non_nullable
as Map<String, String>,retrySuccessRate: null == retrySuccessRate ? _self.retrySuccessRate : retrySuccessRate // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
