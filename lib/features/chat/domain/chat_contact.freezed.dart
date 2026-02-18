// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatContact {

 String get id; String get name; String get lastMessage; String get profileImageUrl; DateTime get lastMessageTime; bool get isOnline; int get unreadCount;
/// Create a copy of ChatContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatContactCopyWith<ChatContact> get copyWith => _$ChatContactCopyWithImpl<ChatContact>(this as ChatContact, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatContact&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.lastMessageTime, lastMessageTime) || other.lastMessageTime == lastMessageTime)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,lastMessage,profileImageUrl,lastMessageTime,isOnline,unreadCount);

@override
String toString() {
  return 'ChatContact(id: $id, name: $name, lastMessage: $lastMessage, profileImageUrl: $profileImageUrl, lastMessageTime: $lastMessageTime, isOnline: $isOnline, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ChatContactCopyWith<$Res>  {
  factory $ChatContactCopyWith(ChatContact value, $Res Function(ChatContact) _then) = _$ChatContactCopyWithImpl;
@useResult
$Res call({
 String id, String name, String lastMessage, String profileImageUrl, DateTime lastMessageTime, bool isOnline, int unreadCount
});




}
/// @nodoc
class _$ChatContactCopyWithImpl<$Res>
    implements $ChatContactCopyWith<$Res> {
  _$ChatContactCopyWithImpl(this._self, this._then);

  final ChatContact _self;
  final $Res Function(ChatContact) _then;

/// Create a copy of ChatContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? lastMessage = null,Object? profileImageUrl = null,Object? lastMessageTime = null,Object? isOnline = null,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,lastMessageTime: null == lastMessageTime ? _self.lastMessageTime : lastMessageTime // ignore: cast_nullable_to_non_nullable
as DateTime,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatContact].
extension ChatContactPatterns on ChatContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatContact value)  $default,){
final _that = this;
switch (_that) {
case _ChatContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatContact value)?  $default,){
final _that = this;
switch (_that) {
case _ChatContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String lastMessage,  String profileImageUrl,  DateTime lastMessageTime,  bool isOnline,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatContact() when $default != null:
return $default(_that.id,_that.name,_that.lastMessage,_that.profileImageUrl,_that.lastMessageTime,_that.isOnline,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String lastMessage,  String profileImageUrl,  DateTime lastMessageTime,  bool isOnline,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _ChatContact():
return $default(_that.id,_that.name,_that.lastMessage,_that.profileImageUrl,_that.lastMessageTime,_that.isOnline,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String lastMessage,  String profileImageUrl,  DateTime lastMessageTime,  bool isOnline,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _ChatContact() when $default != null:
return $default(_that.id,_that.name,_that.lastMessage,_that.profileImageUrl,_that.lastMessageTime,_that.isOnline,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc


class _ChatContact implements ChatContact {
  const _ChatContact({required this.id, required this.name, required this.lastMessage, required this.profileImageUrl, required this.lastMessageTime, this.isOnline = false, this.unreadCount = 0});
  

@override final  String id;
@override final  String name;
@override final  String lastMessage;
@override final  String profileImageUrl;
@override final  DateTime lastMessageTime;
@override@JsonKey() final  bool isOnline;
@override@JsonKey() final  int unreadCount;

/// Create a copy of ChatContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatContactCopyWith<_ChatContact> get copyWith => __$ChatContactCopyWithImpl<_ChatContact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatContact&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.lastMessageTime, lastMessageTime) || other.lastMessageTime == lastMessageTime)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,lastMessage,profileImageUrl,lastMessageTime,isOnline,unreadCount);

@override
String toString() {
  return 'ChatContact(id: $id, name: $name, lastMessage: $lastMessage, profileImageUrl: $profileImageUrl, lastMessageTime: $lastMessageTime, isOnline: $isOnline, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ChatContactCopyWith<$Res> implements $ChatContactCopyWith<$Res> {
  factory _$ChatContactCopyWith(_ChatContact value, $Res Function(_ChatContact) _then) = __$ChatContactCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String lastMessage, String profileImageUrl, DateTime lastMessageTime, bool isOnline, int unreadCount
});




}
/// @nodoc
class __$ChatContactCopyWithImpl<$Res>
    implements _$ChatContactCopyWith<$Res> {
  __$ChatContactCopyWithImpl(this._self, this._then);

  final _ChatContact _self;
  final $Res Function(_ChatContact) _then;

/// Create a copy of ChatContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? lastMessage = null,Object? profileImageUrl = null,Object? lastMessageTime = null,Object? isOnline = null,Object? unreadCount = null,}) {
  return _then(_ChatContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,lastMessageTime: null == lastMessageTime ? _self.lastMessageTime : lastMessageTime // ignore: cast_nullable_to_non_nullable
as DateTime,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
