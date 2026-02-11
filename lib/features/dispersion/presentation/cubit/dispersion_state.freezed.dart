// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispersion_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DispersionState {

 DispersionScreen get screen; List<DispersionDataset> get datasets; List<DispersionGroup> get groups; bool get isLoading; String? get errorMessage;// Create group flow
 String? get createImagePath; Calibration? get createCalibration; PixelPoint? get createAimPointPx; List<DispersionPoint> get createPoints; String? get createSelectedPointId; double get createDistanceMeters; double get createKnownLengthMm; double get createCalibrationE1x; double get createCalibrationE1y; double get createCalibrationE2x; double get createCalibrationE2y; double get createAimPx; double get createAimPy; String? get createGroupName; double? get createHoleDiameterMm; int get createSamplePointIndex;// Comparison
 String? get compareDatasetAId; String? get compareDatasetBId; double get compareAlpha; bool get compareExcludeOutliers; DispersionComparisonResult? get compareResult; bool get compareLoading; List<DispersionPoint>? get comparePointsA; List<DispersionPoint>? get comparePointsB;
/// Create a copy of DispersionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispersionStateCopyWith<DispersionState> get copyWith => _$DispersionStateCopyWithImpl<DispersionState>(this as DispersionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispersionState&&(identical(other.screen, screen) || other.screen == screen)&&const DeepCollectionEquality().equals(other.datasets, datasets)&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createImagePath, createImagePath) || other.createImagePath == createImagePath)&&(identical(other.createCalibration, createCalibration) || other.createCalibration == createCalibration)&&(identical(other.createAimPointPx, createAimPointPx) || other.createAimPointPx == createAimPointPx)&&const DeepCollectionEquality().equals(other.createPoints, createPoints)&&(identical(other.createSelectedPointId, createSelectedPointId) || other.createSelectedPointId == createSelectedPointId)&&(identical(other.createDistanceMeters, createDistanceMeters) || other.createDistanceMeters == createDistanceMeters)&&(identical(other.createKnownLengthMm, createKnownLengthMm) || other.createKnownLengthMm == createKnownLengthMm)&&(identical(other.createCalibrationE1x, createCalibrationE1x) || other.createCalibrationE1x == createCalibrationE1x)&&(identical(other.createCalibrationE1y, createCalibrationE1y) || other.createCalibrationE1y == createCalibrationE1y)&&(identical(other.createCalibrationE2x, createCalibrationE2x) || other.createCalibrationE2x == createCalibrationE2x)&&(identical(other.createCalibrationE2y, createCalibrationE2y) || other.createCalibrationE2y == createCalibrationE2y)&&(identical(other.createAimPx, createAimPx) || other.createAimPx == createAimPx)&&(identical(other.createAimPy, createAimPy) || other.createAimPy == createAimPy)&&(identical(other.createGroupName, createGroupName) || other.createGroupName == createGroupName)&&(identical(other.createHoleDiameterMm, createHoleDiameterMm) || other.createHoleDiameterMm == createHoleDiameterMm)&&(identical(other.createSamplePointIndex, createSamplePointIndex) || other.createSamplePointIndex == createSamplePointIndex)&&(identical(other.compareDatasetAId, compareDatasetAId) || other.compareDatasetAId == compareDatasetAId)&&(identical(other.compareDatasetBId, compareDatasetBId) || other.compareDatasetBId == compareDatasetBId)&&(identical(other.compareAlpha, compareAlpha) || other.compareAlpha == compareAlpha)&&(identical(other.compareExcludeOutliers, compareExcludeOutliers) || other.compareExcludeOutliers == compareExcludeOutliers)&&(identical(other.compareResult, compareResult) || other.compareResult == compareResult)&&(identical(other.compareLoading, compareLoading) || other.compareLoading == compareLoading)&&const DeepCollectionEquality().equals(other.comparePointsA, comparePointsA)&&const DeepCollectionEquality().equals(other.comparePointsB, comparePointsB));
}


