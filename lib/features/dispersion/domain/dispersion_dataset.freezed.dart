// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispersion_dataset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DispersionDataset {

 String get id; String get name; List<String> get groupIds; DateTime get createdAt; bool get isDerived; List<String> get sourceDatasetIds; int get pointCount; Map<String, String> get metadata;
/// Create a copy of DispersionDataset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispersionDatasetCopyWith<DispersionDataset> get copyWith => _$DispersionDatasetCopyWithImpl<DispersionDataset>(this as DispersionDataset, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispersionDataset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.groupIds, groupIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDerived, isDerived) || other.isDerived == isDerived)&&const DeepCollectionEquality().equals(other.sourceDatasetIds, sourceDatasetIds)&&(identical(other.pointCount, pointCount) || other.pointCount == pointCount)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(groupIds),createdAt,isDerived,const DeepCollectionEquality().hash(sourceDatasetIds),pointCount,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DispersionDataset(id: $id, name: $name, groupIds: $groupIds, createdAt: $createdAt, isDerived: $isDerived, sourceDatasetIds: $sourceDatasetIds, pointCount: $pointCount, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DispersionDatasetCopyWith<$Res>  {
  factory $DispersionDatasetCopyWith(DispersionDataset value, $Res Function(DispersionDataset) _then) = _$DispersionDatasetCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> groupIds, DateTime createdAt, bool isDerived, List<String> sourceDatasetIds, int pointCount, Map<String, String> metadata
});




}
/// @nodoc
class _$DispersionDatasetCopyWithImpl<$Res>
    implements $DispersionDatasetCopyWith<$Res> {
  _$DispersionDatasetCopyWithImpl(this._self, this._then);

  final DispersionDataset _self;
  final $Res Function(DispersionDataset) _then;

/// Create a copy of DispersionDataset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? groupIds = null,Object? createdAt = null,Object? isDerived = null,Object? sourceDatasetIds = null,Object? pointCount = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,groupIds: null == groupIds ? _self.groupIds : groupIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDerived: null == isDerived ? _self.isDerived : isDerived // ignore: cast_nullable_to_non_nullable
as bool,sourceDatasetIds: null == sourceDatasetIds ? _self.sourceDatasetIds : sourceDatasetIds // ignore: cast_nullable_to_non_nullable
as List<String>,pointCount: null == pointCount ? _self.pointCount : pointCount // ignore: cast_nullable_to_non_nullable
as int,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DispersionDataset].
extension DispersionDatasetPatterns on DispersionDataset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispersionDataset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispersionDataset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispersionDataset value)  $default,){
final _that = this;
switch (_that) {
case _DispersionDataset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispersionDataset value)?  $default,){
final _that = this;
switch (_that) {
case _DispersionDataset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> groupIds,  DateTime createdAt,  bool isDerived,  List<String> sourceDatasetIds,  int pointCount,  Map<String, String> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispersionDataset() when $default != null:
return $default(_that.id,_that.name,_that.groupIds,_that.createdAt,_that.isDerived,_that.sourceDatasetIds,_that.pointCount,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> groupIds,  DateTime createdAt,  bool isDerived,  List<String> sourceDatasetIds,  int pointCount,  Map<String, String> metadata)  $default,) {final _that = this;
switch (_that) {
case _DispersionDataset():
return $default(_that.id,_that.name,_that.groupIds,_that.createdAt,_that.isDerived,_that.sourceDatasetIds,_that.pointCount,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> groupIds,  DateTime createdAt,  bool isDerived,  List<String> sourceDatasetIds,  int pointCount,  Map<String, String> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DispersionDataset() when $default != null:
return $default(_that.id,_that.name,_that.groupIds,_that.createdAt,_that.isDerived,_that.sourceDatasetIds,_that.pointCount,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _DispersionDataset extends DispersionDataset {
  const _DispersionDataset({required this.id, required this.name, required final  List<String> groupIds, required this.createdAt, this.isDerived = false, final  List<String> sourceDatasetIds = const [], this.pointCount = 0, final  Map<String, String> metadata = const {}}): _groupIds = groupIds,_sourceDatasetIds = sourceDatasetIds,_metadata = metadata,super._();
  

@override final  String id;
@override final  String name;
 final  List<String> _groupIds;
@override List<String> get groupIds {
  if (_groupIds is EqualUnmodifiableListView) return _groupIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupIds);
}

@override final  DateTime createdAt;
@override@JsonKey() final  bool isDerived;
 final  List<String> _sourceDatasetIds;
@override@JsonKey() List<String> get sourceDatasetIds {
  if (_sourceDatasetIds is EqualUnmodifiableListView) return _sourceDatasetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceDatasetIds);
}

@override@JsonKey() final  int pointCount;
 final  Map<String, String> _metadata;
@override@JsonKey() Map<String, String> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DispersionDataset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispersionDatasetCopyWith<_DispersionDataset> get copyWith => __$DispersionDatasetCopyWithImpl<_DispersionDataset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispersionDataset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._groupIds, _groupIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDerived, isDerived) || other.isDerived == isDerived)&&const DeepCollectionEquality().equals(other._sourceDatasetIds, _sourceDatasetIds)&&(identical(other.pointCount, pointCount) || other.pointCount == pointCount)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_groupIds),createdAt,isDerived,const DeepCollectionEquality().hash(_sourceDatasetIds),pointCount,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DispersionDataset(id: $id, name: $name, groupIds: $groupIds, createdAt: $createdAt, isDerived: $isDerived, sourceDatasetIds: $sourceDatasetIds, pointCount: $pointCount, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DispersionDatasetCopyWith<$Res> implements $DispersionDatasetCopyWith<$Res> {
  factory _$DispersionDatasetCopyWith(_DispersionDataset value, $Res Function(_DispersionDataset) _then) = __$DispersionDatasetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> groupIds, DateTime createdAt, bool isDerived, List<String> sourceDatasetIds, int pointCount, Map<String, String> metadata
});




}
/// @nodoc
class __$DispersionDatasetCopyWithImpl<$Res>
    implements _$DispersionDatasetCopyWith<$Res> {
  __$DispersionDatasetCopyWithImpl(this._self, this._then);

  final _DispersionDataset _self;
  final $Res Function(_DispersionDataset) _then;

/// Create a copy of DispersionDataset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? groupIds = null,Object? createdAt = null,Object? isDerived = null,Object? sourceDatasetIds = null,Object? pointCount = null,Object? metadata = null,}) {
  return _then(_DispersionDataset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,groupIds: null == groupIds ? _self._groupIds : groupIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDerived: null == isDerived ? _self.isDerived : isDerived // ignore: cast_nullable_to_non_nullable
as bool,sourceDatasetIds: null == sourceDatasetIds ? _self._sourceDatasetIds : sourceDatasetIds // ignore: cast_nullable_to_non_nullable
as List<String>,pointCount: null == pointCount ? _self.pointCount : pointCount // ignore: cast_nullable_to_non_nullable
as int,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
