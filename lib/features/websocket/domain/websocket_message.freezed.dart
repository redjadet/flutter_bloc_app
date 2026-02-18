// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebsocketMessage {

 WebsocketMessageDirection get direction; String get text;
/// Create a copy of WebsocketMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebsocketMessageCopyWith<WebsocketMessage> get copyWith => _$WebsocketMessageCopyWithImpl<WebsocketMessage>(this as WebsocketMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebsocketMessage&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,direction,text);

@override
String toString() {
  return 'WebsocketMessage(direction: $direction, text: $text)';
}


}

/// @nodoc
abstract mixin class $WebsocketMessageCopyWith<$Res>  {
  factory $WebsocketMessageCopyWith(WebsocketMessage value, $Res Function(WebsocketMessage) _then) = _$WebsocketMessageCopyWithImpl;
@useResult
$Res call({
 WebsocketMessageDirection direction, String text
});




}
/// @nodoc
class _$WebsocketMessageCopyWithImpl<$Res>
    implements $WebsocketMessageCopyWith<$Res> {
  _$WebsocketMessageCopyWithImpl(this._self, this._then);

  final WebsocketMessage _self;
  final $Res Function(WebsocketMessage) _then;

/// Create a copy of WebsocketMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? direction = null,Object? text = null,}) {
  return _then(_self.copyWith(
direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as WebsocketMessageDirection,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WebsocketMessage].
extension WebsocketMessagePatterns on WebsocketMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebsocketMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebsocketMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebsocketMessage value)  $default,){
final _that = this;
switch (_that) {
case _WebsocketMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebsocketMessage value)?  $default,){
final _that = this;
switch (_that) {
case _WebsocketMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WebsocketMessageDirection direction,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebsocketMessage() when $default != null:
return $default(_that.direction,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WebsocketMessageDirection direction,  String text)  $default,) {final _that = this;
switch (_that) {
case _WebsocketMessage():
return $default(_that.direction,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WebsocketMessageDirection direction,  String text)?  $default,) {final _that = this;
switch (_that) {
case _WebsocketMessage() when $default != null:
return $default(_that.direction,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _WebsocketMessage implements WebsocketMessage {
  const _WebsocketMessage({required this.direction, required this.text});
  

@override final  WebsocketMessageDirection direction;
@override final  String text;

/// Create a copy of WebsocketMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebsocketMessageCopyWith<_WebsocketMessage> get copyWith => __$WebsocketMessageCopyWithImpl<_WebsocketMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebsocketMessage&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,direction,text);

@override
String toString() {
  return 'WebsocketMessage(direction: $direction, text: $text)';
}


}

/// @nodoc
abstract mixin class _$WebsocketMessageCopyWith<$Res> implements $WebsocketMessageCopyWith<$Res> {
  factory _$WebsocketMessageCopyWith(_WebsocketMessage value, $Res Function(_WebsocketMessage) _then) = __$WebsocketMessageCopyWithImpl;
@override @useResult
$Res call({
 WebsocketMessageDirection direction, String text
});




}
/// @nodoc
class __$WebsocketMessageCopyWithImpl<$Res>
    implements _$WebsocketMessageCopyWith<$Res> {
  __$WebsocketMessageCopyWithImpl(this._self, this._then);

  final _WebsocketMessage _self;
  final $Res Function(_WebsocketMessage) _then;

/// Create a copy of WebsocketMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? direction = null,Object? text = null,}) {
  return _then(_WebsocketMessage(
direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as WebsocketMessageDirection,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
