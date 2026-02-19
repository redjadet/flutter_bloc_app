// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scape.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Scape {

 String get id; String get name; String get imageUrl; Duration get duration; int get assetCount; bool get isFavorite;
/// Create a copy of Scape
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScapeCopyWith<Scape> get copyWith => _$ScapeCopyWithImpl<Scape>(this as Scape, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scape&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.assetCount, assetCount) || other.assetCount == assetCount)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,imageUrl,duration,assetCount,isFavorite);

@override
String toString() {
  return 'Scape(id: $id, name: $name, imageUrl: $imageUrl, duration: $duration, assetCount: $assetCount, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class $ScapeCopyWith<$Res>  {
  factory $ScapeCopyWith(Scape value, $Res Function(Scape) _then) = _$ScapeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String imageUrl, Duration duration, int assetCount, bool isFavorite
});




}
/// @nodoc
class _$ScapeCopyWithImpl<$Res>
    implements $ScapeCopyWith<$Res> {
  _$ScapeCopyWithImpl(this._self, this._then);

  final Scape _self;
  final $Res Function(Scape) _then;

/// Create a copy of Scape
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? imageUrl = null,Object? duration = null,Object? assetCount = null,Object? isFavorite = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,assetCount: null == assetCount ? _self.assetCount : assetCount // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Scape].
extension ScapePatterns on Scape {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scape value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scape() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scape value)  $default,){
final _that = this;
switch (_that) {
case _Scape():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scape value)?  $default,){
final _that = this;
switch (_that) {
case _Scape() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String imageUrl,  Duration duration,  int assetCount,  bool isFavorite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scape() when $default != null:
return $default(_that.id,_that.name,_that.imageUrl,_that.duration,_that.assetCount,_that.isFavorite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String imageUrl,  Duration duration,  int assetCount,  bool isFavorite)  $default,) {final _that = this;
switch (_that) {
case _Scape():
return $default(_that.id,_that.name,_that.imageUrl,_that.duration,_that.assetCount,_that.isFavorite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String imageUrl,  Duration duration,  int assetCount,  bool isFavorite)?  $default,) {final _that = this;
switch (_that) {
case _Scape() when $default != null:
return $default(_that.id,_that.name,_that.imageUrl,_that.duration,_that.assetCount,_that.isFavorite);case _:
  return null;

}
}

}

/// @nodoc


class _Scape extends Scape {
  const _Scape({required this.id, required this.name, required this.imageUrl, required this.duration, required this.assetCount, this.isFavorite = false}): super._();
  

@override final  String id;
@override final  String name;
@override final  String imageUrl;
@override final  Duration duration;
@override final  int assetCount;
@override@JsonKey() final  bool isFavorite;

/// Create a copy of Scape
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScapeCopyWith<_Scape> get copyWith => __$ScapeCopyWithImpl<_Scape>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scape&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.assetCount, assetCount) || other.assetCount == assetCount)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,imageUrl,duration,assetCount,isFavorite);

@override
String toString() {
  return 'Scape(id: $id, name: $name, imageUrl: $imageUrl, duration: $duration, assetCount: $assetCount, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class _$ScapeCopyWith<$Res> implements $ScapeCopyWith<$Res> {
  factory _$ScapeCopyWith(_Scape value, $Res Function(_Scape) _then) = __$ScapeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String imageUrl, Duration duration, int assetCount, bool isFavorite
});




}
/// @nodoc
class __$ScapeCopyWithImpl<$Res>
    implements _$ScapeCopyWith<$Res> {
  __$ScapeCopyWithImpl(this._self, this._then);

  final _Scape _self;
  final $Res Function(_Scape) _then;

/// Create a copy of Scape
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? imageUrl = null,Object? duration = null,Object? assetCount = null,Object? isFavorite = null,}) {
  return _then(_Scape(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,assetCount: null == assetCount ? _self.assetCount : assetCount // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
