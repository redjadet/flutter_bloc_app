// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket_connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebsocketConnectionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebsocketConnectionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WebsocketConnectionState()';
}


}

/// @nodoc
class $WebsocketConnectionStateCopyWith<$Res>  {
$WebsocketConnectionStateCopyWith(WebsocketConnectionState _, $Res Function(WebsocketConnectionState) __);
}


/// Adds pattern-matching-related methods to [WebsocketConnectionState].
extension WebsocketConnectionStatePatterns on WebsocketConnectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WebsocketConnectionStateDisconnected value)?  disconnected,TResult Function( WebsocketConnectionStateConnecting value)?  connecting,TResult Function( WebsocketConnectionStateConnected value)?  connected,TResult Function( WebsocketConnectionStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WebsocketConnectionStateDisconnected() when disconnected != null:
return disconnected(_that);case WebsocketConnectionStateConnecting() when connecting != null:
return connecting(_that);case WebsocketConnectionStateConnected() when connected != null:
return connected(_that);case WebsocketConnectionStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WebsocketConnectionStateDisconnected value)  disconnected,required TResult Function( WebsocketConnectionStateConnecting value)  connecting,required TResult Function( WebsocketConnectionStateConnected value)  connected,required TResult Function( WebsocketConnectionStateError value)  error,}){
final _that = this;
switch (_that) {
case WebsocketConnectionStateDisconnected():
return disconnected(_that);case WebsocketConnectionStateConnecting():
return connecting(_that);case WebsocketConnectionStateConnected():
return connected(_that);case WebsocketConnectionStateError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WebsocketConnectionStateDisconnected value)?  disconnected,TResult? Function( WebsocketConnectionStateConnecting value)?  connecting,TResult? Function( WebsocketConnectionStateConnected value)?  connected,TResult? Function( WebsocketConnectionStateError value)?  error,}){
final _that = this;
switch (_that) {
case WebsocketConnectionStateDisconnected() when disconnected != null:
return disconnected(_that);case WebsocketConnectionStateConnecting() when connecting != null:
return connecting(_that);case WebsocketConnectionStateConnected() when connected != null:
return connected(_that);case WebsocketConnectionStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  disconnected,TResult Function()?  connecting,TResult Function()?  connected,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WebsocketConnectionStateDisconnected() when disconnected != null:
return disconnected();case WebsocketConnectionStateConnecting() when connecting != null:
return connecting();case WebsocketConnectionStateConnected() when connected != null:
return connected();case WebsocketConnectionStateError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  disconnected,required TResult Function()  connecting,required TResult Function()  connected,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case WebsocketConnectionStateDisconnected():
return disconnected();case WebsocketConnectionStateConnecting():
return connecting();case WebsocketConnectionStateConnected():
return connected();case WebsocketConnectionStateError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  disconnected,TResult? Function()?  connecting,TResult? Function()?  connected,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case WebsocketConnectionStateDisconnected() when disconnected != null:
return disconnected();case WebsocketConnectionStateConnecting() when connecting != null:
return connecting();case WebsocketConnectionStateConnected() when connected != null:
return connected();case WebsocketConnectionStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class WebsocketConnectionStateDisconnected extends WebsocketConnectionState {
  const WebsocketConnectionStateDisconnected(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebsocketConnectionStateDisconnected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WebsocketConnectionState.disconnected()';
}


}




/// @nodoc


class WebsocketConnectionStateConnecting extends WebsocketConnectionState {
  const WebsocketConnectionStateConnecting(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebsocketConnectionStateConnecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WebsocketConnectionState.connecting()';
}


}




/// @nodoc


class WebsocketConnectionStateConnected extends WebsocketConnectionState {
  const WebsocketConnectionStateConnected(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebsocketConnectionStateConnected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WebsocketConnectionState.connected()';
}


}




/// @nodoc


class WebsocketConnectionStateError extends WebsocketConnectionState {
  const WebsocketConnectionStateError(this.message): super._();
  

 final  String message;

/// Create a copy of WebsocketConnectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebsocketConnectionStateErrorCopyWith<WebsocketConnectionStateError> get copyWith => _$WebsocketConnectionStateErrorCopyWithImpl<WebsocketConnectionStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebsocketConnectionStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'WebsocketConnectionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $WebsocketConnectionStateErrorCopyWith<$Res> implements $WebsocketConnectionStateCopyWith<$Res> {
  factory $WebsocketConnectionStateErrorCopyWith(WebsocketConnectionStateError value, $Res Function(WebsocketConnectionStateError) _then) = _$WebsocketConnectionStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$WebsocketConnectionStateErrorCopyWithImpl<$Res>
    implements $WebsocketConnectionStateErrorCopyWith<$Res> {
  _$WebsocketConnectionStateErrorCopyWithImpl(this._self, this._then);

  final WebsocketConnectionStateError _self;
  final $Res Function(WebsocketConnectionStateError) _then;

/// Create a copy of WebsocketConnectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(WebsocketConnectionStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
