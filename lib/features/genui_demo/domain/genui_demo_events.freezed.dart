// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'genui_demo_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenUiSurfaceEvent {

 String get surfaceId;
/// Create a copy of GenUiSurfaceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenUiSurfaceEventCopyWith<GenUiSurfaceEvent> get copyWith => _$GenUiSurfaceEventCopyWithImpl<GenUiSurfaceEvent>(this as GenUiSurfaceEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenUiSurfaceEvent&&(identical(other.surfaceId, surfaceId) || other.surfaceId == surfaceId));
}


@override
int get hashCode => Object.hash(runtimeType,surfaceId);

@override
String toString() {
  return 'GenUiSurfaceEvent(surfaceId: $surfaceId)';
}


}

/// @nodoc
abstract mixin class $GenUiSurfaceEventCopyWith<$Res>  {
  factory $GenUiSurfaceEventCopyWith(GenUiSurfaceEvent value, $Res Function(GenUiSurfaceEvent) _then) = _$GenUiSurfaceEventCopyWithImpl;
@useResult
$Res call({
 String surfaceId
});




}
/// @nodoc
class _$GenUiSurfaceEventCopyWithImpl<$Res>
    implements $GenUiSurfaceEventCopyWith<$Res> {
  _$GenUiSurfaceEventCopyWithImpl(this._self, this._then);

  final GenUiSurfaceEvent _self;
  final $Res Function(GenUiSurfaceEvent) _then;

/// Create a copy of GenUiSurfaceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? surfaceId = null,}) {
  return _then(_self.copyWith(
surfaceId: null == surfaceId ? _self.surfaceId : surfaceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GenUiSurfaceEvent].
extension GenUiSurfaceEventPatterns on GenUiSurfaceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GenUiSurfaceAdded value)?  added,TResult Function( GenUiSurfaceRemoved value)?  removed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GenUiSurfaceAdded() when added != null:
return added(_that);case GenUiSurfaceRemoved() when removed != null:
return removed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GenUiSurfaceAdded value)  added,required TResult Function( GenUiSurfaceRemoved value)  removed,}){
final _that = this;
switch (_that) {
case GenUiSurfaceAdded():
return added(_that);case GenUiSurfaceRemoved():
return removed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GenUiSurfaceAdded value)?  added,TResult? Function( GenUiSurfaceRemoved value)?  removed,}){
final _that = this;
switch (_that) {
case GenUiSurfaceAdded() when added != null:
return added(_that);case GenUiSurfaceRemoved() when removed != null:
return removed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String surfaceId)?  added,TResult Function( String surfaceId)?  removed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GenUiSurfaceAdded() when added != null:
return added(_that.surfaceId);case GenUiSurfaceRemoved() when removed != null:
return removed(_that.surfaceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String surfaceId)  added,required TResult Function( String surfaceId)  removed,}) {final _that = this;
switch (_that) {
case GenUiSurfaceAdded():
return added(_that.surfaceId);case GenUiSurfaceRemoved():
return removed(_that.surfaceId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String surfaceId)?  added,TResult? Function( String surfaceId)?  removed,}) {final _that = this;
switch (_that) {
case GenUiSurfaceAdded() when added != null:
return added(_that.surfaceId);case GenUiSurfaceRemoved() when removed != null:
return removed(_that.surfaceId);case _:
  return null;

}
}

}

/// @nodoc


class GenUiSurfaceAdded extends GenUiSurfaceEvent {
  const GenUiSurfaceAdded({required this.surfaceId}): super._();
  

@override final  String surfaceId;

/// Create a copy of GenUiSurfaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenUiSurfaceAddedCopyWith<GenUiSurfaceAdded> get copyWith => _$GenUiSurfaceAddedCopyWithImpl<GenUiSurfaceAdded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenUiSurfaceAdded&&(identical(other.surfaceId, surfaceId) || other.surfaceId == surfaceId));
}


@override
int get hashCode => Object.hash(runtimeType,surfaceId);

@override
String toString() {
  return 'GenUiSurfaceEvent.added(surfaceId: $surfaceId)';
}


}

/// @nodoc
abstract mixin class $GenUiSurfaceAddedCopyWith<$Res> implements $GenUiSurfaceEventCopyWith<$Res> {
  factory $GenUiSurfaceAddedCopyWith(GenUiSurfaceAdded value, $Res Function(GenUiSurfaceAdded) _then) = _$GenUiSurfaceAddedCopyWithImpl;
@override @useResult
$Res call({
 String surfaceId
});




}
/// @nodoc
class _$GenUiSurfaceAddedCopyWithImpl<$Res>
    implements $GenUiSurfaceAddedCopyWith<$Res> {
  _$GenUiSurfaceAddedCopyWithImpl(this._self, this._then);

  final GenUiSurfaceAdded _self;
  final $Res Function(GenUiSurfaceAdded) _then;

/// Create a copy of GenUiSurfaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surfaceId = null,}) {
  return _then(GenUiSurfaceAdded(
surfaceId: null == surfaceId ? _self.surfaceId : surfaceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GenUiSurfaceRemoved extends GenUiSurfaceEvent {
  const GenUiSurfaceRemoved({required this.surfaceId}): super._();
  

@override final  String surfaceId;

/// Create a copy of GenUiSurfaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenUiSurfaceRemovedCopyWith<GenUiSurfaceRemoved> get copyWith => _$GenUiSurfaceRemovedCopyWithImpl<GenUiSurfaceRemoved>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenUiSurfaceRemoved&&(identical(other.surfaceId, surfaceId) || other.surfaceId == surfaceId));
}


@override
int get hashCode => Object.hash(runtimeType,surfaceId);

@override
String toString() {
  return 'GenUiSurfaceEvent.removed(surfaceId: $surfaceId)';
}


}

/// @nodoc
abstract mixin class $GenUiSurfaceRemovedCopyWith<$Res> implements $GenUiSurfaceEventCopyWith<$Res> {
  factory $GenUiSurfaceRemovedCopyWith(GenUiSurfaceRemoved value, $Res Function(GenUiSurfaceRemoved) _then) = _$GenUiSurfaceRemovedCopyWithImpl;
@override @useResult
$Res call({
 String surfaceId
});




}
/// @nodoc
class _$GenUiSurfaceRemovedCopyWithImpl<$Res>
    implements $GenUiSurfaceRemovedCopyWith<$Res> {
  _$GenUiSurfaceRemovedCopyWithImpl(this._self, this._then);

  final GenUiSurfaceRemoved _self;
  final $Res Function(GenUiSurfaceRemoved) _then;

/// Create a copy of GenUiSurfaceEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? surfaceId = null,}) {
  return _then(GenUiSurfaceRemoved(
surfaceId: null == surfaceId ? _self.surfaceId : surfaceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