@override
int get hashCode => Object.hashAll([runtimeType,screen,const DeepCollectionEquality().hash(datasets),const DeepCollectionEquality().hash(groups),isLoading,errorMessage,createImagePath,createCalibration,createAimPointPx,const DeepCollectionEquality().hash(createPoints),createSelectedPointId,createDistanceMeters,createKnownLengthMm,createCalibrationE1x,createCalibrationE1y,createCalibrationE2x,createCalibrationE2y,createAimPx,createAimPy,createGroupName,createHoleDiameterMm,createSamplePointIndex,compareDatasetAId,compareDatasetBId,compareAlpha,compareExcludeOutliers,compareResult,compareLoading,const DeepCollectionEquality().hash(comparePointsA),const DeepCollectionEquality().hash(comparePointsB)]);

@override
String toString() {
  return 'DispersionState(screen: $screen, datasets: $datasets, groups: $groups, isLoading: $isLoading, errorMessage: $errorMessage, createImagePath: $createImagePath, createCalibration: $createCalibration, createAimPointPx: $createAimPointPx, createPoints: $createPoints, createSelectedPointId: $createSelectedPointId, createDistanceMeters: $createDistanceMeters, createKnownLengthMm: $createKnownLengthMm, createCalibrationE1x: $createCalibrationE1x, createCalibrationE1y: $createCalibrationE1y, createCalibrationE2x: $createCalibrationE2x, createCalibrationE2y: $createCalibrationE2y, createAimPx: $createAimPx, createAimPy: $createAimPy, createGroupName: $createGroupName, createHoleDiameterMm: $createHoleDiameterMm, createSamplePointIndex: $createSamplePointIndex, compareDatasetAId: $compareDatasetAId, compareDatasetBId: $compareDatasetBId, compareAlpha: $compareAlpha, compareExcludeOutliers: $compareExcludeOutliers, compareResult: $compareResult, compareLoading: $compareLoading, comparePointsA: $comparePointsA, comparePointsB: $comparePointsB)';
}


}

