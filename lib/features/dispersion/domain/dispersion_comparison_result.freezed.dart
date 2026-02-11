// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispersion_comparison_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DispersionComparisonResult {

 String get datasetAId; String get datasetBId; int get nA; int get nB; double get uStatistic; double get zScore; double get pValueTwoSided; double get alpha; bool get isSignificant; double get effectSizeRankBiserial; int get excludedOutliersCount; bool get smallSampleCaution;
/// Create a copy of DispersionComparisonResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispersionComparisonResultCopyWith<DispersionComparisonResult> get copyWith => _$DispersionComparisonResultCopyWithImpl<DispersionComparisonResult>(this as DispersionComparisonResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispersionComparisonResult&&(identical(other.datasetAId, datasetAId) || other.datasetAId == datasetAId)&&(identical(other.datasetBId, datasetBId) || other.datasetBId == datasetBId)&&(identical(other.nA, nA) || other.nA == nA)&&(identical(other.nB, nB) || other.nB == nB)&&(identical(other.uStatistic, uStatistic) || other.uStatistic == uStatistic)&&(identical(other.zScore, zScore) || other.zScore == zScore)&&(identical(other.pValueTwoSided, pValueTwoSided) || other.pValueTwoSided == pValueTwoSided)&&(identical(other.alpha, alpha) || other.alpha == alpha)&&(identical(other.isSignificant, isSignificant) || other.isSignificant == isSignificant)&&(identical(other.effectSizeRankBiserial, effectSizeRankBiserial) || other.effectSizeRankBiserial == effectSizeRankBiserial)&&(identical(other.excludedOutliersCount, excludedOutliersCount) || other.excludedOutliersCount == excludedOutliersCount)&&(identical(other.smallSampleCaution, smallSampleCaution) || other.smallSampleCaution == smallSampleCaution));
}


@override
int get hashCode => Object.hash(runtimeType,datasetAId,datasetBId,nA,nB,uStatistic,zScore,pValueTwoSided,alpha,isSignificant,effectSizeRankBiserial,excludedOutliersCount,smallSampleCaution);

@override
String toString() {
  return 'DispersionComparisonResult(datasetAId: $datasetAId, datasetBId: $datasetBId, nA: $nA, nB: $nB, uStatistic: $uStatistic, zScore: $zScore, pValueTwoSided: $pValueTwoSided, alpha: $alpha, isSignificant: $isSignificant, effectSizeRankBiserial: $effectSizeRankBiserial, excludedOutliersCount: $excludedOutliersCount, smallSampleCaution: $smallSampleCaution)';
}


}

