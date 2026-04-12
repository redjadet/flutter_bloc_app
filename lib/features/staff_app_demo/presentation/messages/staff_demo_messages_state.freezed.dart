// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_messages_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoMessagesState {

 StaffDemoMessagesStatus get status; List<StaffDemoInboxItem> get items; StaffDemoMessagesKnownError? get knownError; String? get errorMessage;
/// Create a copy of StaffDemoMessagesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoMessagesStateCopyWith<StaffDemoMessagesState> get copyWith => _$StaffDemoMessagesStateCopyWithImpl<StaffDemoMessagesState>(this as StaffDemoMessagesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoMessagesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.knownError, knownError) || other.knownError == knownError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(items),knownError,errorMessage);

@override
String toString() {
  return 'StaffDemoMessagesState(status: $status, items: $items, knownError: $knownError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $StaffDemoMessagesStateCopyWith<$Res>  {
  factory $StaffDemoMessagesStateCopyWith(StaffDemoMessagesState value, $Res Function(StaffDemoMessagesState) _then) = _$StaffDemoMessagesStateCopyWithImpl;
@useResult
$Res call({
 StaffDemoMessagesStatus status, List<StaffDemoInboxItem> items, StaffDemoMessagesKnownError? knownError, String? errorMessage
});




}
/// @nodoc
class _$StaffDemoMessagesStateCopyWithImpl<$Res>
    implements $StaffDemoMessagesStateCopyWith<$Res> {
  _$StaffDemoMessagesStateCopyWithImpl(this._self, this._then);

  final StaffDemoMessagesState _self;
  final $Res Function(StaffDemoMessagesState) _then;

/// Create a copy of StaffDemoMessagesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? items = null,Object? knownError = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoMessagesStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StaffDemoInboxItem>,knownError: freezed == knownError ? _self.knownError : knownError // ignore: cast_nullable_to_non_nullable
as StaffDemoMessagesKnownError?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoMessagesState].
extension StaffDemoMessagesStatePatterns on StaffDemoMessagesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoMessagesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoMessagesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoMessagesState value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoMessagesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoMessagesState value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoMessagesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffDemoMessagesStatus status,  List<StaffDemoInboxItem> items,  StaffDemoMessagesKnownError? knownError,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoMessagesState() when $default != null:
return $default(_that.status,_that.items,_that.knownError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffDemoMessagesStatus status,  List<StaffDemoInboxItem> items,  StaffDemoMessagesKnownError? knownError,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoMessagesState():
return $default(_that.status,_that.items,_that.knownError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffDemoMessagesStatus status,  List<StaffDemoInboxItem> items,  StaffDemoMessagesKnownError? knownError,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoMessagesState() when $default != null:
return $default(_that.status,_that.items,_that.knownError,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoMessagesState implements StaffDemoMessagesState {
  const _StaffDemoMessagesState({this.status = StaffDemoMessagesStatus.initial, final  List<StaffDemoInboxItem> items = const <StaffDemoInboxItem>[], this.knownError, this.errorMessage}): _items = items;
  

@override@JsonKey() final  StaffDemoMessagesStatus status;
 final  List<StaffDemoInboxItem> _items;
@override@JsonKey() List<StaffDemoInboxItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  StaffDemoMessagesKnownError? knownError;
@override final  String? errorMessage;

/// Create a copy of StaffDemoMessagesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoMessagesStateCopyWith<_StaffDemoMessagesState> get copyWith => __$StaffDemoMessagesStateCopyWithImpl<_StaffDemoMessagesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoMessagesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.knownError, knownError) || other.knownError == knownError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_items),knownError,errorMessage);

@override
String toString() {
  return 'StaffDemoMessagesState(status: $status, items: $items, knownError: $knownError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoMessagesStateCopyWith<$Res> implements $StaffDemoMessagesStateCopyWith<$Res> {
  factory _$StaffDemoMessagesStateCopyWith(_StaffDemoMessagesState value, $Res Function(_StaffDemoMessagesState) _then) = __$StaffDemoMessagesStateCopyWithImpl;
@override @useResult
$Res call({
 StaffDemoMessagesStatus status, List<StaffDemoInboxItem> items, StaffDemoMessagesKnownError? knownError, String? errorMessage
});




}
/// @nodoc
class __$StaffDemoMessagesStateCopyWithImpl<$Res>
    implements _$StaffDemoMessagesStateCopyWith<$Res> {
  __$StaffDemoMessagesStateCopyWithImpl(this._self, this._then);

  final _StaffDemoMessagesState _self;
  final $Res Function(_StaffDemoMessagesState) _then;

/// Create a copy of StaffDemoMessagesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? items = null,Object? knownError = freezed,Object? errorMessage = freezed,}) {
  return _then(_StaffDemoMessagesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoMessagesStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StaffDemoInboxItem>,knownError: freezed == knownError ? _self.knownError : knownError // ignore: cast_nullable_to_non_nullable
as StaffDemoMessagesKnownError?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
