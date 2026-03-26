// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iap_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IapProduct {

 String get id; String get title; String get description; String get priceLabel; IapProductType get type;
/// Create a copy of IapProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IapProductCopyWith<IapProduct> get copyWith => _$IapProductCopyWithImpl<IapProduct>(this as IapProduct, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IapProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceLabel, priceLabel) || other.priceLabel == priceLabel)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,priceLabel,type);

@override
String toString() {
  return 'IapProduct(id: $id, title: $title, description: $description, priceLabel: $priceLabel, type: $type)';
}


}

/// @nodoc
abstract mixin class $IapProductCopyWith<$Res>  {
  factory $IapProductCopyWith(IapProduct value, $Res Function(IapProduct) _then) = _$IapProductCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String priceLabel, IapProductType type
});




}
/// @nodoc
class _$IapProductCopyWithImpl<$Res>
    implements $IapProductCopyWith<$Res> {
  _$IapProductCopyWithImpl(this._self, this._then);

  final IapProduct _self;
  final $Res Function(IapProduct) _then;

/// Create a copy of IapProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? priceLabel = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceLabel: null == priceLabel ? _self.priceLabel : priceLabel // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IapProductType,
  ));
}

}


/// Adds pattern-matching-related methods to [IapProduct].
extension IapProductPatterns on IapProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IapProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IapProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IapProduct value)  $default,){
final _that = this;
switch (_that) {
case _IapProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IapProduct value)?  $default,){
final _that = this;
switch (_that) {
case _IapProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String priceLabel,  IapProductType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IapProduct() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.priceLabel,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String priceLabel,  IapProductType type)  $default,) {final _that = this;
switch (_that) {
case _IapProduct():
return $default(_that.id,_that.title,_that.description,_that.priceLabel,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String priceLabel,  IapProductType type)?  $default,) {final _that = this;
switch (_that) {
case _IapProduct() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.priceLabel,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _IapProduct implements IapProduct {
  const _IapProduct({required this.id, required this.title, required this.description, required this.priceLabel, required this.type});
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String priceLabel;
@override final  IapProductType type;

/// Create a copy of IapProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IapProductCopyWith<_IapProduct> get copyWith => __$IapProductCopyWithImpl<_IapProduct>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IapProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceLabel, priceLabel) || other.priceLabel == priceLabel)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,priceLabel,type);

@override
String toString() {
  return 'IapProduct(id: $id, title: $title, description: $description, priceLabel: $priceLabel, type: $type)';
}


}

/// @nodoc
abstract mixin class _$IapProductCopyWith<$Res> implements $IapProductCopyWith<$Res> {
  factory _$IapProductCopyWith(_IapProduct value, $Res Function(_IapProduct) _then) = __$IapProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String priceLabel, IapProductType type
});




}
/// @nodoc
class __$IapProductCopyWithImpl<$Res>
    implements _$IapProductCopyWith<$Res> {
  __$IapProductCopyWithImpl(this._self, this._then);

  final _IapProduct _self;
  final $Res Function(_IapProduct) _then;

/// Create a copy of IapProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? priceLabel = null,Object? type = null,}) {
  return _then(_IapProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceLabel: null == priceLabel ? _self.priceLabel : priceLabel // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IapProductType,
  ));
}


}

// dart format on
