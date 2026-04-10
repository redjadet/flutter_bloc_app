// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_content_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoContentItem {

 String get contentId; String get title; StaffDemoContentType get type; String get storagePath; bool get isPublished;
/// Create a copy of StaffDemoContentItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoContentItemCopyWith<StaffDemoContentItem> get copyWith => _$StaffDemoContentItemCopyWithImpl<StaffDemoContentItem>(this as StaffDemoContentItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoContentItem&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished));
}


@override
int get hashCode => Object.hash(runtimeType,contentId,title,type,storagePath,isPublished);

@override
String toString() {
  return 'StaffDemoContentItem(contentId: $contentId, title: $title, type: $type, storagePath: $storagePath, isPublished: $isPublished)';
}


}

/// @nodoc
abstract mixin class $StaffDemoContentItemCopyWith<$Res>  {
  factory $StaffDemoContentItemCopyWith(StaffDemoContentItem value, $Res Function(StaffDemoContentItem) _then) = _$StaffDemoContentItemCopyWithImpl;
@useResult
$Res call({
 String contentId, String title, StaffDemoContentType type, String storagePath, bool isPublished
});




}
/// @nodoc
class _$StaffDemoContentItemCopyWithImpl<$Res>
    implements $StaffDemoContentItemCopyWith<$Res> {
  _$StaffDemoContentItemCopyWithImpl(this._self, this._then);

  final StaffDemoContentItem _self;
  final $Res Function(StaffDemoContentItem) _then;

/// Create a copy of StaffDemoContentItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentId = null,Object? title = null,Object? type = null,Object? storagePath = null,Object? isPublished = null,}) {
  return _then(_self.copyWith(
contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StaffDemoContentType,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoContentItem].
extension StaffDemoContentItemPatterns on StaffDemoContentItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoContentItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoContentItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoContentItem value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoContentItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoContentItem value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoContentItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contentId,  String title,  StaffDemoContentType type,  String storagePath,  bool isPublished)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoContentItem() when $default != null:
return $default(_that.contentId,_that.title,_that.type,_that.storagePath,_that.isPublished);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contentId,  String title,  StaffDemoContentType type,  String storagePath,  bool isPublished)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoContentItem():
return $default(_that.contentId,_that.title,_that.type,_that.storagePath,_that.isPublished);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contentId,  String title,  StaffDemoContentType type,  String storagePath,  bool isPublished)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoContentItem() when $default != null:
return $default(_that.contentId,_that.title,_that.type,_that.storagePath,_that.isPublished);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoContentItem implements StaffDemoContentItem {
  const _StaffDemoContentItem({required this.contentId, required this.title, required this.type, required this.storagePath, required this.isPublished});
  

@override final  String contentId;
@override final  String title;
@override final  StaffDemoContentType type;
@override final  String storagePath;
@override final  bool isPublished;

/// Create a copy of StaffDemoContentItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoContentItemCopyWith<_StaffDemoContentItem> get copyWith => __$StaffDemoContentItemCopyWithImpl<_StaffDemoContentItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoContentItem&&(identical(other.contentId, contentId) || other.contentId == contentId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished));
}


@override
int get hashCode => Object.hash(runtimeType,contentId,title,type,storagePath,isPublished);

@override
String toString() {
  return 'StaffDemoContentItem(contentId: $contentId, title: $title, type: $type, storagePath: $storagePath, isPublished: $isPublished)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoContentItemCopyWith<$Res> implements $StaffDemoContentItemCopyWith<$Res> {
  factory _$StaffDemoContentItemCopyWith(_StaffDemoContentItem value, $Res Function(_StaffDemoContentItem) _then) = __$StaffDemoContentItemCopyWithImpl;
@override @useResult
$Res call({
 String contentId, String title, StaffDemoContentType type, String storagePath, bool isPublished
});




}
/// @nodoc
class __$StaffDemoContentItemCopyWithImpl<$Res>
    implements _$StaffDemoContentItemCopyWith<$Res> {
  __$StaffDemoContentItemCopyWithImpl(this._self, this._then);

  final _StaffDemoContentItem _self;
  final $Res Function(_StaffDemoContentItem) _then;

/// Create a copy of StaffDemoContentItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentId = null,Object? title = null,Object? type = null,Object? storagePath = null,Object? isPublished = null,}) {
  return _then(_StaffDemoContentItem(
contentId: null == contentId ? _self.contentId : contentId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StaffDemoContentType,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
