// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_maps_sample_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapBodyData implements DiagnosticableTreeMixin {

 bool get showLoading; bool get hasError; String? get errorMessage;
/// Create a copy of _MapBodyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapBodyDataCopyWith<_MapBodyData> get copyWith => __$MapBodyDataCopyWithImpl<_MapBodyData>(this as _MapBodyData, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_MapBodyData'))
    ..add(DiagnosticsProperty('showLoading', showLoading))..add(DiagnosticsProperty('hasError', hasError))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapBodyData&&(identical(other.showLoading, showLoading) || other.showLoading == showLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,showLoading,hasError,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_MapBodyData(showLoading: $showLoading, hasError: $hasError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$MapBodyDataCopyWith<$Res>  {
  factory _$MapBodyDataCopyWith(_MapBodyData value, $Res Function(_MapBodyData) _then) = __$MapBodyDataCopyWithImpl;
@useResult
$Res call({
 bool showLoading, bool hasError, String? errorMessage
});




}
/// @nodoc
class __$MapBodyDataCopyWithImpl<$Res>
    implements _$MapBodyDataCopyWith<$Res> {
  __$MapBodyDataCopyWithImpl(this._self, this._then);

  final _MapBodyData _self;
  final $Res Function(_MapBodyData) _then;

/// Create a copy of _MapBodyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showLoading = null,Object? hasError = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
showLoading: null == showLoading ? _self.showLoading : showLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [_MapBodyData].
extension _MapBodyDataPatterns on _MapBodyData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __MapBodyData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __MapBodyData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __MapBodyData value)  $default,){
final _that = this;
switch (_that) {
case __MapBodyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __MapBodyData value)?  $default,){
final _that = this;
switch (_that) {
case __MapBodyData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showLoading,  bool hasError,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __MapBodyData() when $default != null:
return $default(_that.showLoading,_that.hasError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showLoading,  bool hasError,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case __MapBodyData():
return $default(_that.showLoading,_that.hasError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showLoading,  bool hasError,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case __MapBodyData() when $default != null:
return $default(_that.showLoading,_that.hasError,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class __MapBodyData with DiagnosticableTreeMixin implements _MapBodyData {
  const __MapBodyData({required this.showLoading, required this.hasError, required this.errorMessage});
  

@override final  bool showLoading;
@override final  bool hasError;
@override final  String? errorMessage;

/// Create a copy of _MapBodyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_MapBodyDataCopyWith<__MapBodyData> get copyWith => __$_MapBodyDataCopyWithImpl<__MapBodyData>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_MapBodyData'))
    ..add(DiagnosticsProperty('showLoading', showLoading))..add(DiagnosticsProperty('hasError', hasError))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __MapBodyData&&(identical(other.showLoading, showLoading) || other.showLoading == showLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,showLoading,hasError,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_MapBodyData(showLoading: $showLoading, hasError: $hasError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$_MapBodyDataCopyWith<$Res> implements _$MapBodyDataCopyWith<$Res> {
  factory _$_MapBodyDataCopyWith(__MapBodyData value, $Res Function(__MapBodyData) _then) = __$_MapBodyDataCopyWithImpl;
@override @useResult
$Res call({
 bool showLoading, bool hasError, String? errorMessage
});




}
/// @nodoc
class __$_MapBodyDataCopyWithImpl<$Res>
    implements _$_MapBodyDataCopyWith<$Res> {
  __$_MapBodyDataCopyWithImpl(this._self, this._then);

  final __MapBodyData _self;
  final $Res Function(__MapBodyData) _then;

/// Create a copy of _MapBodyData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showLoading = null,Object? hasError = null,Object? errorMessage = freezed,}) {
  return _then(__MapBodyData(
showLoading: null == showLoading ? _self.showLoading : showLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ControlsViewModel implements DiagnosticableTreeMixin {

 bool get isHybridMapType; bool get trafficEnabled;
/// Create a copy of _ControlsViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ControlsViewModelCopyWith<_ControlsViewModel> get copyWith => __$ControlsViewModelCopyWithImpl<_ControlsViewModel>(this as _ControlsViewModel, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_ControlsViewModel'))
    ..add(DiagnosticsProperty('isHybridMapType', isHybridMapType))..add(DiagnosticsProperty('trafficEnabled', trafficEnabled));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ControlsViewModel&&(identical(other.isHybridMapType, isHybridMapType) || other.isHybridMapType == isHybridMapType)&&(identical(other.trafficEnabled, trafficEnabled) || other.trafficEnabled == trafficEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isHybridMapType,trafficEnabled);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_ControlsViewModel(isHybridMapType: $isHybridMapType, trafficEnabled: $trafficEnabled)';
}


}

/// @nodoc
abstract mixin class _$ControlsViewModelCopyWith<$Res>  {
  factory _$ControlsViewModelCopyWith(_ControlsViewModel value, $Res Function(_ControlsViewModel) _then) = __$ControlsViewModelCopyWithImpl;
@useResult
$Res call({
 bool isHybridMapType, bool trafficEnabled
});




}
/// @nodoc
class __$ControlsViewModelCopyWithImpl<$Res>
    implements _$ControlsViewModelCopyWith<$Res> {
  __$ControlsViewModelCopyWithImpl(this._self, this._then);

  final _ControlsViewModel _self;
  final $Res Function(_ControlsViewModel) _then;

/// Create a copy of _ControlsViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isHybridMapType = null,Object? trafficEnabled = null,}) {
  return _then(_self.copyWith(
isHybridMapType: null == isHybridMapType ? _self.isHybridMapType : isHybridMapType // ignore: cast_nullable_to_non_nullable
as bool,trafficEnabled: null == trafficEnabled ? _self.trafficEnabled : trafficEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [_ControlsViewModel].
extension _ControlsViewModelPatterns on _ControlsViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __ControlsViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __ControlsViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __ControlsViewModel value)  $default,){
final _that = this;
switch (_that) {
case __ControlsViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __ControlsViewModel value)?  $default,){
final _that = this;
switch (_that) {
case __ControlsViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isHybridMapType,  bool trafficEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __ControlsViewModel() when $default != null:
return $default(_that.isHybridMapType,_that.trafficEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isHybridMapType,  bool trafficEnabled)  $default,) {final _that = this;
switch (_that) {
case __ControlsViewModel():
return $default(_that.isHybridMapType,_that.trafficEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isHybridMapType,  bool trafficEnabled)?  $default,) {final _that = this;
switch (_that) {
case __ControlsViewModel() when $default != null:
return $default(_that.isHybridMapType,_that.trafficEnabled);case _:
  return null;

}
}

}

/// @nodoc


class __ControlsViewModel with DiagnosticableTreeMixin implements _ControlsViewModel {
  const __ControlsViewModel({required this.isHybridMapType, required this.trafficEnabled});
  

@override final  bool isHybridMapType;
@override final  bool trafficEnabled;

/// Create a copy of _ControlsViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_ControlsViewModelCopyWith<__ControlsViewModel> get copyWith => __$_ControlsViewModelCopyWithImpl<__ControlsViewModel>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_ControlsViewModel'))
    ..add(DiagnosticsProperty('isHybridMapType', isHybridMapType))..add(DiagnosticsProperty('trafficEnabled', trafficEnabled));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __ControlsViewModel&&(identical(other.isHybridMapType, isHybridMapType) || other.isHybridMapType == isHybridMapType)&&(identical(other.trafficEnabled, trafficEnabled) || other.trafficEnabled == trafficEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isHybridMapType,trafficEnabled);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_ControlsViewModel(isHybridMapType: $isHybridMapType, trafficEnabled: $trafficEnabled)';
}


}

/// @nodoc
abstract mixin class _$_ControlsViewModelCopyWith<$Res> implements _$ControlsViewModelCopyWith<$Res> {
  factory _$_ControlsViewModelCopyWith(__ControlsViewModel value, $Res Function(__ControlsViewModel) _then) = __$_ControlsViewModelCopyWithImpl;
@override @useResult
$Res call({
 bool isHybridMapType, bool trafficEnabled
});




}
/// @nodoc
class __$_ControlsViewModelCopyWithImpl<$Res>
    implements _$_ControlsViewModelCopyWith<$Res> {
  __$_ControlsViewModelCopyWithImpl(this._self, this._then);

  final __ControlsViewModel _self;
  final $Res Function(__ControlsViewModel) _then;

/// Create a copy of _ControlsViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isHybridMapType = null,Object? trafficEnabled = null,}) {
  return _then(__ControlsViewModel(
isHybridMapType: null == isHybridMapType ? _self.isHybridMapType : isHybridMapType // ignore: cast_nullable_to_non_nullable
as bool,trafficEnabled: null == trafficEnabled ? _self.trafficEnabled : trafficEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LocationListViewModel implements DiagnosticableTreeMixin {

 List<MapLocation> get locations; String? get selectedMarkerId;
/// Create a copy of _LocationListViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationListViewModelCopyWith<_LocationListViewModel> get copyWith => __$LocationListViewModelCopyWithImpl<_LocationListViewModel>(this as _LocationListViewModel, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_LocationListViewModel'))
    ..add(DiagnosticsProperty('locations', locations))..add(DiagnosticsProperty('selectedMarkerId', selectedMarkerId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationListViewModel&&const DeepCollectionEquality().equals(other.locations, locations)&&(identical(other.selectedMarkerId, selectedMarkerId) || other.selectedMarkerId == selectedMarkerId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(locations),selectedMarkerId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_LocationListViewModel(locations: $locations, selectedMarkerId: $selectedMarkerId)';
}


}

/// @nodoc
abstract mixin class _$LocationListViewModelCopyWith<$Res>  {
  factory _$LocationListViewModelCopyWith(_LocationListViewModel value, $Res Function(_LocationListViewModel) _then) = __$LocationListViewModelCopyWithImpl;
@useResult
$Res call({
 List<MapLocation> locations, String? selectedMarkerId
});




}
/// @nodoc
class __$LocationListViewModelCopyWithImpl<$Res>
    implements _$LocationListViewModelCopyWith<$Res> {
  __$LocationListViewModelCopyWithImpl(this._self, this._then);

  final _LocationListViewModel _self;
  final $Res Function(_LocationListViewModel) _then;

/// Create a copy of _LocationListViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locations = null,Object? selectedMarkerId = freezed,}) {
  return _then(_self.copyWith(
locations: null == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<MapLocation>,selectedMarkerId: freezed == selectedMarkerId ? _self.selectedMarkerId : selectedMarkerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [_LocationListViewModel].
extension _LocationListViewModelPatterns on _LocationListViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __LocationListViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __LocationListViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __LocationListViewModel value)  $default,){
final _that = this;
switch (_that) {
case __LocationListViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __LocationListViewModel value)?  $default,){
final _that = this;
switch (_that) {
case __LocationListViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MapLocation> locations,  String? selectedMarkerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __LocationListViewModel() when $default != null:
return $default(_that.locations,_that.selectedMarkerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MapLocation> locations,  String? selectedMarkerId)  $default,) {final _that = this;
switch (_that) {
case __LocationListViewModel():
return $default(_that.locations,_that.selectedMarkerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MapLocation> locations,  String? selectedMarkerId)?  $default,) {final _that = this;
switch (_that) {
case __LocationListViewModel() when $default != null:
return $default(_that.locations,_that.selectedMarkerId);case _:
  return null;

}
}

}

/// @nodoc


class __LocationListViewModel with DiagnosticableTreeMixin implements _LocationListViewModel {
  const __LocationListViewModel({required final  List<MapLocation> locations, required this.selectedMarkerId}): _locations = locations;
  

 final  List<MapLocation> _locations;
@override List<MapLocation> get locations {
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locations);
}

@override final  String? selectedMarkerId;

/// Create a copy of _LocationListViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_LocationListViewModelCopyWith<__LocationListViewModel> get copyWith => __$_LocationListViewModelCopyWithImpl<__LocationListViewModel>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_LocationListViewModel'))
    ..add(DiagnosticsProperty('locations', locations))..add(DiagnosticsProperty('selectedMarkerId', selectedMarkerId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __LocationListViewModel&&const DeepCollectionEquality().equals(other._locations, _locations)&&(identical(other.selectedMarkerId, selectedMarkerId) || other.selectedMarkerId == selectedMarkerId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_locations),selectedMarkerId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_LocationListViewModel(locations: $locations, selectedMarkerId: $selectedMarkerId)';
}


}

/// @nodoc
abstract mixin class _$_LocationListViewModelCopyWith<$Res> implements _$LocationListViewModelCopyWith<$Res> {
  factory _$_LocationListViewModelCopyWith(__LocationListViewModel value, $Res Function(__LocationListViewModel) _then) = __$_LocationListViewModelCopyWithImpl;
@override @useResult
$Res call({
 List<MapLocation> locations, String? selectedMarkerId
});




}
/// @nodoc
class __$_LocationListViewModelCopyWithImpl<$Res>
    implements _$_LocationListViewModelCopyWith<$Res> {
  __$_LocationListViewModelCopyWithImpl(this._self, this._then);

  final __LocationListViewModel _self;
  final $Res Function(__LocationListViewModel) _then;

/// Create a copy of _LocationListViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locations = null,Object? selectedMarkerId = freezed,}) {
  return _then(__LocationListViewModel(
locations: null == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<MapLocation>,selectedMarkerId: freezed == selectedMarkerId ? _self.selectedMarkerId : selectedMarkerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
