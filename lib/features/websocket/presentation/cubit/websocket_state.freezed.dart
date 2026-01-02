// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebsocketState {

 Uri get endpoint; WebsocketStatus get status; List<WebsocketMessage> get messages; String? get errorMessage; bool get isSending;
/// Create a copy of WebsocketState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebsocketStateCopyWith<WebsocketState> get copyWith => _$WebsocketStateCopyWithImpl<WebsocketState>(this as WebsocketState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebsocketState&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isSending, isSending) || other.isSending == isSending));
}


@override
int get hashCode => Object.hash(runtimeType,endpoint,status,const DeepCollectionEquality().hash(messages),errorMessage,isSending);

@override
String toString() {
  return 'WebsocketState(endpoint: $endpoint, status: $status, messages: $messages, errorMessage: $errorMessage, isSending: $isSending)';
}


}

/// @nodoc
abstract mixin class $WebsocketStateCopyWith<$Res>  {
  factory $WebsocketStateCopyWith(WebsocketState value, $Res Function(WebsocketState) _then) = _$WebsocketStateCopyWithImpl;
@useResult
$Res call({
 Uri endpoint, WebsocketStatus status, List<WebsocketMessage> messages, String? errorMessage, bool isSending
});




}
/// @nodoc
class _$WebsocketStateCopyWithImpl<$Res>
    implements $WebsocketStateCopyWith<$Res> {
  _$WebsocketStateCopyWithImpl(this._self, this._then);

  final WebsocketState _self;
  final $Res Function(WebsocketState) _then;

/// Create a copy of WebsocketState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? endpoint = null,Object? status = null,Object? messages = null,Object? errorMessage = freezed,Object? isSending = null,}) {
  return _then(_self.copyWith(
endpoint: null == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as Uri,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WebsocketStatus,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<WebsocketMessage>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WebsocketState].
extension WebsocketStatePatterns on WebsocketState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebsocketState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebsocketState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebsocketState value)  $default,){
final _that = this;
switch (_that) {
case _WebsocketState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebsocketState value)?  $default,){
final _that = this;
switch (_that) {
case _WebsocketState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uri endpoint,  WebsocketStatus status,  List<WebsocketMessage> messages,  String? errorMessage,  bool isSending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebsocketState() when $default != null:
return $default(_that.endpoint,_that.status,_that.messages,_that.errorMessage,_that.isSending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uri endpoint,  WebsocketStatus status,  List<WebsocketMessage> messages,  String? errorMessage,  bool isSending)  $default,) {final _that = this;
switch (_that) {
case _WebsocketState():
return $default(_that.endpoint,_that.status,_that.messages,_that.errorMessage,_that.isSending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uri endpoint,  WebsocketStatus status,  List<WebsocketMessage> messages,  String? errorMessage,  bool isSending)?  $default,) {final _that = this;
switch (_that) {
case _WebsocketState() when $default != null:
return $default(_that.endpoint,_that.status,_that.messages,_that.errorMessage,_that.isSending);case _:
  return null;

}
}

}

/// @nodoc


class _WebsocketState extends WebsocketState {
  const _WebsocketState({required this.endpoint, required this.status, final  List<WebsocketMessage> messages = const <WebsocketMessage>[], this.errorMessage, this.isSending = false}): _messages = messages,super._();
  

@override final  Uri endpoint;
@override final  WebsocketStatus status;
 final  List<WebsocketMessage> _messages;
@override@JsonKey() List<WebsocketMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override final  String? errorMessage;
@override@JsonKey() final  bool isSending;

/// Create a copy of WebsocketState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebsocketStateCopyWith<_WebsocketState> get copyWith => __$WebsocketStateCopyWithImpl<_WebsocketState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebsocketState&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isSending, isSending) || other.isSending == isSending));
}


@override
int get hashCode => Object.hash(runtimeType,endpoint,status,const DeepCollectionEquality().hash(_messages),errorMessage,isSending);

@override
String toString() {
  return 'WebsocketState(endpoint: $endpoint, status: $status, messages: $messages, errorMessage: $errorMessage, isSending: $isSending)';
}


}

/// @nodoc
abstract mixin class _$WebsocketStateCopyWith<$Res> implements $WebsocketStateCopyWith<$Res> {
  factory _$WebsocketStateCopyWith(_WebsocketState value, $Res Function(_WebsocketState) _then) = __$WebsocketStateCopyWithImpl;
@override @useResult
$Res call({
 Uri endpoint, WebsocketStatus status, List<WebsocketMessage> messages, String? errorMessage, bool isSending
});




}
/// @nodoc
class __$WebsocketStateCopyWithImpl<$Res>
    implements _$WebsocketStateCopyWith<$Res> {
  __$WebsocketStateCopyWithImpl(this._self, this._then);

  final _WebsocketState _self;
  final $Res Function(_WebsocketState) _then;

/// Create a copy of WebsocketState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? endpoint = null,Object? status = null,Object? messages = null,Object? errorMessage = freezed,Object? isSending = null,}) {
  return _then(_WebsocketState(
endpoint: null == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as Uri,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WebsocketStatus,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<WebsocketMessage>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
