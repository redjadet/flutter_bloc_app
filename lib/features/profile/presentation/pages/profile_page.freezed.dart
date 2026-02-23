// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileBodyData {

 bool get isLoading; bool get hasError; bool get hasUser; ProfileUser? get user;
/// Create a copy of _ProfileBodyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileBodyDataCopyWith<_ProfileBodyData> get copyWith => __$ProfileBodyDataCopyWithImpl<_ProfileBodyData>(this as _ProfileBodyData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileBodyData&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.hasUser, hasUser) || other.hasUser == hasUser)&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,hasError,hasUser,user);

@override
String toString() {
  return '_ProfileBodyData(isLoading: $isLoading, hasError: $hasError, hasUser: $hasUser, user: $user)';
}


}

/// @nodoc
abstract mixin class _$ProfileBodyDataCopyWith<$Res>  {
  factory _$ProfileBodyDataCopyWith(_ProfileBodyData value, $Res Function(_ProfileBodyData) _then) = __$ProfileBodyDataCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool hasError, bool hasUser, ProfileUser? user
});


$ProfileUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$ProfileBodyDataCopyWithImpl<$Res>
    implements _$ProfileBodyDataCopyWith<$Res> {
  __$ProfileBodyDataCopyWithImpl(this._self, this._then);

  final _ProfileBodyData _self;
  final $Res Function(_ProfileBodyData) _then;

/// Create a copy of _ProfileBodyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? hasError = null,Object? hasUser = null,Object? user = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,hasUser: null == hasUser ? _self.hasUser : hasUser // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ProfileUser?,
  ));
}
/// Create a copy of _ProfileBodyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [_ProfileBodyData].
extension _ProfileBodyDataPatterns on _ProfileBodyData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __ProfileBodyData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __ProfileBodyData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __ProfileBodyData value)  $default,){
final _that = this;
switch (_that) {
case __ProfileBodyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __ProfileBodyData value)?  $default,){
final _that = this;
switch (_that) {
case __ProfileBodyData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool hasError,  bool hasUser,  ProfileUser? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __ProfileBodyData() when $default != null:
return $default(_that.isLoading,_that.hasError,_that.hasUser,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool hasError,  bool hasUser,  ProfileUser? user)  $default,) {final _that = this;
switch (_that) {
case __ProfileBodyData():
return $default(_that.isLoading,_that.hasError,_that.hasUser,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool hasError,  bool hasUser,  ProfileUser? user)?  $default,) {final _that = this;
switch (_that) {
case __ProfileBodyData() when $default != null:
return $default(_that.isLoading,_that.hasError,_that.hasUser,_that.user);case _:
  return null;

}
}

}

/// @nodoc


class __ProfileBodyData implements _ProfileBodyData {
  const __ProfileBodyData({required this.isLoading, required this.hasError, required this.hasUser, required this.user});
  

@override final  bool isLoading;
@override final  bool hasError;
@override final  bool hasUser;
@override final  ProfileUser? user;

/// Create a copy of _ProfileBodyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_ProfileBodyDataCopyWith<__ProfileBodyData> get copyWith => __$_ProfileBodyDataCopyWithImpl<__ProfileBodyData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __ProfileBodyData&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.hasUser, hasUser) || other.hasUser == hasUser)&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,hasError,hasUser,user);

@override
String toString() {
  return '_ProfileBodyData(isLoading: $isLoading, hasError: $hasError, hasUser: $hasUser, user: $user)';
}


}

/// @nodoc
abstract mixin class _$_ProfileBodyDataCopyWith<$Res> implements _$ProfileBodyDataCopyWith<$Res> {
  factory _$_ProfileBodyDataCopyWith(__ProfileBodyData value, $Res Function(__ProfileBodyData) _then) = __$_ProfileBodyDataCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool hasError, bool hasUser, ProfileUser? user
});


@override $ProfileUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$_ProfileBodyDataCopyWithImpl<$Res>
    implements _$_ProfileBodyDataCopyWith<$Res> {
  __$_ProfileBodyDataCopyWithImpl(this._self, this._then);

  final __ProfileBodyData _self;
  final $Res Function(__ProfileBodyData) _then;

/// Create a copy of _ProfileBodyData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? hasError = null,Object? hasUser = null,Object? user = freezed,}) {
  return _then(__ProfileBodyData(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,hasUser: null == hasUser ? _self.hasUser : hasUser // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ProfileUser?,
  ));
}

/// Create a copy of _ProfileBodyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
