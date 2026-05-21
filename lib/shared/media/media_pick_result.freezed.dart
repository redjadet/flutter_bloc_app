// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_pick_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaPickResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaPickResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MediaPickResult()';
}


}

/// @nodoc
class $MediaPickResultCopyWith<$Res>  {
$MediaPickResultCopyWith(MediaPickResult _, $Res Function(MediaPickResult) __);
}


/// Adds pattern-matching-related methods to [MediaPickResult].
extension MediaPickResultPatterns on MediaPickResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MediaPickResultSuccess value)?  success,TResult Function( _MediaPickResultCancelled value)?  cancelled,TResult Function( _MediaPickResultFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaPickResultSuccess() when success != null:
return success(_that);case _MediaPickResultCancelled() when cancelled != null:
return cancelled(_that);case _MediaPickResultFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MediaPickResultSuccess value)  success,required TResult Function( _MediaPickResultCancelled value)  cancelled,required TResult Function( _MediaPickResultFailure value)  failure,}){
final _that = this;
switch (_that) {
case _MediaPickResultSuccess():
return success(_that);case _MediaPickResultCancelled():
return cancelled(_that);case _MediaPickResultFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MediaPickResultSuccess value)?  success,TResult? Function( _MediaPickResultCancelled value)?  cancelled,TResult? Function( _MediaPickResultFailure value)?  failure,}){
final _that = this;
switch (_that) {
case _MediaPickResultSuccess() when success != null:
return success(_that);case _MediaPickResultCancelled() when cancelled != null:
return cancelled(_that);case _MediaPickResultFailure() when failure != null:
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
case _MediaPickResultSuccess() when success != null:
return success(_that.imagePath);case _MediaPickResultCancelled() when cancelled != null:
return cancelled();case _MediaPickResultFailure() when failure != null:
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
case _MediaPickResultSuccess():
return success(_that.imagePath);case _MediaPickResultCancelled():
return cancelled();case _MediaPickResultFailure():
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
case _MediaPickResultSuccess() when success != null:
return success(_that.imagePath);case _MediaPickResultCancelled() when cancelled != null:
return cancelled();case _MediaPickResultFailure() when failure != null:
return failure(_that.errorKey,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _MediaPickResultSuccess extends MediaPickResult {
  const _MediaPickResultSuccess(this.imagePath): super._();
  

 final  String imagePath;

/// Create a copy of MediaPickResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaPickResultSuccessCopyWith<_MediaPickResultSuccess> get copyWith => __$MediaPickResultSuccessCopyWithImpl<_MediaPickResultSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaPickResultSuccess&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}


@override
int get hashCode => Object.hash(runtimeType,imagePath);

@override
String toString() {
  return 'MediaPickResult.success(imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$MediaPickResultSuccessCopyWith<$Res> implements $MediaPickResultCopyWith<$Res> {
  factory _$MediaPickResultSuccessCopyWith(_MediaPickResultSuccess value, $Res Function(_MediaPickResultSuccess) _then) = __$MediaPickResultSuccessCopyWithImpl;
@useResult
$Res call({
 String imagePath
});




}
/// @nodoc
class __$MediaPickResultSuccessCopyWithImpl<$Res>
    implements _$MediaPickResultSuccessCopyWith<$Res> {
  __$MediaPickResultSuccessCopyWithImpl(this._self, this._then);

  final _MediaPickResultSuccess _self;
  final $Res Function(_MediaPickResultSuccess) _then;

/// Create a copy of MediaPickResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagePath = null,}) {
  return _then(_MediaPickResultSuccess(
null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _MediaPickResultCancelled extends MediaPickResult {
  const _MediaPickResultCancelled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaPickResultCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MediaPickResult.cancelled()';
}


}




/// @nodoc


class _MediaPickResultFailure extends MediaPickResult {
  const _MediaPickResultFailure({required this.errorKey, this.message}): super._();
  

 final  String errorKey;
 final  String? message;

/// Create a copy of MediaPickResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaPickResultFailureCopyWith<_MediaPickResultFailure> get copyWith => __$MediaPickResultFailureCopyWithImpl<_MediaPickResultFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaPickResultFailure&&(identical(other.errorKey, errorKey) || other.errorKey == errorKey)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,errorKey,message);

@override
String toString() {
  return 'MediaPickResult.failure(errorKey: $errorKey, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MediaPickResultFailureCopyWith<$Res> implements $MediaPickResultCopyWith<$Res> {
  factory _$MediaPickResultFailureCopyWith(_MediaPickResultFailure value, $Res Function(_MediaPickResultFailure) _then) = __$MediaPickResultFailureCopyWithImpl;
@useResult
$Res call({
 String errorKey, String? message
});




}
/// @nodoc
class __$MediaPickResultFailureCopyWithImpl<$Res>
    implements _$MediaPickResultFailureCopyWith<$Res> {
  __$MediaPickResultFailureCopyWithImpl(this._self, this._then);

  final _MediaPickResultFailure _self;
  final $Res Function(_MediaPickResultFailure) _then;

/// Create a copy of MediaPickResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorKey = null,Object? message = freezed,}) {
  return _then(_MediaPickResultFailure(
errorKey: null == errorKey ? _self.errorKey : errorKey // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
