// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_content_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoContentState {

 StaffDemoContentStatus get status; List<StaffDemoContentItem> get items; String? get errorMessage;
/// Create a copy of StaffDemoContentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoContentStateCopyWith<StaffDemoContentState> get copyWith => _$StaffDemoContentStateCopyWithImpl<StaffDemoContentState>(this as StaffDemoContentState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoContentState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(items),errorMessage);

@override
String toString() {
  return 'StaffDemoContentState(status: $status, items: $items, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $StaffDemoContentStateCopyWith<$Res>  {
  factory $StaffDemoContentStateCopyWith(StaffDemoContentState value, $Res Function(StaffDemoContentState) _then) = _$StaffDemoContentStateCopyWithImpl;
@useResult
$Res call({
 StaffDemoContentStatus status, List<StaffDemoContentItem> items, String? errorMessage
});




}
/// @nodoc
class _$StaffDemoContentStateCopyWithImpl<$Res>
    implements $StaffDemoContentStateCopyWith<$Res> {
  _$StaffDemoContentStateCopyWithImpl(this._self, this._then);

  final StaffDemoContentState _self;
  final $Res Function(StaffDemoContentState) _then;

/// Create a copy of StaffDemoContentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoContentStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StaffDemoContentItem>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoContentState].
extension StaffDemoContentStatePatterns on StaffDemoContentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoContentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoContentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoContentState value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoContentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoContentState value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoContentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffDemoContentStatus status,  List<StaffDemoContentItem> items,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoContentState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffDemoContentStatus status,  List<StaffDemoContentItem> items,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoContentState():
return $default(_that.status,_that.items,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffDemoContentStatus status,  List<StaffDemoContentItem> items,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoContentState() when $default != null:
return $default(_that.status,_that.items,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoContentState implements StaffDemoContentState {
  const _StaffDemoContentState({this.status = StaffDemoContentStatus.initial, final  List<StaffDemoContentItem> items = const <StaffDemoContentItem>[], this.errorMessage}): _items = items;
  

@override@JsonKey() final  StaffDemoContentStatus status;
 final  List<StaffDemoContentItem> _items;
@override@JsonKey() List<StaffDemoContentItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? errorMessage;

/// Create a copy of StaffDemoContentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoContentStateCopyWith<_StaffDemoContentState> get copyWith => __$StaffDemoContentStateCopyWithImpl<_StaffDemoContentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoContentState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_items),errorMessage);

@override
String toString() {
  return 'StaffDemoContentState(status: $status, items: $items, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoContentStateCopyWith<$Res> implements $StaffDemoContentStateCopyWith<$Res> {
  factory _$StaffDemoContentStateCopyWith(_StaffDemoContentState value, $Res Function(_StaffDemoContentState) _then) = __$StaffDemoContentStateCopyWithImpl;
@override @useResult
$Res call({
 StaffDemoContentStatus status, List<StaffDemoContentItem> items, String? errorMessage
});




}
/// @nodoc
class __$StaffDemoContentStateCopyWithImpl<$Res>
    implements _$StaffDemoContentStateCopyWith<$Res> {
  __$StaffDemoContentStateCopyWithImpl(this._self, this._then);

  final _StaffDemoContentState _self;
  final $Res Function(_StaffDemoContentState) _then;

/// Create a copy of StaffDemoContentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? items = null,Object? errorMessage = freezed,}) {
  return _then(_StaffDemoContentState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoContentStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StaffDemoContentItem>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