/// @nodoc
abstract mixin class $DispersionStateCopyWith<$Res>  {
  factory $DispersionStateCopyWith(DispersionState value, $Res Function(DispersionState) _then) = _$DispersionStateCopyWithImpl;
@useResult
$Res call({
 DispersionScreen screen, List<DispersionDataset> datasets, List<DispersionGroup> groups, bool isLoading, String? errorMessage, String? createImagePath, Calibration? createCalibration, PixelPoint? createAimPointPx, List<DispersionPoint> createPoints, String? createSelectedPointId, double createDistanceMeters, double createKnownLengthMm, double createCalibrationE1x, double createCalibrationE1y, double createCalibrationE2x, double createCalibrationE2y, double createAimPx, double createAimPy, String? createGroupName, double? createHoleDiameterMm, int createSamplePointIndex, String? compareDatasetAId, String? compareDatasetBId, double compareAlpha, bool compareExcludeOutliers, DispersionComparisonResult? compareResult, bool compareLoading, List<DispersionPoint>? comparePointsA, List<DispersionPoint>? comparePointsB
});


$DispersionComparisonResultCopyWith<$Res>? get compareResult;

}
/// @nodoc
class _$DispersionStateCopyWithImpl<$Res>
    implements $DispersionStateCopyWith<$Res> {
  _$DispersionStateCopyWithImpl(this._self, this._then);

  final DispersionState _self;
  final $Res Function(DispersionState) _then;

/// Create a copy of DispersionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? screen = null,Object? datasets = null,Object? groups = null,Object? isLoading = null,Object? errorMessage = freezed,Object? createImagePath = freezed,Object? createCalibration = freezed,Object? createAimPointPx = freezed,Object? createPoints = null,Object? createSelectedPointId = freezed,Object? createDistanceMeters = null,Object? createKnownLengthMm = null,Object? createCalibrationE1x = null,Object? createCalibrationE1y = null,Object? createCalibrationE2x = null,Object? createCalibrationE2y = null,Object? createAimPx = null,Object? createAimPy = null,Object? createGroupName = freezed,Object? createHoleDiameterMm = freezed,Object? createSamplePointIndex = null,Object? compareDatasetAId = freezed,Object? compareDatasetBId = freezed,Object? compareAlpha = null,Object? compareExcludeOutliers = null,Object? compareResult = freezed,Object? compareLoading = null,Object? comparePointsA = freezed,Object? comparePointsB = freezed,}) {
  return _then(_self.copyWith(
screen: null == screen ? _self.screen : screen // ignore: cast_nullable_to_non_nullable
as DispersionScreen,datasets: null == datasets ? _self.datasets : datasets // ignore: cast_nullable_to_non_nullable
as List<DispersionDataset>,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<DispersionGroup>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createImagePath: freezed == createImagePath ? _self.createImagePath : createImagePath // ignore: cast_nullable_to_non_nullable
as String?,createCalibration: freezed == createCalibration ? _self.createCalibration : createCalibration // ignore: cast_nullable_to_non_nullable
as Calibration?,createAimPointPx: freezed == createAimPointPx ? _self.createAimPointPx : createAimPointPx // ignore: cast_nullable_to_non_nullable
as PixelPoint?,createPoints: null == createPoints ? _self.createPoints : createPoints // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>,createSelectedPointId: freezed == createSelectedPointId ? _self.createSelectedPointId : createSelectedPointId // ignore: cast_nullable_to_non_nullable
as String?,createDistanceMeters: null == createDistanceMeters ? _self.createDistanceMeters : createDistanceMeters // ignore: cast_nullable_to_non_nullable
as double,createKnownLengthMm: null == createKnownLengthMm ? _self.createKnownLengthMm : createKnownLengthMm // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE1x: null == createCalibrationE1x ? _self.createCalibrationE1x : createCalibrationE1x // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE1y: null == createCalibrationE1y ? _self.createCalibrationE1y : createCalibrationE1y // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE2x: null == createCalibrationE2x ? _self.createCalibrationE2x : createCalibrationE2x // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE2y: null == createCalibrationE2y ? _self.createCalibrationE2y : createCalibrationE2y // ignore: cast_nullable_to_non_nullable
as double,createAimPx: null == createAimPx ? _self.createAimPx : createAimPx // ignore: cast_nullable_to_non_nullable
as double,createAimPy: null == createAimPy ? _self.createAimPy : createAimPy // ignore: cast_nullable_to_non_nullable
as double,createGroupName: freezed == createGroupName ? _self.createGroupName : createGroupName // ignore: cast_nullable_to_non_nullable
as String?,createHoleDiameterMm: freezed == createHoleDiameterMm ? _self.createHoleDiameterMm : createHoleDiameterMm // ignore: cast_nullable_to_non_nullable
as double?,createSamplePointIndex: null == createSamplePointIndex ? _self.createSamplePointIndex : createSamplePointIndex // ignore: cast_nullable_to_non_nullable
as int,compareDatasetAId: freezed == compareDatasetAId ? _self.compareDatasetAId : compareDatasetAId // ignore: cast_nullable_to_non_nullable
as String?,compareDatasetBId: freezed == compareDatasetBId ? _self.compareDatasetBId : compareDatasetBId // ignore: cast_nullable_to_non_nullable
as String?,compareAlpha: null == compareAlpha ? _self.compareAlpha : compareAlpha // ignore: cast_nullable_to_non_nullable
as double,compareExcludeOutliers: null == compareExcludeOutliers ? _self.compareExcludeOutliers : compareExcludeOutliers // ignore: cast_nullable_to_non_nullable
as bool,compareResult: freezed == compareResult ? _self.compareResult : compareResult // ignore: cast_nullable_to_non_nullable
as DispersionComparisonResult?,compareLoading: null == compareLoading ? _self.compareLoading : compareLoading // ignore: cast_nullable_to_non_nullable
as bool,comparePointsA: freezed == comparePointsA ? _self.comparePointsA : comparePointsA // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>?,comparePointsB: freezed == comparePointsB ? _self.comparePointsB : comparePointsB // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>?,
  ));
}
/// Create a copy of DispersionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DispersionComparisonResultCopyWith<$Res>? get compareResult {
    if (_self.compareResult == null) {
    return null;
  }

  return $DispersionComparisonResultCopyWith<$Res>(_self.compareResult!, (value) {
    return _then(_self.copyWith(compareResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [DispersionState].
extension DispersionStatePatterns on DispersionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispersionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispersionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispersionState value)  $default,){
final _that = this;
switch (_that) {
case _DispersionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispersionState value)?  $default,){
final _that = this;
switch (_that) {
case _DispersionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DispersionScreen screen,  List<DispersionDataset> datasets,  List<DispersionGroup> groups,  bool isLoading,  String? errorMessage,  String? createImagePath,  Calibration? createCalibration,  PixelPoint? createAimPointPx,  List<DispersionPoint> createPoints,  String? createSelectedPointId,  double createDistanceMeters,  double createKnownLengthMm,  double createCalibrationE1x,  double createCalibrationE1y,  double createCalibrationE2x,  double createCalibrationE2y,  double createAimPx,  double createAimPy,  String? createGroupName,  double? createHoleDiameterMm,  int createSamplePointIndex,  String? compareDatasetAId,  String? compareDatasetBId,  double compareAlpha,  bool compareExcludeOutliers,  DispersionComparisonResult? compareResult,  bool compareLoading,  List<DispersionPoint>? comparePointsA,  List<DispersionPoint>? comparePointsB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispersionState() when $default != null:
return $default(_that.screen,_that.datasets,_that.groups,_that.isLoading,_that.errorMessage,_that.createImagePath,_that.createCalibration,_that.createAimPointPx,_that.createPoints,_that.createSelectedPointId,_that.createDistanceMeters,_that.createKnownLengthMm,_that.createCalibrationE1x,_that.createCalibrationE1y,_that.createCalibrationE2x,_that.createCalibrationE2y,_that.createAimPx,_that.createAimPy,_that.createGroupName,_that.createHoleDiameterMm,_that.createSamplePointIndex,_that.compareDatasetAId,_that.compareDatasetBId,_that.compareAlpha,_that.compareExcludeOutliers,_that.compareResult,_that.compareLoading,_that.comparePointsA,_that.comparePointsB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DispersionScreen screen,  List<DispersionDataset> datasets,  List<DispersionGroup> groups,  bool isLoading,  String? errorMessage,  String? createImagePath,  Calibration? createCalibration,  PixelPoint? createAimPointPx,  List<DispersionPoint> createPoints,  String? createSelectedPointId,  double createDistanceMeters,  double createKnownLengthMm,  double createCalibrationE1x,  double createCalibrationE1y,  double createCalibrationE2x,  double createCalibrationE2y,  double createAimPx,  double createAimPy,  String? createGroupName,  double? createHoleDiameterMm,  int createSamplePointIndex,  String? compareDatasetAId,  String? compareDatasetBId,  double compareAlpha,  bool compareExcludeOutliers,  DispersionComparisonResult? compareResult,  bool compareLoading,  List<DispersionPoint>? comparePointsA,  List<DispersionPoint>? comparePointsB)  $default,) {final _that = this;
switch (_that) {
case _DispersionState():
return $default(_that.screen,_that.datasets,_that.groups,_that.isLoading,_that.errorMessage,_that.createImagePath,_that.createCalibration,_that.createAimPointPx,_that.createPoints,_that.createSelectedPointId,_that.createDistanceMeters,_that.createKnownLengthMm,_that.createCalibrationE1x,_that.createCalibrationE1y,_that.createCalibrationE2x,_that.createCalibrationE2y,_that.createAimPx,_that.createAimPy,_that.createGroupName,_that.createHoleDiameterMm,_that.createSamplePointIndex,_that.compareDatasetAId,_that.compareDatasetBId,_that.compareAlpha,_that.compareExcludeOutliers,_that.compareResult,_that.compareLoading,_that.comparePointsA,_that.comparePointsB);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DispersionScreen screen,  List<DispersionDataset> datasets,  List<DispersionGroup> groups,  bool isLoading,  String? errorMessage,  String? createImagePath,  Calibration? createCalibration,  PixelPoint? createAimPointPx,  List<DispersionPoint> createPoints,  String? createSelectedPointId,  double createDistanceMeters,  double createKnownLengthMm,  double createCalibrationE1x,  double createCalibrationE1y,  double createCalibrationE2x,  double createCalibrationE2y,  double createAimPx,  double createAimPy,  String? createGroupName,  double? createHoleDiameterMm,  int createSamplePointIndex,  String? compareDatasetAId,  String? compareDatasetBId,  double compareAlpha,  bool compareExcludeOutliers,  DispersionComparisonResult? compareResult,  bool compareLoading,  List<DispersionPoint>? comparePointsA,  List<DispersionPoint>? comparePointsB)?  $default,) {final _that = this;
switch (_that) {
case _DispersionState() when $default != null:
return $default(_that.screen,_that.datasets,_that.groups,_that.isLoading,_that.errorMessage,_that.createImagePath,_that.createCalibration,_that.createAimPointPx,_that.createPoints,_that.createSelectedPointId,_that.createDistanceMeters,_that.createKnownLengthMm,_that.createCalibrationE1x,_that.createCalibrationE1y,_that.createCalibrationE2x,_that.createCalibrationE2y,_that.createAimPx,_that.createAimPy,_that.createGroupName,_that.createHoleDiameterMm,_that.createSamplePointIndex,_that.compareDatasetAId,_that.compareDatasetBId,_that.compareAlpha,_that.compareExcludeOutliers,_that.compareResult,_that.compareLoading,_that.comparePointsA,_that.comparePointsB);case _:
  return null;

}
}

}

/// @nodoc


class _DispersionState extends DispersionState {
  const _DispersionState({this.screen = DispersionScreen.home, final  List<DispersionDataset> datasets = const [], final  List<DispersionGroup> groups = const [], this.isLoading = true, this.errorMessage, this.createImagePath, this.createCalibration, this.createAimPointPx, final  List<DispersionPoint> createPoints = const [], this.createSelectedPointId, this.createDistanceMeters = 0, this.createKnownLengthMm = 0, this.createCalibrationE1x = 0, this.createCalibrationE1y = 0, this.createCalibrationE2x = 0, this.createCalibrationE2y = 0, this.createAimPx = 0, this.createAimPy = 0, this.createGroupName, this.createHoleDiameterMm, this.createSamplePointIndex = 0, this.compareDatasetAId, this.compareDatasetBId, this.compareAlpha = 0.05, this.compareExcludeOutliers = true, this.compareResult, this.compareLoading = false, final  List<DispersionPoint>? comparePointsA, final  List<DispersionPoint>? comparePointsB}): _datasets = datasets,_groups = groups,_createPoints = createPoints,_comparePointsA = comparePointsA,_comparePointsB = comparePointsB,super._();
  

@override@JsonKey() final  DispersionScreen screen;
 final  List<DispersionDataset> _datasets;
@override@JsonKey() List<DispersionDataset> get datasets {
  if (_datasets is EqualUnmodifiableListView) return _datasets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_datasets);
}

 final  List<DispersionGroup> _groups;
@override@JsonKey() List<DispersionGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
// Create group flow
@override final  String? createImagePath;
@override final  Calibration? createCalibration;
@override final  PixelPoint? createAimPointPx;
 final  List<DispersionPoint> _createPoints;
@override@JsonKey() List<DispersionPoint> get createPoints {
  if (_createPoints is EqualUnmodifiableListView) return _createPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_createPoints);
}

@override final  String? createSelectedPointId;
@override@JsonKey() final  double createDistanceMeters;
@override@JsonKey() final  double createKnownLengthMm;
@override@JsonKey() final  double createCalibrationE1x;
@override@JsonKey() final  double createCalibrationE1y;
@override@JsonKey() final  double createCalibrationE2x;
@override@JsonKey() final  double createCalibrationE2y;
@override@JsonKey() final  double createAimPx;
@override@JsonKey() final  double createAimPy;
@override final  String? createGroupName;
@override final  double? createHoleDiameterMm;
@override@JsonKey() final  int createSamplePointIndex;
// Comparison
@override final  String? compareDatasetAId;
@override final  String? compareDatasetBId;
@override@JsonKey() final  double compareAlpha;
@override@JsonKey() final  bool compareExcludeOutliers;
@override final  DispersionComparisonResult? compareResult;
@override@JsonKey() final  bool compareLoading;
 final  List<DispersionPoint>? _comparePointsA;
@override List<DispersionPoint>? get comparePointsA {
  final value = _comparePointsA;
  if (value == null) return null;
  if (_comparePointsA is EqualUnmodifiableListView) return _comparePointsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<DispersionPoint>? _comparePointsB;
@override List<DispersionPoint>? get comparePointsB {
  final value = _comparePointsB;
  if (value == null) return null;
  if (_comparePointsB is EqualUnmodifiableListView) return _comparePointsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of DispersionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispersionStateCopyWith<_DispersionState> get copyWith => __$DispersionStateCopyWithImpl<_DispersionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispersionState&&(identical(other.screen, screen) || other.screen == screen)&&const DeepCollectionEquality().equals(other._datasets, _datasets)&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.createImagePath, createImagePath) || other.createImagePath == createImagePath)&&(identical(other.createCalibration, createCalibration) || other.createCalibration == createCalibration)&&(identical(other.createAimPointPx, createAimPointPx) || other.createAimPointPx == createAimPointPx)&&const DeepCollectionEquality().equals(other._createPoints, _createPoints)&&(identical(other.createSelectedPointId, createSelectedPointId) || other.createSelectedPointId == createSelectedPointId)&&(identical(other.createDistanceMeters, createDistanceMeters) || other.createDistanceMeters == createDistanceMeters)&&(identical(other.createKnownLengthMm, createKnownLengthMm) || other.createKnownLengthMm == createKnownLengthMm)&&(identical(other.createCalibrationE1x, createCalibrationE1x) || other.createCalibrationE1x == createCalibrationE1x)&&(identical(other.createCalibrationE1y, createCalibrationE1y) || other.createCalibrationE1y == createCalibrationE1y)&&(identical(other.createCalibrationE2x, createCalibrationE2x) || other.createCalibrationE2x == createCalibrationE2x)&&(identical(other.createCalibrationE2y, createCalibrationE2y) || other.createCalibrationE2y == createCalibrationE2y)&&(identical(other.createAimPx, createAimPx) || other.createAimPx == createAimPx)&&(identical(other.createAimPy, createAimPy) || other.createAimPy == createAimPy)&&(identical(other.createGroupName, createGroupName) || other.createGroupName == createGroupName)&&(identical(other.createHoleDiameterMm, createHoleDiameterMm) || other.createHoleDiameterMm == createHoleDiameterMm)&&(identical(other.createSamplePointIndex, createSamplePointIndex) || other.createSamplePointIndex == createSamplePointIndex)&&(identical(other.compareDatasetAId, compareDatasetAId) || other.compareDatasetAId == compareDatasetAId)&&(identical(other.compareDatasetBId, compareDatasetBId) || other.compareDatasetBId == compareDatasetBId)&&(identical(other.compareAlpha, compareAlpha) || other.compareAlpha == compareAlpha)&&(identical(other.compareExcludeOutliers, compareExcludeOutliers) || other.compareExcludeOutliers == compareExcludeOutliers)&&(identical(other.compareResult, compareResult) || other.compareResult == compareResult)&&(identical(other.compareLoading, compareLoading) || other.compareLoading == compareLoading)&&const DeepCollectionEquality().equals(other._comparePointsA, _comparePointsA)&&const DeepCollectionEquality().equals(other._comparePointsB, _comparePointsB));
}


