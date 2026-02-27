// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_gallery_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraGalleryState {

 ViewStatus get status; String? get imagePath;/// L10n key for user-visible error (e.g. cameraGalleryPermissionDenied).
 String? get errorKey;
/// Create a copy of CameraGalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CameraGalleryStateCopyWith<CameraGalleryState> get copyWith => _$CameraGalleryStateCopyWithImpl<CameraGalleryState>(this as CameraGalleryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraGalleryState&&(identical(other.status, status) || other.status == status)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.errorKey, errorKey) || other.errorKey == errorKey));
}


@override
int get hashCode => Object.hash(runtimeType,status,imagePath,errorKey);

@override
String toString() {
  return 'CameraGalleryState(status: $status, imagePath: $imagePath, errorKey: $errorKey)';
}


}

/// @nodoc
abstract mixin class $CameraGalleryStateCopyWith<$Res>  {
  factory $CameraGalleryStateCopyWith(CameraGalleryState value, $Res Function(CameraGalleryState) _then) = _$CameraGalleryStateCopyWithImpl;
@useResult
$Res call({
 ViewStatus status, String? imagePath, String? errorKey
});




}
/// @nodoc
class _$CameraGalleryStateCopyWithImpl<$Res>
    implements $CameraGalleryStateCopyWith<$Res> {
  _$CameraGalleryStateCopyWithImpl(this._self, this._then);

  final CameraGalleryState _self;
  final $Res Function(CameraGalleryState) _then;

/// Create a copy of CameraGalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? imagePath = freezed,Object? errorKey = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,errorKey: freezed == errorKey ? _self.errorKey : errorKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CameraGalleryState].
extension CameraGalleryStatePatterns on CameraGalleryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CameraGalleryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraGalleryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CameraGalleryState value)  $default,){
final _that = this;
switch (_that) {
case _CameraGalleryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CameraGalleryState value)?  $default,){
final _that = this;
switch (_that) {
case _CameraGalleryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ViewStatus status,  String? imagePath,  String? errorKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraGalleryState() when $default != null:
return $default(_that.status,_that.imagePath,_that.errorKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ViewStatus status,  String? imagePath,  String? errorKey)  $default,) {final _that = this;
switch (_that) {
case _CameraGalleryState():
return $default(_that.status,_that.imagePath,_that.errorKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ViewStatus status,  String? imagePath,  String? errorKey)?  $default,) {final _that = this;
switch (_that) {
case _CameraGalleryState() when $default != null:
return $default(_that.status,_that.imagePath,_that.errorKey);case _:
  return null;

}
}

}

/// @nodoc


class _CameraGalleryState extends CameraGalleryState {
  const _CameraGalleryState({this.status = ViewStatus.initial, this.imagePath, this.errorKey}): super._();
  

@override@JsonKey() final  ViewStatus status;
@override final  String? imagePath;
/// L10n key for user-visible error (e.g. cameraGalleryPermissionDenied).
@override final  String? errorKey;

/// Create a copy of CameraGalleryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraGalleryStateCopyWith<_CameraGalleryState> get copyWith => __$CameraGalleryStateCopyWithImpl<_CameraGalleryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraGalleryState&&(identical(other.status, status) || other.status == status)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.errorKey, errorKey) || other.errorKey == errorKey));
}


@override
int get hashCode => Object.hash(runtimeType,status,imagePath,errorKey);

@override
String toString() {
  return 'CameraGalleryState(status: $status, imagePath: $imagePath, errorKey: $errorKey)';
}


}

/// @nodoc
abstract mixin class _$CameraGalleryStateCopyWith<$Res> implements $CameraGalleryStateCopyWith<$Res> {
  factory _$CameraGalleryStateCopyWith(_CameraGalleryState value, $Res Function(_CameraGalleryState) _then) = __$CameraGalleryStateCopyWithImpl;
@override @useResult
$Res call({
 ViewStatus status, String? imagePath, String? errorKey
});




}
/// @nodoc
class __$CameraGalleryStateCopyWithImpl<$Res>
    implements _$CameraGalleryStateCopyWith<$Res> {
  __$CameraGalleryStateCopyWithImpl(this._self, this._then);

  final _CameraGalleryState _self;
  final $Res Function(_CameraGalleryState) _then;

/// Create a copy of CameraGalleryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? imagePath = freezed,Object? errorKey = freezed,}) {
  return _then(_CameraGalleryState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,errorKey: freezed == errorKey ? _self.errorKey : errorKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
