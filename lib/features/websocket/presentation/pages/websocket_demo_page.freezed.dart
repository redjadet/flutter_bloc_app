// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket_demo_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebsocketViewData implements DiagnosticableTreeMixin {

 bool get isConnecting; bool get isConnected; bool get isSending; List<WebsocketMessage> get messages;
/// Create a copy of _WebsocketViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebsocketViewDataCopyWith<_WebsocketViewData> get copyWith => __$WebsocketViewDataCopyWithImpl<_WebsocketViewData>(this as _WebsocketViewData, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_WebsocketViewData'))
    ..add(DiagnosticsProperty('isConnecting', isConnecting))..add(DiagnosticsProperty('isConnected', isConnected))..add(DiagnosticsProperty('isSending', isSending))..add(DiagnosticsProperty('messages', messages));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebsocketViewData&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&const DeepCollectionEquality().equals(other.messages, messages));
}


@override
int get hashCode => Object.hash(runtimeType,isConnecting,isConnected,isSending,const DeepCollectionEquality().hash(messages));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_WebsocketViewData(isConnecting: $isConnecting, isConnected: $isConnected, isSending: $isSending, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$WebsocketViewDataCopyWith<$Res>  {
  factory _$WebsocketViewDataCopyWith(_WebsocketViewData value, $Res Function(_WebsocketViewData) _then) = __$WebsocketViewDataCopyWithImpl;
@useResult
$Res call({
 bool isConnecting, bool isConnected, bool isSending, List<WebsocketMessage> messages
});




}
/// @nodoc
class __$WebsocketViewDataCopyWithImpl<$Res>
    implements _$WebsocketViewDataCopyWith<$Res> {
  __$WebsocketViewDataCopyWithImpl(this._self, this._then);

  final _WebsocketViewData _self;
  final $Res Function(_WebsocketViewData) _then;

/// Create a copy of _WebsocketViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isConnecting = null,Object? isConnected = null,Object? isSending = null,Object? messages = null,}) {
  return _then(_self.copyWith(
isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<WebsocketMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [_WebsocketViewData].
extension _WebsocketViewDataPatterns on _WebsocketViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __WebsocketViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __WebsocketViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __WebsocketViewData value)  $default,){
final _that = this;
switch (_that) {
case __WebsocketViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __WebsocketViewData value)?  $default,){
final _that = this;
switch (_that) {
case __WebsocketViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isConnecting,  bool isConnected,  bool isSending,  List<WebsocketMessage> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __WebsocketViewData() when $default != null:
return $default(_that.isConnecting,_that.isConnected,_that.isSending,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isConnecting,  bool isConnected,  bool isSending,  List<WebsocketMessage> messages)  $default,) {final _that = this;
switch (_that) {
case __WebsocketViewData():
return $default(_that.isConnecting,_that.isConnected,_that.isSending,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isConnecting,  bool isConnected,  bool isSending,  List<WebsocketMessage> messages)?  $default,) {final _that = this;
switch (_that) {
case __WebsocketViewData() when $default != null:
return $default(_that.isConnecting,_that.isConnected,_that.isSending,_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class __WebsocketViewData with DiagnosticableTreeMixin implements _WebsocketViewData {
  const __WebsocketViewData({required this.isConnecting, required this.isConnected, required this.isSending, required final  List<WebsocketMessage> messages}): _messages = messages;
  

@override final  bool isConnecting;
@override final  bool isConnected;
@override final  bool isSending;
 final  List<WebsocketMessage> _messages;
@override List<WebsocketMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of _WebsocketViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_WebsocketViewDataCopyWith<__WebsocketViewData> get copyWith => __$_WebsocketViewDataCopyWithImpl<__WebsocketViewData>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', '_WebsocketViewData'))
    ..add(DiagnosticsProperty('isConnecting', isConnecting))..add(DiagnosticsProperty('isConnected', isConnected))..add(DiagnosticsProperty('isSending', isSending))..add(DiagnosticsProperty('messages', messages));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __WebsocketViewData&&(identical(other.isConnecting, isConnecting) || other.isConnecting == isConnecting)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,isConnecting,isConnected,isSending,const DeepCollectionEquality().hash(_messages));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return '_WebsocketViewData(isConnecting: $isConnecting, isConnected: $isConnected, isSending: $isSending, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$_WebsocketViewDataCopyWith<$Res> implements _$WebsocketViewDataCopyWith<$Res> {
  factory _$_WebsocketViewDataCopyWith(__WebsocketViewData value, $Res Function(__WebsocketViewData) _then) = __$_WebsocketViewDataCopyWithImpl;
@override @useResult
$Res call({
 bool isConnecting, bool isConnected, bool isSending, List<WebsocketMessage> messages
});




}
/// @nodoc
class __$_WebsocketViewDataCopyWithImpl<$Res>
    implements _$_WebsocketViewDataCopyWith<$Res> {
  __$_WebsocketViewDataCopyWithImpl(this._self, this._then);

  final __WebsocketViewData _self;
  final $Res Function(__WebsocketViewData) _then;

/// Create a copy of _WebsocketViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isConnecting = null,Object? isConnected = null,Object? isSending = null,Object? messages = null,}) {
  return _then(__WebsocketViewData(
isConnecting: null == isConnecting ? _self.isConnecting : isConnecting // ignore: cast_nullable_to_non_nullable
as bool,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<WebsocketMessage>,
  ));
}


}

// dart format on
