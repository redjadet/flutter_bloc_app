// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileUser {

 String get name; String get location; String get avatarUrl; List<ProfileImage> get galleryImages;
/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUserCopyWith<ProfileUser> get copyWith => _$ProfileUserCopyWithImpl<ProfileUser>(this as ProfileUser, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUser&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other.galleryImages, galleryImages));
}


@override
int get hashCode => Object.hash(runtimeType,name,location,avatarUrl,const DeepCollectionEquality().hash(galleryImages));

@override
String toString() {
  return 'ProfileUser(name: $name, location: $location, avatarUrl: $avatarUrl, galleryImages: $galleryImages)';
}


}

/// @nodoc
abstract mixin class $ProfileUserCopyWith<$Res>  {
  factory $ProfileUserCopyWith(ProfileUser value, $Res Function(ProfileUser) _then) = _$ProfileUserCopyWithImpl;
@useResult
$Res call({
 String name, String location, String avatarUrl, List<ProfileImage> galleryImages
});




}
/// @nodoc
class _$ProfileUserCopyWithImpl<$Res>
    implements $ProfileUserCopyWith<$Res> {
  _$ProfileUserCopyWithImpl(this._self, this._then);

  final ProfileUser _self;
  final $Res Function(ProfileUser) _then;

/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? location = null,Object? avatarUrl = null,Object? galleryImages = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,galleryImages: null == galleryImages ? _self.galleryImages : galleryImages // ignore: cast_nullable_to_non_nullable
as List<ProfileImage>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileUser].
extension ProfileUserPatterns on ProfileUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileUser value)  $default,){
final _that = this;
switch (_that) {
case _ProfileUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileUser value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String location,  String avatarUrl,  List<ProfileImage> galleryImages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
return $default(_that.name,_that.location,_that.avatarUrl,_that.galleryImages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String location,  String avatarUrl,  List<ProfileImage> galleryImages)  $default,) {final _that = this;
switch (_that) {
case _ProfileUser():
return $default(_that.name,_that.location,_that.avatarUrl,_that.galleryImages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String location,  String avatarUrl,  List<ProfileImage> galleryImages)?  $default,) {final _that = this;
switch (_that) {
case _ProfileUser() when $default != null:
return $default(_that.name,_that.location,_that.avatarUrl,_that.galleryImages);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileUser implements ProfileUser {
  const _ProfileUser({required this.name, required this.location, required this.avatarUrl, required final  List<ProfileImage> galleryImages}): _galleryImages = galleryImages;
  

@override final  String name;
@override final  String location;
@override final  String avatarUrl;
 final  List<ProfileImage> _galleryImages;
@override List<ProfileImage> get galleryImages {
  if (_galleryImages is EqualUnmodifiableListView) return _galleryImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_galleryImages);
}


/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileUserCopyWith<_ProfileUser> get copyWith => __$ProfileUserCopyWithImpl<_ProfileUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileUser&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other._galleryImages, _galleryImages));
}


@override
int get hashCode => Object.hash(runtimeType,name,location,avatarUrl,const DeepCollectionEquality().hash(_galleryImages));

@override
String toString() {
  return 'ProfileUser(name: $name, location: $location, avatarUrl: $avatarUrl, galleryImages: $galleryImages)';
}


}

/// @nodoc
abstract mixin class _$ProfileUserCopyWith<$Res> implements $ProfileUserCopyWith<$Res> {
  factory _$ProfileUserCopyWith(_ProfileUser value, $Res Function(_ProfileUser) _then) = __$ProfileUserCopyWithImpl;
@override @useResult
$Res call({
 String name, String location, String avatarUrl, List<ProfileImage> galleryImages
});




}
/// @nodoc
class __$ProfileUserCopyWithImpl<$Res>
    implements _$ProfileUserCopyWith<$Res> {
  __$ProfileUserCopyWithImpl(this._self, this._then);

  final _ProfileUser _self;
  final $Res Function(_ProfileUser) _then;

/// Create a copy of ProfileUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? location = null,Object? avatarUrl = null,Object? galleryImages = null,}) {
  return _then(_ProfileUser(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,galleryImages: null == galleryImages ? _self._galleryImages : galleryImages // ignore: cast_nullable_to_non_nullable
as List<ProfileImage>,
  ));
}


}

/// @nodoc
mixin _$ProfileImage {

 String get url; double get aspectRatio;
/// Create a copy of ProfileImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileImageCopyWith<ProfileImage> get copyWith => _$ProfileImageCopyWithImpl<ProfileImage>(this as ProfileImage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileImage&&(identical(other.url, url) || other.url == url)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}


@override
int get hashCode => Object.hash(runtimeType,url,aspectRatio);

@override
String toString() {
  return 'ProfileImage(url: $url, aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class $ProfileImageCopyWith<$Res>  {
  factory $ProfileImageCopyWith(ProfileImage value, $Res Function(ProfileImage) _then) = _$ProfileImageCopyWithImpl;
@useResult
$Res call({
 String url, double aspectRatio
});




}
/// @nodoc
class _$ProfileImageCopyWithImpl<$Res>
    implements $ProfileImageCopyWith<$Res> {
  _$ProfileImageCopyWithImpl(this._self, this._then);

  final ProfileImage _self;
  final $Res Function(ProfileImage) _then;

/// Create a copy of ProfileImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? aspectRatio = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileImage].
extension ProfileImagePatterns on ProfileImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileImage value)  $default,){
final _that = this;
switch (_that) {
case _ProfileImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileImage value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  double aspectRatio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileImage() when $default != null:
return $default(_that.url,_that.aspectRatio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  double aspectRatio)  $default,) {final _that = this;
switch (_that) {
case _ProfileImage():
return $default(_that.url,_that.aspectRatio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  double aspectRatio)?  $default,) {final _that = this;
switch (_that) {
case _ProfileImage() when $default != null:
return $default(_that.url,_that.aspectRatio);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileImage implements ProfileImage {
  const _ProfileImage({required this.url, required this.aspectRatio});
  

@override final  String url;
@override final  double aspectRatio;

/// Create a copy of ProfileImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileImageCopyWith<_ProfileImage> get copyWith => __$ProfileImageCopyWithImpl<_ProfileImage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileImage&&(identical(other.url, url) || other.url == url)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}


@override
int get hashCode => Object.hash(runtimeType,url,aspectRatio);

@override
String toString() {
  return 'ProfileImage(url: $url, aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class _$ProfileImageCopyWith<$Res> implements $ProfileImageCopyWith<$Res> {
  factory _$ProfileImageCopyWith(_ProfileImage value, $Res Function(_ProfileImage) _then) = __$ProfileImageCopyWithImpl;
@override @useResult
$Res call({
 String url, double aspectRatio
});




}
/// @nodoc
class __$ProfileImageCopyWithImpl<$Res>
    implements _$ProfileImageCopyWith<$Res> {
  __$ProfileImageCopyWithImpl(this._self, this._then);

  final _ProfileImage _self;
  final $Res Function(_ProfileImage) _then;

/// Create a copy of ProfileImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? aspectRatio = null,}) {
  return _then(_ProfileImage(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
