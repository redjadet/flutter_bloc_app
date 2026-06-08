// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_showcase_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlatformShowcaseData {

 AppPlatformKind get platform; List<NativeCapability> get capabilities; List<NativeInteropCallResult> get interopResults;
/// Create a copy of PlatformShowcaseData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformShowcaseDataCopyWith<PlatformShowcaseData> get copyWith => _$PlatformShowcaseDataCopyWithImpl<PlatformShowcaseData>(this as PlatformShowcaseData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformShowcaseData&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other.capabilities, capabilities)&&const DeepCollectionEquality().equals(other.interopResults, interopResults));
}


@override
int get hashCode => Object.hash(runtimeType,platform,const DeepCollectionEquality().hash(capabilities),const DeepCollectionEquality().hash(interopResults));

@override
String toString() {
  return 'PlatformShowcaseData(platform: $platform, capabilities: $capabilities, interopResults: $interopResults)';
}


}

/// @nodoc
abstract mixin class $PlatformShowcaseDataCopyWith<$Res>  {
  factory $PlatformShowcaseDataCopyWith(PlatformShowcaseData value, $Res Function(PlatformShowcaseData) _then) = _$PlatformShowcaseDataCopyWithImpl;
@useResult
$Res call({
 AppPlatformKind platform, List<NativeCapability> capabilities, List<NativeInteropCallResult> interopResults
});




}
/// @nodoc
class _$PlatformShowcaseDataCopyWithImpl<$Res>
    implements $PlatformShowcaseDataCopyWith<$Res> {
  _$PlatformShowcaseDataCopyWithImpl(this._self, this._then);

  final PlatformShowcaseData _self;
  final $Res Function(PlatformShowcaseData) _then;

/// Create a copy of PlatformShowcaseData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? capabilities = null,Object? interopResults = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as AppPlatformKind,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<NativeCapability>,interopResults: null == interopResults ? _self.interopResults : interopResults // ignore: cast_nullable_to_non_nullable
as List<NativeInteropCallResult>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformShowcaseData].
extension PlatformShowcaseDataPatterns on PlatformShowcaseData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformShowcaseData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformShowcaseData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformShowcaseData value)  $default,){
final _that = this;
switch (_that) {
case _PlatformShowcaseData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformShowcaseData value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformShowcaseData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppPlatformKind platform,  List<NativeCapability> capabilities,  List<NativeInteropCallResult> interopResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformShowcaseData() when $default != null:
return $default(_that.platform,_that.capabilities,_that.interopResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppPlatformKind platform,  List<NativeCapability> capabilities,  List<NativeInteropCallResult> interopResults)  $default,) {final _that = this;
switch (_that) {
case _PlatformShowcaseData():
return $default(_that.platform,_that.capabilities,_that.interopResults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppPlatformKind platform,  List<NativeCapability> capabilities,  List<NativeInteropCallResult> interopResults)?  $default,) {final _that = this;
switch (_that) {
case _PlatformShowcaseData() when $default != null:
return $default(_that.platform,_that.capabilities,_that.interopResults);case _:
  return null;

}
}

}

/// @nodoc


class _PlatformShowcaseData implements PlatformShowcaseData {
  const _PlatformShowcaseData({required this.platform, required final  List<NativeCapability> capabilities, required final  List<NativeInteropCallResult> interopResults}): _capabilities = capabilities,_interopResults = interopResults;
  

@override final  AppPlatformKind platform;
 final  List<NativeCapability> _capabilities;
@override List<NativeCapability> get capabilities {
  if (_capabilities is EqualUnmodifiableListView) return _capabilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_capabilities);
}

 final  List<NativeInteropCallResult> _interopResults;
@override List<NativeInteropCallResult> get interopResults {
  if (_interopResults is EqualUnmodifiableListView) return _interopResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interopResults);
}


/// Create a copy of PlatformShowcaseData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformShowcaseDataCopyWith<_PlatformShowcaseData> get copyWith => __$PlatformShowcaseDataCopyWithImpl<_PlatformShowcaseData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformShowcaseData&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other._capabilities, _capabilities)&&const DeepCollectionEquality().equals(other._interopResults, _interopResults));
}


@override
int get hashCode => Object.hash(runtimeType,platform,const DeepCollectionEquality().hash(_capabilities),const DeepCollectionEquality().hash(_interopResults));

@override
String toString() {
  return 'PlatformShowcaseData(platform: $platform, capabilities: $capabilities, interopResults: $interopResults)';
}


}

/// @nodoc
abstract mixin class _$PlatformShowcaseDataCopyWith<$Res> implements $PlatformShowcaseDataCopyWith<$Res> {
  factory _$PlatformShowcaseDataCopyWith(_PlatformShowcaseData value, $Res Function(_PlatformShowcaseData) _then) = __$PlatformShowcaseDataCopyWithImpl;
@override @useResult
$Res call({
 AppPlatformKind platform, List<NativeCapability> capabilities, List<NativeInteropCallResult> interopResults
});




}
/// @nodoc
class __$PlatformShowcaseDataCopyWithImpl<$Res>
    implements _$PlatformShowcaseDataCopyWith<$Res> {
  __$PlatformShowcaseDataCopyWithImpl(this._self, this._then);

  final _PlatformShowcaseData _self;
  final $Res Function(_PlatformShowcaseData) _then;

/// Create a copy of PlatformShowcaseData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? capabilities = null,Object? interopResults = null,}) {
  return _then(_PlatformShowcaseData(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as AppPlatformKind,capabilities: null == capabilities ? _self._capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as List<NativeCapability>,interopResults: null == interopResults ? _self._interopResults : interopResults // ignore: cast_nullable_to_non_nullable
as List<NativeInteropCallResult>,
  ));
}


}

// dart format on