@override
int get hashCode => Object.hashAll([runtimeType,screen,const DeepCollectionEquality().hash(_datasets),const DeepCollectionEquality().hash(_groups),isLoading,errorMessage,createImagePath,createCalibration,createAimPointPx,const DeepCollectionEquality().hash(_createPoints),createSelectedPointId,createDistanceMeters,createKnownLengthMm,createCalibrationE1x,createCalibrationE1y,createCalibrationE2x,createCalibrationE2y,createAimPx,createAimPy,createGroupName,createHoleDiameterMm,createSamplePointIndex,compareDatasetAId,compareDatasetBId,compareAlpha,compareExcludeOutliers,compareResult,compareLoading,const DeepCollectionEquality().hash(_comparePointsA),const DeepCollectionEquality().hash(_comparePointsB)]);

@override
String toString() {
  return 'DispersionState(screen: $screen, datasets: $datasets, groups: $groups, isLoading: $isLoading, errorMessage: $errorMessage, createImagePath: $createImagePath, createCalibration: $createCalibration, createAimPointPx: $createAimPointPx, createPoints: $createPoints, createSelectedPointId: $createSelectedPointId, createDistanceMeters: $createDistanceMeters, createKnownLengthMm: $createKnownLengthMm, createCalibrationE1x: $createCalibrationE1x, createCalibrationE1y: $createCalibrationE1y, createCalibrationE2x: $createCalibrationE2x, createCalibrationE2y: $createCalibrationE2y, createAimPx: $createAimPx, createAimPy: $createAimPy, createGroupName: $createGroupName, createHoleDiameterMm: $createHoleDiameterMm, createSamplePointIndex: $createSamplePointIndex, compareDatasetAId: $compareDatasetAId, compareDatasetBId: $compareDatasetBId, compareAlpha: $compareAlpha, compareExcludeOutliers: $compareExcludeOutliers, compareResult: $compareResult, compareLoading: $compareLoading, comparePointsA: $comparePointsA, comparePointsB: $comparePointsB)';
}


}

