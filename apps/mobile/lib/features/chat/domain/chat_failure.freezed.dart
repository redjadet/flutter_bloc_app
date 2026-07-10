// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatFailure {

 String get message; String? get l10nCode;
/// Create a copy of ChatFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatFailureCopyWith<ChatFailure> get copyWith => _$ChatFailureCopyWithImpl<ChatFailure>(this as ChatFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.l10nCode, l10nCode) || other.l10nCode == l10nCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,l10nCode);

@override
String toString() {
  return 'ChatFailure(message: $message, l10nCode: $l10nCode)';
}


}

/// @nodoc
abstract mixin class $ChatFailureCopyWith<$Res>  {
  factory $ChatFailureCopyWith(ChatFailure value, $Res Function(ChatFailure) _then) = _$ChatFailureCopyWithImpl;
@useResult
$Res call({
 String message, String? l10nCode
});




}
/// @nodoc
class _$ChatFailureCopyWithImpl<$Res>
    implements $ChatFailureCopyWith<$Res> {
  _$ChatFailureCopyWithImpl(this._self, this._then);

  final ChatFailure _self;
  final $Res Function(ChatFailure) _then;

/// Create a copy of ChatFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? l10nCode = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,l10nCode: freezed == l10nCode ? _self.l10nCode : l10nCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatFailure].
extension ChatFailurePatterns on ChatFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatFailure value)  $default,){
final _that = this;
switch (_that) {
case _ChatFailure():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatFailure value)?  $default,){
final _that = this;
switch (_that) {
case _ChatFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  String? l10nCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatFailure() when $default != null:
return $default(_that.message,_that.l10nCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  String? l10nCode)  $default,) {final _that = this;
switch (_that) {
case _ChatFailure():
return $default(_that.message,_that.l10nCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  String? l10nCode)?  $default,) {final _that = this;
switch (_that) {
case _ChatFailure() when $default != null:
return $default(_that.message,_that.l10nCode);case _:
  return null;

}
}

}

/// @nodoc


class _ChatFailure implements ChatFailure {
  const _ChatFailure({required this.message, this.l10nCode});
  

@override final  String message;
@override final  String? l10nCode;

/// Create a copy of ChatFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatFailureCopyWith<_ChatFailure> get copyWith => __$ChatFailureCopyWithImpl<_ChatFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.l10nCode, l10nCode) || other.l10nCode == l10nCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,l10nCode);

@override
String toString() {
  return 'ChatFailure(message: $message, l10nCode: $l10nCode)';
}


}

/// @nodoc
abstract mixin class _$ChatFailureCopyWith<$Res> implements $ChatFailureCopyWith<$Res> {
  factory _$ChatFailureCopyWith(_ChatFailure value, $Res Function(_ChatFailure) _then) = __$ChatFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, String? l10nCode
});




}
/// @nodoc
class __$ChatFailureCopyWithImpl<$Res>
    implements _$ChatFailureCopyWith<$Res> {
  __$ChatFailureCopyWithImpl(this._self, this._then);

  final _ChatFailure _self;
  final $Res Function(_ChatFailure) _then;

/// Create a copy of ChatFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? l10nCode = freezed,}) {
  return _then(_ChatFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,l10nCode: freezed == l10nCode ? _self.l10nCode : l10nCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
