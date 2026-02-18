// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nft_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NftMetadata {

 String get tokenId; String get contractAddress; String get name; String? get imageUrl;
/// Create a copy of NftMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NftMetadataCopyWith<NftMetadata> get copyWith => _$NftMetadataCopyWithImpl<NftMetadata>(this as NftMetadata, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NftMetadata&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,tokenId,contractAddress,name,imageUrl);

@override
String toString() {
  return 'NftMetadata(tokenId: $tokenId, contractAddress: $contractAddress, name: $name, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $NftMetadataCopyWith<$Res>  {
  factory $NftMetadataCopyWith(NftMetadata value, $Res Function(NftMetadata) _then) = _$NftMetadataCopyWithImpl;
@useResult
$Res call({
 String tokenId, String contractAddress, String name, String? imageUrl
});




}
/// @nodoc
class _$NftMetadataCopyWithImpl<$Res>
    implements $NftMetadataCopyWith<$Res> {
  _$NftMetadataCopyWithImpl(this._self, this._then);

  final NftMetadata _self;
  final $Res Function(NftMetadata) _then;

/// Create a copy of NftMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokenId = null,Object? contractAddress = null,Object? name = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String,contractAddress: null == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NftMetadata].
extension NftMetadataPatterns on NftMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NftMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NftMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NftMetadata value)  $default,){
final _that = this;
switch (_that) {
case _NftMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NftMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _NftMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tokenId,  String contractAddress,  String name,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NftMetadata() when $default != null:
return $default(_that.tokenId,_that.contractAddress,_that.name,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tokenId,  String contractAddress,  String name,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _NftMetadata():
return $default(_that.tokenId,_that.contractAddress,_that.name,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tokenId,  String contractAddress,  String name,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _NftMetadata() when $default != null:
return $default(_that.tokenId,_that.contractAddress,_that.name,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _NftMetadata implements NftMetadata {
  const _NftMetadata({required this.tokenId, required this.contractAddress, required this.name, this.imageUrl});
  

@override final  String tokenId;
@override final  String contractAddress;
@override final  String name;
@override final  String? imageUrl;

/// Create a copy of NftMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NftMetadataCopyWith<_NftMetadata> get copyWith => __$NftMetadataCopyWithImpl<_NftMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NftMetadata&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.contractAddress, contractAddress) || other.contractAddress == contractAddress)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,tokenId,contractAddress,name,imageUrl);

@override
String toString() {
  return 'NftMetadata(tokenId: $tokenId, contractAddress: $contractAddress, name: $name, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$NftMetadataCopyWith<$Res> implements $NftMetadataCopyWith<$Res> {
  factory _$NftMetadataCopyWith(_NftMetadata value, $Res Function(_NftMetadata) _then) = __$NftMetadataCopyWithImpl;
@override @useResult
$Res call({
 String tokenId, String contractAddress, String name, String? imageUrl
});




}
/// @nodoc
class __$NftMetadataCopyWithImpl<$Res>
    implements _$NftMetadataCopyWith<$Res> {
  __$NftMetadataCopyWithImpl(this._self, this._then);

  final _NftMetadata _self;
  final $Res Function(_NftMetadata) _then;

/// Create a copy of NftMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokenId = null,Object? contractAddress = null,Object? name = null,Object? imageUrl = freezed,}) {
  return _then(_NftMetadata(
tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String,contractAddress: null == contractAddress ? _self.contractAddress : contractAddress // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
