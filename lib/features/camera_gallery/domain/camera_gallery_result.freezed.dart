// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_gallery_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CameraGalleryResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CameraGalleryResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CameraGalleryResult()';
}


}

/// @nodoc
class $CameraGalleryResultCopyWith<$Res>  {
$CameraGalleryResultCopyWith(CameraGalleryResult _, $Res Function(CameraGalleryResult) __);
}


/// Adds pattern-matching-related methods to [CameraGalleryResult].
extension CameraGalleryResultPatterns on CameraGalleryResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CameraGalleryResultSuccess value)?  success,TResult Function( _CameraGalleryResultCancelled value)?  cancelled,TResult Function( _CameraGalleryResultFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CameraGalleryResultSuccess() when success != null:
return success(_that);case _CameraGalleryResultCancelled() when cancelled != null:
return cancelled(_that);case _CameraGalleryResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CameraGalleryResultSuccess value)  success,required TResult Function( _CameraGalleryResultCancelled value)  cancelled,required TResult Function( _CameraGalleryResultFailure value)  failure,}){
final _that = this;
switch (_that) {
case _CameraGalleryResultSuccess():
return success(_that);case _CameraGalleryResultCancelled():
return cancelled(_that);case _CameraGalleryResultFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CameraGalleryResultSuccess value)?  success,TResult? Function( _CameraGalleryResultCancelled value)?  cancelled,TResult? Function( _CameraGalleryResultFailure value)?  failure,}){
final _that = this;
switch (_that) {
case _CameraGalleryResultSuccess() when success != null:
return success(_that);case _CameraGalleryResultCancelled() when cancelled != null:
return cancelled(_that);case _CameraGalleryResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String imagePath)?  success,TResult Function()?  cancelled,TResult Function( String errorKey,  String? message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CameraGalleryResultSuccess() when success != null:
return success(_that.imagePath);case _CameraGalleryResultCancelled() when cancelled != null:
return cancelled();case _CameraGalleryResultFailure() when failure != null:
return failure(_that.errorKey,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String imagePath)  success,required TResult Function()  cancelled,required TResult Function( String errorKey,  String? message)  failure,}) {final _that = this;
switch (_that) {
case _CameraGalleryResultSuccess():
return success(_that.imagePath);case _CameraGalleryResultCancelled():
return cancelled();case _CameraGalleryResultFailure():
return failure(_that.errorKey,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String imagePath)?  success,TResult? Function()?  cancelled,TResult? Function( String errorKey,  String? message)?  failure,}) {final _that = this;
switch (_that) {
case _CameraGalleryResultSuccess() when success != null:
return success(_that.imagePath);case _CameraGalleryResultCancelled() when cancelled != null:
return cancelled();case _CameraGalleryResultFailure() when failure != null:
return failure(_that.errorKey,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CameraGalleryResultSuccess extends CameraGalleryResult {
  const _CameraGalleryResultSuccess(this.imagePath): super._();
  

 final  String imagePath;

/// Create a copy of CameraGalleryResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraGalleryResultSuccessCopyWith<_CameraGalleryResultSuccess> get copyWith => __$CameraGalleryResultSuccessCopyWithImpl<_CameraGalleryResultSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraGalleryResultSuccess&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}


@override
int get hashCode => Object.hash(runtimeType,imagePath);

@override
String toString() {
  return 'CameraGalleryResult.success(imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$CameraGalleryResultSuccessCopyWith<$Res> implements $CameraGalleryResultCopyWith<$Res> {
  factory _$CameraGalleryResultSuccessCopyWith(_CameraGalleryResultSuccess value, $Res Function(_CameraGalleryResultSuccess) _then) = __$CameraGalleryResultSuccessCopyWithImpl;
@useResult
$Res call({
 String imagePath
});




}
/// @nodoc
class __$CameraGalleryResultSuccessCopyWithImpl<$Res>
    implements _$CameraGalleryResultSuccessCopyWith<$Res> {
  __$CameraGalleryResultSuccessCopyWithImpl(this._self, this._then);

  final _CameraGalleryResultSuccess _self;
  final $Res Function(_CameraGalleryResultSuccess) _then;

/// Create a copy of CameraGalleryResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagePath = null,}) {
  return _then(_CameraGalleryResultSuccess(
null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CameraGalleryResultCancelled extends CameraGalleryResult {
  const _CameraGalleryResultCancelled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraGalleryResultCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CameraGalleryResult.cancelled()';
}


}




/// @nodoc


class _CameraGalleryResultFailure extends CameraGalleryResult {
  const _CameraGalleryResultFailure({required this.errorKey, this.message}): super._();
  

 final  String errorKey;
 final  String? message;

/// Create a copy of CameraGalleryResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CameraGalleryResultFailureCopyWith<_CameraGalleryResultFailure> get copyWith => __$CameraGalleryResultFailureCopyWithImpl<_CameraGalleryResultFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CameraGalleryResultFailure&&(identical(other.errorKey, errorKey) || other.errorKey == errorKey)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,errorKey,message);

@override
String toString() {
  return 'CameraGalleryResult.failure(errorKey: $errorKey, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CameraGalleryResultFailureCopyWith<$Res> implements $CameraGalleryResultCopyWith<$Res> {
  factory _$CameraGalleryResultFailureCopyWith(_CameraGalleryResultFailure value, $Res Function(_CameraGalleryResultFailure) _then) = __$CameraGalleryResultFailureCopyWithImpl;
@useResult
$Res call({
 String errorKey, String? message
});




}
/// @nodoc
class __$CameraGalleryResultFailureCopyWithImpl<$Res>
    implements _$CameraGalleryResultFailureCopyWith<$Res> {
  __$CameraGalleryResultFailureCopyWithImpl(this._self, this._then);

  final _CameraGalleryResultFailure _self;
  final $Res Function(_CameraGalleryResultFailure) _then;

/// Create a copy of CameraGalleryResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorKey = null,Object? message = freezed,}) {
  return _then(_CameraGalleryResultFailure(
errorKey: null == errorKey ? _self.errorKey : errorKey // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
