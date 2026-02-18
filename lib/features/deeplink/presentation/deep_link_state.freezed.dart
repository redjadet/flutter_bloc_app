// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deep_link_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeepLinkState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeepLinkState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeepLinkState()';
}


}

/// @nodoc
class $DeepLinkStateCopyWith<$Res>  {
$DeepLinkStateCopyWith(DeepLinkState _, $Res Function(DeepLinkState) __);
}


/// Adds pattern-matching-related methods to [DeepLinkState].
extension DeepLinkStatePatterns on DeepLinkState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DeepLinkIdle value)?  idle,TResult Function( DeepLinkLoading value)?  loading,TResult Function( DeepLinkNavigate value)?  navigate,TResult Function( DeepLinkError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DeepLinkIdle() when idle != null:
return idle(_that);case DeepLinkLoading() when loading != null:
return loading(_that);case DeepLinkNavigate() when navigate != null:
return navigate(_that);case DeepLinkError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DeepLinkIdle value)  idle,required TResult Function( DeepLinkLoading value)  loading,required TResult Function( DeepLinkNavigate value)  navigate,required TResult Function( DeepLinkError value)  error,}){
final _that = this;
switch (_that) {
case DeepLinkIdle():
return idle(_that);case DeepLinkLoading():
return loading(_that);case DeepLinkNavigate():
return navigate(_that);case DeepLinkError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DeepLinkIdle value)?  idle,TResult? Function( DeepLinkLoading value)?  loading,TResult? Function( DeepLinkNavigate value)?  navigate,TResult? Function( DeepLinkError value)?  error,}){
final _that = this;
switch (_that) {
case DeepLinkIdle() when idle != null:
return idle(_that);case DeepLinkLoading() when loading != null:
return loading(_that);case DeepLinkNavigate() when navigate != null:
return navigate(_that);case DeepLinkError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( DeepLinkTarget target,  DeepLinkOrigin origin)?  navigate,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DeepLinkIdle() when idle != null:
return idle();case DeepLinkLoading() when loading != null:
return loading();case DeepLinkNavigate() when navigate != null:
return navigate(_that.target,_that.origin);case DeepLinkError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( DeepLinkTarget target,  DeepLinkOrigin origin)  navigate,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DeepLinkIdle():
return idle();case DeepLinkLoading():
return loading();case DeepLinkNavigate():
return navigate(_that.target,_that.origin);case DeepLinkError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( DeepLinkTarget target,  DeepLinkOrigin origin)?  navigate,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DeepLinkIdle() when idle != null:
return idle();case DeepLinkLoading() when loading != null:
return loading();case DeepLinkNavigate() when navigate != null:
return navigate(_that.target,_that.origin);case DeepLinkError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DeepLinkIdle implements DeepLinkState {
  const DeepLinkIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeepLinkIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeepLinkState.idle()';
}


}




/// @nodoc


class DeepLinkLoading implements DeepLinkState {
  const DeepLinkLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeepLinkLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DeepLinkState.loading()';
}


}




/// @nodoc


class DeepLinkNavigate implements DeepLinkState {
  const DeepLinkNavigate(this.target, this.origin);
  

 final  DeepLinkTarget target;
 final  DeepLinkOrigin origin;

/// Create a copy of DeepLinkState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeepLinkNavigateCopyWith<DeepLinkNavigate> get copyWith => _$DeepLinkNavigateCopyWithImpl<DeepLinkNavigate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeepLinkNavigate&&(identical(other.target, target) || other.target == target)&&(identical(other.origin, origin) || other.origin == origin));
}


@override
int get hashCode => Object.hash(runtimeType,target,origin);

@override
String toString() {
  return 'DeepLinkState.navigate(target: $target, origin: $origin)';
}


}

/// @nodoc
abstract mixin class $DeepLinkNavigateCopyWith<$Res> implements $DeepLinkStateCopyWith<$Res> {
  factory $DeepLinkNavigateCopyWith(DeepLinkNavigate value, $Res Function(DeepLinkNavigate) _then) = _$DeepLinkNavigateCopyWithImpl;
@useResult
$Res call({
 DeepLinkTarget target, DeepLinkOrigin origin
});




}
/// @nodoc
class _$DeepLinkNavigateCopyWithImpl<$Res>
    implements $DeepLinkNavigateCopyWith<$Res> {
  _$DeepLinkNavigateCopyWithImpl(this._self, this._then);

  final DeepLinkNavigate _self;
  final $Res Function(DeepLinkNavigate) _then;

/// Create a copy of DeepLinkState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? target = null,Object? origin = null,}) {
  return _then(DeepLinkNavigate(
null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as DeepLinkTarget,null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as DeepLinkOrigin,
  ));
}


}

/// @nodoc


class DeepLinkError implements DeepLinkState {
  const DeepLinkError(this.message);
  

 final  String message;

/// Create a copy of DeepLinkState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeepLinkErrorCopyWith<DeepLinkError> get copyWith => _$DeepLinkErrorCopyWithImpl<DeepLinkError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeepLinkError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DeepLinkState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DeepLinkErrorCopyWith<$Res> implements $DeepLinkStateCopyWith<$Res> {
  factory $DeepLinkErrorCopyWith(DeepLinkError value, $Res Function(DeepLinkError) _then) = _$DeepLinkErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DeepLinkErrorCopyWithImpl<$Res>
    implements $DeepLinkErrorCopyWith<$Res> {
  _$DeepLinkErrorCopyWithImpl(this._self, this._then);

  final DeepLinkError _self;
  final $Res Function(DeepLinkError) _then;

/// Create a copy of DeepLinkState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DeepLinkError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
