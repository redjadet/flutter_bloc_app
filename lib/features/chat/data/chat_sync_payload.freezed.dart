// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_sync_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatSyncPayload {

 String get conversationId; String get prompt; List<String> get pastUserInputs; List<String> get generatedResponses; String? get model; String get clientMessageId; DateTime get createdAt;
/// Create a copy of ChatSyncPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSyncPayloadCopyWith<ChatSyncPayload> get copyWith => _$ChatSyncPayloadCopyWithImpl<ChatSyncPayload>(this as ChatSyncPayload, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSyncPayload&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other.pastUserInputs, pastUserInputs)&&const DeepCollectionEquality().equals(other.generatedResponses, generatedResponses)&&(identical(other.model, model) || other.model == model)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,prompt,const DeepCollectionEquality().hash(pastUserInputs),const DeepCollectionEquality().hash(generatedResponses),model,clientMessageId,createdAt);

@override
String toString() {
  return 'ChatSyncPayload(conversationId: $conversationId, prompt: $prompt, pastUserInputs: $pastUserInputs, generatedResponses: $generatedResponses, model: $model, clientMessageId: $clientMessageId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatSyncPayloadCopyWith<$Res>  {
  factory $ChatSyncPayloadCopyWith(ChatSyncPayload value, $Res Function(ChatSyncPayload) _then) = _$ChatSyncPayloadCopyWithImpl;
@useResult
$Res call({
 String conversationId, String prompt, List<String> pastUserInputs, List<String> generatedResponses, String? model, String clientMessageId, DateTime createdAt
});




}
/// @nodoc
class _$ChatSyncPayloadCopyWithImpl<$Res>
    implements $ChatSyncPayloadCopyWith<$Res> {
  _$ChatSyncPayloadCopyWithImpl(this._self, this._then);

  final ChatSyncPayload _self;
  final $Res Function(ChatSyncPayload) _then;

/// Create a copy of ChatSyncPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? prompt = null,Object? pastUserInputs = null,Object? generatedResponses = null,Object? model = freezed,Object? clientMessageId = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,pastUserInputs: null == pastUserInputs ? _self.pastUserInputs : pastUserInputs // ignore: cast_nullable_to_non_nullable
as List<String>,generatedResponses: null == generatedResponses ? _self.generatedResponses : generatedResponses // ignore: cast_nullable_to_non_nullable
as List<String>,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: null == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatSyncPayload].
extension ChatSyncPayloadPatterns on ChatSyncPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatSyncPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatSyncPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatSyncPayload value)  $default,){
final _that = this;
switch (_that) {
case _ChatSyncPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatSyncPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ChatSyncPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId,  String prompt,  List<String> pastUserInputs,  List<String> generatedResponses,  String? model,  String clientMessageId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatSyncPayload() when $default != null:
return $default(_that.conversationId,_that.prompt,_that.pastUserInputs,_that.generatedResponses,_that.model,_that.clientMessageId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId,  String prompt,  List<String> pastUserInputs,  List<String> generatedResponses,  String? model,  String clientMessageId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatSyncPayload():
return $default(_that.conversationId,_that.prompt,_that.pastUserInputs,_that.generatedResponses,_that.model,_that.clientMessageId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId,  String prompt,  List<String> pastUserInputs,  List<String> generatedResponses,  String? model,  String clientMessageId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatSyncPayload() when $default != null:
return $default(_that.conversationId,_that.prompt,_that.pastUserInputs,_that.generatedResponses,_that.model,_that.clientMessageId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ChatSyncPayload extends ChatSyncPayload {
  const _ChatSyncPayload({required this.conversationId, required this.prompt, required final  List<String> pastUserInputs, required final  List<String> generatedResponses, required this.model, required this.clientMessageId, required this.createdAt}): _pastUserInputs = pastUserInputs,_generatedResponses = generatedResponses,super._();
  

@override final  String conversationId;
@override final  String prompt;
 final  List<String> _pastUserInputs;
@override List<String> get pastUserInputs {
  if (_pastUserInputs is EqualUnmodifiableListView) return _pastUserInputs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pastUserInputs);
}

 final  List<String> _generatedResponses;
@override List<String> get generatedResponses {
  if (_generatedResponses is EqualUnmodifiableListView) return _generatedResponses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_generatedResponses);
}

@override final  String? model;
@override final  String clientMessageId;
@override final  DateTime createdAt;

/// Create a copy of ChatSyncPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSyncPayloadCopyWith<_ChatSyncPayload> get copyWith => __$ChatSyncPayloadCopyWithImpl<_ChatSyncPayload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSyncPayload&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&const DeepCollectionEquality().equals(other._pastUserInputs, _pastUserInputs)&&const DeepCollectionEquality().equals(other._generatedResponses, _generatedResponses)&&(identical(other.model, model) || other.model == model)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,prompt,const DeepCollectionEquality().hash(_pastUserInputs),const DeepCollectionEquality().hash(_generatedResponses),model,clientMessageId,createdAt);

@override
String toString() {
  return 'ChatSyncPayload(conversationId: $conversationId, prompt: $prompt, pastUserInputs: $pastUserInputs, generatedResponses: $generatedResponses, model: $model, clientMessageId: $clientMessageId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatSyncPayloadCopyWith<$Res> implements $ChatSyncPayloadCopyWith<$Res> {
  factory _$ChatSyncPayloadCopyWith(_ChatSyncPayload value, $Res Function(_ChatSyncPayload) _then) = __$ChatSyncPayloadCopyWithImpl;
@override @useResult
$Res call({
 String conversationId, String prompt, List<String> pastUserInputs, List<String> generatedResponses, String? model, String clientMessageId, DateTime createdAt
});




}
/// @nodoc
class __$ChatSyncPayloadCopyWithImpl<$Res>
    implements _$ChatSyncPayloadCopyWith<$Res> {
  __$ChatSyncPayloadCopyWithImpl(this._self, this._then);

  final _ChatSyncPayload _self;
  final $Res Function(_ChatSyncPayload) _then;

/// Create a copy of ChatSyncPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? prompt = null,Object? pastUserInputs = null,Object? generatedResponses = null,Object? model = freezed,Object? clientMessageId = null,Object? createdAt = null,}) {
  return _then(_ChatSyncPayload(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,pastUserInputs: null == pastUserInputs ? _self._pastUserInputs : pastUserInputs // ignore: cast_nullable_to_non_nullable
as List<String>,generatedResponses: null == generatedResponses ? _self._generatedResponses : generatedResponses // ignore: cast_nullable_to_non_nullable
as List<String>,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: null == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