/// @nodoc
abstract mixin class _$DispersionStateCopyWith<$Res> implements $DispersionStateCopyWith<$Res> {
  factory _$DispersionStateCopyWith(_DispersionState value, $Res Function(_DispersionState) _then) = __$DispersionStateCopyWithImpl;
@override @useResult
$Res call({
 DispersionScreen screen, List<DispersionDataset> datasets, List<DispersionGroup> groups, bool isLoading, String? errorMessage, String? createImagePath, Calibration? createCalibration, PixelPoint? createAimPointPx, List<DispersionPoint> createPoints, String? createSelectedPointId, double createDistanceMeters, double createKnownLengthMm, double createCalibrationE1x, double createCalibrationE1y, double createCalibrationE2x, double createCalibrationE2y, double createAimPx, double createAimPy, String? createGroupName, double? createHoleDiameterMm, int createSamplePointIndex, String? compareDatasetAId, String? compareDatasetBId, double compareAlpha, bool compareExcludeOutliers, DispersionComparisonResult? compareResult, bool compareLoading, List<DispersionPoint>? comparePointsA, List<DispersionPoint>? comparePointsB
});


@override $DispersionComparisonResultCopyWith<$Res>? get compareResult;

}
/// @nodoc
class __$DispersionStateCopyWithImpl<$Res>
    implements _$DispersionStateCopyWith<$Res> {
  __$DispersionStateCopyWithImpl(this._self, this._then);

  final _DispersionState _self;
  final $Res Function(_DispersionState) _then;

/// Create a copy of DispersionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? screen = null,Object? datasets = null,Object? groups = null,Object? isLoading = null,Object? errorMessage = freezed,Object? createImagePath = freezed,Object? createCalibration = freezed,Object? createAimPointPx = freezed,Object? createPoints = null,Object? createSelectedPointId = freezed,Object? createDistanceMeters = null,Object? createKnownLengthMm = null,Object? createCalibrationE1x = null,Object? createCalibrationE1y = null,Object? createCalibrationE2x = null,Object? createCalibrationE2y = null,Object? createAimPx = null,Object? createAimPy = null,Object? createGroupName = freezed,Object? createHoleDiameterMm = freezed,Object? createSamplePointIndex = null,Object? compareDatasetAId = freezed,Object? compareDatasetBId = freezed,Object? compareAlpha = null,Object? compareExcludeOutliers = null,Object? compareResult = freezed,Object? compareLoading = null,Object? comparePointsA = freezed,Object? comparePointsB = freezed,}) {
  return _then(_DispersionState(
screen: null == screen ? _self.screen : screen // ignore: cast_nullable_to_non_nullable
as DispersionScreen,datasets: null == datasets ? _self._datasets : datasets // ignore: cast_nullable_to_non_nullable
as List<DispersionDataset>,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<DispersionGroup>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,createImagePath: freezed == createImagePath ? _self.createImagePath : createImagePath // ignore: cast_nullable_to_non_nullable
as String?,createCalibration: freezed == createCalibration ? _self.createCalibration : createCalibration // ignore: cast_nullable_to_non_nullable
as Calibration?,createAimPointPx: freezed == createAimPointPx ? _self.createAimPointPx : createAimPointPx // ignore: cast_nullable_to_non_nullable
as PixelPoint?,createPoints: null == createPoints ? _self._createPoints : createPoints // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>,createSelectedPointId: freezed == createSelectedPointId ? _self.createSelectedPointId : createSelectedPointId // ignore: cast_nullable_to_non_nullable
as String?,createDistanceMeters: null == createDistanceMeters ? _self.createDistanceMeters : createDistanceMeters // ignore: cast_nullable_to_non_nullable
as double,createKnownLengthMm: null == createKnownLengthMm ? _self.createKnownLengthMm : createKnownLengthMm // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE1x: null == createCalibrationE1x ? _self.createCalibrationE1x : createCalibrationE1x // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE1y: null == createCalibrationE1y ? _self.createCalibrationE1y : createCalibrationE1y // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE2x: null == createCalibrationE2x ? _self.createCalibrationE2x : createCalibrationE2x // ignore: cast_nullable_to_non_nullable
as double,createCalibrationE2y: null == createCalibrationE2y ? _self.createCalibrationE2y : createCalibrationE2y // ignore: cast_nullable_to_non_nullable
as double,createAimPx: null == createAimPx ? _self.createAimPx : createAimPx // ignore: cast_nullable_to_non_nullable
as double,createAimPy: null == createAimPy ? _self.createAimPy : createAimPy // ignore: cast_nullable_to_non_nullable
as double,createGroupName: freezed == createGroupName ? _self.createGroupName : createGroupName // ignore: cast_nullable_to_non_nullable
as String?,createHoleDiameterMm: freezed == createHoleDiameterMm ? _self.createHoleDiameterMm : createHoleDiameterMm // ignore: cast_nullable_to_non_nullable
as double?,createSamplePointIndex: null == createSamplePointIndex ? _self.createSamplePointIndex : createSamplePointIndex // ignore: cast_nullable_to_non_nullable
as int,compareDatasetAId: freezed == compareDatasetAId ? _self.compareDatasetAId : compareDatasetAId // ignore: cast_nullable_to_non_nullable
as String?,compareDatasetBId: freezed == compareDatasetBId ? _self.compareDatasetBId : compareDatasetBId // ignore: cast_nullable_to_non_nullable
as String?,compareAlpha: null == compareAlpha ? _self.compareAlpha : compareAlpha // ignore: cast_nullable_to_non_nullable
as double,compareExcludeOutliers: null == compareExcludeOutliers ? _self.compareExcludeOutliers : compareExcludeOutliers // ignore: cast_nullable_to_non_nullable
as bool,compareResult: freezed == compareResult ? _self.compareResult : compareResult // ignore: cast_nullable_to_non_nullable
as DispersionComparisonResult?,compareLoading: null == compareLoading ? _self.compareLoading : compareLoading // ignore: cast_nullable_to_non_nullable
as bool,comparePointsA: freezed == comparePointsA ? _self._comparePointsA : comparePointsA // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>?,comparePointsB: freezed == comparePointsB ? _self._comparePointsB : comparePointsB // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>?,
  ));
}

/// Create a copy of DispersionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DispersionComparisonResultCopyWith<$Res>? get compareResult {
    if (_self.compareResult == null) {
    return null;
  }

  return $DispersionComparisonResultCopyWith<$Res>(_self.compareResult!, (value) {
    return _then(_self.copyWith(compareResult: value));
  });
}
}

// dart format on