/// @nodoc
abstract mixin class $DispersionComparisonResultCopyWith<$Res>  {
  factory $DispersionComparisonResultCopyWith(DispersionComparisonResult value, $Res Function(DispersionComparisonResult) _then) = _$DispersionComparisonResultCopyWithImpl;
@useResult
$Res call({
 String datasetAId, String datasetBId, int nA, int nB, double uStatistic, double zScore, double pValueTwoSided, double alpha, bool isSignificant, double effectSizeRankBiserial, int excludedOutliersCount, bool smallSampleCaution
});




}
/// @nodoc
class _$DispersionComparisonResultCopyWithImpl<$Res>
    implements $DispersionComparisonResultCopyWith<$Res> {
  _$DispersionComparisonResultCopyWithImpl(this._self, this._then);

  final DispersionComparisonResult _self;
  final $Res Function(DispersionComparisonResult) _then;

/// Create a copy of DispersionComparisonResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? datasetAId = null,Object? datasetBId = null,Object? nA = null,Object? nB = null,Object? uStatistic = null,Object? zScore = null,Object? pValueTwoSided = null,Object? alpha = null,Object? isSignificant = null,Object? effectSizeRankBiserial = null,Object? excludedOutliersCount = null,Object? smallSampleCaution = null,}) {
  return _then(_self.copyWith(
datasetAId: null == datasetAId ? _self.datasetAId : datasetAId // ignore: cast_nullable_to_non_nullable
as String,datasetBId: null == datasetBId ? _self.datasetBId : datasetBId // ignore: cast_nullable_to_non_nullable
as String,nA: null == nA ? _self.nA : nA // ignore: cast_nullable_to_non_nullable
as int,nB: null == nB ? _self.nB : nB // ignore: cast_nullable_to_non_nullable
as int,uStatistic: null == uStatistic ? _self.uStatistic : uStatistic // ignore: cast_nullable_to_non_nullable
as double,zScore: null == zScore ? _self.zScore : zScore // ignore: cast_nullable_to_non_nullable
as double,pValueTwoSided: null == pValueTwoSided ? _self.pValueTwoSided : pValueTwoSided // ignore: cast_nullable_to_non_nullable
as double,alpha: null == alpha ? _self.alpha : alpha // ignore: cast_nullable_to_non_nullable
as double,isSignificant: null == isSignificant ? _self.isSignificant : isSignificant // ignore: cast_nullable_to_non_nullable
as bool,effectSizeRankBiserial: null == effectSizeRankBiserial ? _self.effectSizeRankBiserial : effectSizeRankBiserial // ignore: cast_nullable_to_non_nullable
as double,excludedOutliersCount: null == excludedOutliersCount ? _self.excludedOutliersCount : excludedOutliersCount // ignore: cast_nullable_to_non_nullable
as int,smallSampleCaution: null == smallSampleCaution ? _self.smallSampleCaution : smallSampleCaution // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DispersionComparisonResult].
extension DispersionComparisonResultPatterns on DispersionComparisonResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispersionComparisonResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispersionComparisonResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispersionComparisonResult value)  $default,){
final _that = this;
switch (_that) {
case _DispersionComparisonResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispersionComparisonResult value)?  $default,){
final _that = this;
switch (_that) {
case _DispersionComparisonResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String datasetAId,  String datasetBId,  int nA,  int nB,  double uStatistic,  double zScore,  double pValueTwoSided,  double alpha,  bool isSignificant,  double effectSizeRankBiserial,  int excludedOutliersCount,  bool smallSampleCaution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispersionComparisonResult() when $default != null:
return $default(_that.datasetAId,_that.datasetBId,_that.nA,_that.nB,_that.uStatistic,_that.zScore,_that.pValueTwoSided,_that.alpha,_that.isSignificant,_that.effectSizeRankBiserial,_that.excludedOutliersCount,_that.smallSampleCaution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String datasetAId,  String datasetBId,  int nA,  int nB,  double uStatistic,  double zScore,  double pValueTwoSided,  double alpha,  bool isSignificant,  double effectSizeRankBiserial,  int excludedOutliersCount,  bool smallSampleCaution)  $default,) {final _that = this;
switch (_that) {
case _DispersionComparisonResult():
return $default(_that.datasetAId,_that.datasetBId,_that.nA,_that.nB,_that.uStatistic,_that.zScore,_that.pValueTwoSided,_that.alpha,_that.isSignificant,_that.effectSizeRankBiserial,_that.excludedOutliersCount,_that.smallSampleCaution);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String datasetAId,  String datasetBId,  int nA,  int nB,  double uStatistic,  double zScore,  double pValueTwoSided,  double alpha,  bool isSignificant,  double effectSizeRankBiserial,  int excludedOutliersCount,  bool smallSampleCaution)?  $default,) {final _that = this;
switch (_that) {
case _DispersionComparisonResult() when $default != null:
return $default(_that.datasetAId,_that.datasetBId,_that.nA,_that.nB,_that.uStatistic,_that.zScore,_that.pValueTwoSided,_that.alpha,_that.isSignificant,_that.effectSizeRankBiserial,_that.excludedOutliersCount,_that.smallSampleCaution);case _:
  return null;

}
}

}

/// @nodoc


class _DispersionComparisonResult extends DispersionComparisonResult {
  const _DispersionComparisonResult({required this.datasetAId, required this.datasetBId, required this.nA, required this.nB, required this.uStatistic, required this.zScore, required this.pValueTwoSided, required this.alpha, required this.isSignificant, required this.effectSizeRankBiserial, this.excludedOutliersCount = 0, this.smallSampleCaution = false}): super._();
  

@override final  String datasetAId;
@override final  String datasetBId;
@override final  int nA;
@override final  int nB;
@override final  double uStatistic;
@override final  double zScore;
@override final  double pValueTwoSided;
@override final  double alpha;
@override final  bool isSignificant;
@override final  double effectSizeRankBiserial;
@override@JsonKey() final  int excludedOutliersCount;
@override@JsonKey() final  bool smallSampleCaution;

/// Create a copy of DispersionComparisonResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispersionComparisonResultCopyWith<_DispersionComparisonResult> get copyWith => __$DispersionComparisonResultCopyWithImpl<_DispersionComparisonResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispersionComparisonResult&&(identical(other.datasetAId, datasetAId) || other.datasetAId == datasetAId)&&(identical(other.datasetBId, datasetBId) || other.datasetBId == datasetBId)&&(identical(other.nA, nA) || other.nA == nA)&&(identical(other.nB, nB) || other.nB == nB)&&(identical(other.uStatistic, uStatistic) || other.uStatistic == uStatistic)&&(identical(other.zScore, zScore) || other.zScore == zScore)&&(identical(other.pValueTwoSided, pValueTwoSided) || other.pValueTwoSided == pValueTwoSided)&&(identical(other.alpha, alpha) || other.alpha == alpha)&&(identical(other.isSignificant, isSignificant) || other.isSignificant == isSignificant)&&(identical(other.effectSizeRankBiserial, effectSizeRankBiserial) || other.effectSizeRankBiserial == effectSizeRankBiserial)&&(identical(other.excludedOutliersCount, excludedOutliersCount) || other.excludedOutliersCount == excludedOutliersCount)&&(identical(other.smallSampleCaution, smallSampleCaution) || other.smallSampleCaution == smallSampleCaution));
}


@override
int get hashCode => Object.hash(runtimeType,datasetAId,datasetBId,nA,nB,uStatistic,zScore,pValueTwoSided,alpha,isSignificant,effectSizeRankBiserial,excludedOutliersCount,smallSampleCaution);

@override
String toString() {
  return 'DispersionComparisonResult(datasetAId: $datasetAId, datasetBId: $datasetBId, nA: $nA, nB: $nB, uStatistic: $uStatistic, zScore: $zScore, pValueTwoSided: $pValueTwoSided, alpha: $alpha, isSignificant: $isSignificant, effectSizeRankBiserial: $effectSizeRankBiserial, excludedOutliersCount: $excludedOutliersCount, smallSampleCaution: $smallSampleCaution)';
}


}

