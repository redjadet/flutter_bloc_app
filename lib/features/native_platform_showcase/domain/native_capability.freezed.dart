// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_capability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NativeCapability {

 NativeCapabilityKind get kind; String get platformDetail;
/// Create a copy of NativeCapability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeCapabilityCopyWith<NativeCapability> get copyWith => _$NativeCapabilityCopyWithImpl<NativeCapability>(this as NativeCapability, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeCapability&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.platformDetail, platformDetail) || other.platformDetail == platformDetail));
}


@override
int get hashCode => Object.hash(runtimeType,kind,platformDetail);

@override
String toString() {
  return 'NativeCapability(kind: $kind, platformDetail: $platformDetail)';
}


}

/// @nodoc
abstract mixin class $NativeCapabilityCopyWith<$Res>  {
  factory $NativeCapabilityCopyWith(NativeCapability value, $Res Function(NativeCapability) _then) = _$NativeCapabilityCopyWithImpl;
@useResult
$Res call({
 NativeCapabilityKind kind, String platformDetail
});




}
/// @nodoc
class _$NativeCapabilityCopyWithImpl<$Res>
    implements $NativeCapabilityCopyWith<$Res> {
  _$NativeCapabilityCopyWithImpl(this._self, this._then);

  final NativeCapability _self;
  final $Res Function(NativeCapability) _then;

/// Create a copy of NativeCapability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? platformDetail = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as NativeCapabilityKind,platformDetail: null == platformDetail ? _self.platformDetail : platformDetail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NativeCapability].
extension NativeCapabilityPatterns on NativeCapability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeCapability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NativeCapability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeCapability value)  $default,){
final _that = this;
switch (_that) {
case _NativeCapability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeCapability value)?  $default,){
final _that = this;
switch (_that) {
case _NativeCapability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NativeCapabilityKind kind,  String platformDetail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeCapability() when $default != null:
return $default(_that.kind,_that.platformDetail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NativeCapabilityKind kind,  String platformDetail)  $default,) {final _that = this;
switch (_that) {
case _NativeCapability():
return $default(_that.kind,_that.platformDetail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NativeCapabilityKind kind,  String platformDetail)?  $default,) {final _that = this;
switch (_that) {
case _NativeCapability() when $default != null:
return $default(_that.kind,_that.platformDetail);case _:
  return null;

}
}

}

/// @nodoc


class _NativeCapability implements NativeCapability {
  const _NativeCapability({required this.kind, required this.platformDetail});
  

@override final  NativeCapabilityKind kind;
@override final  String platformDetail;

/// Create a copy of NativeCapability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeCapabilityCopyWith<_NativeCapability> get copyWith => __$NativeCapabilityCopyWithImpl<_NativeCapability>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeCapability&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.platformDetail, platformDetail) || other.platformDetail == platformDetail));
}


@override
int get hashCode => Object.hash(runtimeType,kind,platformDetail);

@override
String toString() {
  return 'NativeCapability(kind: $kind, platformDetail: $platformDetail)';
}


}

/// @nodoc
abstract mixin class _$NativeCapabilityCopyWith<$Res> implements $NativeCapabilityCopyWith<$Res> {
  factory _$NativeCapabilityCopyWith(_NativeCapability value, $Res Function(_NativeCapability) _then) = __$NativeCapabilityCopyWithImpl;
@override @useResult
$Res call({
 NativeCapabilityKind kind, String platformDetail
});




}
/// @nodoc
class __$NativeCapabilityCopyWithImpl<$Res>
    implements _$NativeCapabilityCopyWith<$Res> {
  __$NativeCapabilityCopyWithImpl(this._self, this._then);

  final _NativeCapability _self;
  final $Res Function(_NativeCapability) _then;

/// Create a copy of NativeCapability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? platformDetail = null,}) {
  return _then(_NativeCapability(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as NativeCapabilityKind,platformDetail: null == platformDetail ? _self.platformDetail : platformDetail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