/// @nodoc
abstract mixin class _$DispersionComparisonResultCopyWith<$Res> implements $DispersionComparisonResultCopyWith<$Res> {
  factory _$DispersionComparisonResultCopyWith(_DispersionComparisonResult value, $Res Function(_DispersionComparisonResult) _then) = __$DispersionComparisonResultCopyWithImpl;
@override @useResult
$Res call({
 String datasetAId, String datasetBId, int nA, int nB, double uStatistic, double zScore, double pValueTwoSided, double alpha, bool isSignificant, double effectSizeRankBiserial, int excludedOutliersCount, bool smallSampleCaution
});




}
/// @nodoc
class __$DispersionComparisonResultCopyWithImpl<$Res>
    implements _$DispersionComparisonResultCopyWith<$Res> {
  __$DispersionComparisonResultCopyWithImpl(this._self, this._then);

  final _DispersionComparisonResult _self;
  final $Res Function(_DispersionComparisonResult) _then;

/// Create a copy of DispersionComparisonResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? datasetAId = null,Object? datasetBId = null,Object? nA = null,Object? nB = null,Object? uStatistic = null,Object? zScore = null,Object? pValueTwoSided = null,Object? alpha = null,Object? isSignificant = null,Object? effectSizeRankBiserial = null,Object? excludedOutliersCount = null,Object? smallSampleCaution = null,}) {
  return _then(_DispersionComparisonResult(
datasetAId: null == datasetAId ? _self.datasetAId : datasetAId // ignore: cast_nullable_to_non_nullable
as String,datasetBId: null == datasetBId ? _self.datasetBId : datasetBId // ignore: cast_nullable_to_non_nullable
as String,nA: null == nA ? _self.nA : nA // ignore: cast_nullable_to_non_nullable
as int,nB: null == nB ? _self.nB : nB // ignore: cast_nullable_to_non_nullable
as int,uStatistic: null == uStatistic ? _self.uStatistic : uStatistic // ignore: cast_nullable_to_non_nullable
as double,zScore: null == zScore ? _self.zScore : zScore // ignore: cast_nullable_to_non_nullable
as double,pValueTwoSided: null == pValueTwoSided ? _self.pValueTwoSided : pValueTwoSided // ignore: cast_nullable_to_non_nullable
as double,alpha: null == alpha ? _self.alpha : alpha // ignore: cast_nullable_to_non_nullable
as double,isSignificant: null == isSignificant ? _self.isSignificant : isSignificant // ignore: cast_nullable_to_non_nullable
as bool,effectSizeRankBiserial: null == effectSizeRankBiserial ? _self.effectSizeRankBiserial : effectSizeRankBiserial // ignore: cast_nullable_to_non_nullable
as double,excludedOutliersCount: null == excludedOutliersCount ? _self.excludedOutliersCount : excludedOutliersCount // ignore: cast_nullable_to_non_nullable
as int,smallSampleCaution: null == smallSampleCaution ? _self.smallSampleCaution : smallSampleCaution // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
