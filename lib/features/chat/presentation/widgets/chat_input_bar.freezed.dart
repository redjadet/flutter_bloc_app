// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_input_bar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SendButtonData {

 bool get canSend; bool get isLoading;
/// Create a copy of _SendButtonData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendButtonDataCopyWith<_SendButtonData> get copyWith => __$SendButtonDataCopyWithImpl<_SendButtonData>(this as _SendButtonData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendButtonData&&(identical(other.canSend, canSend) || other.canSend == canSend)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,canSend,isLoading);

@override
String toString() {
  return '_SendButtonData(canSend: $canSend, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$SendButtonDataCopyWith<$Res>  {
  factory _$SendButtonDataCopyWith(_SendButtonData value, $Res Function(_SendButtonData) _then) = __$SendButtonDataCopyWithImpl;
@useResult
$Res call({
 bool canSend, bool isLoading
});




}
/// @nodoc
class __$SendButtonDataCopyWithImpl<$Res>
    implements _$SendButtonDataCopyWith<$Res> {
  __$SendButtonDataCopyWithImpl(this._self, this._then);

  final _SendButtonData _self;
  final $Res Function(_SendButtonData) _then;

/// Create a copy of _SendButtonData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canSend = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
canSend: null == canSend ? _self.canSend : canSend // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [_SendButtonData].
extension _SendButtonDataPatterns on _SendButtonData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __SendButtonData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __SendButtonData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __SendButtonData value)  $default,){
final _that = this;
switch (_that) {
case __SendButtonData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __SendButtonData value)?  $default,){
final _that = this;
switch (_that) {
case __SendButtonData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canSend,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __SendButtonData() when $default != null:
return $default(_that.canSend,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canSend,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case __SendButtonData():
return $default(_that.canSend,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canSend,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case __SendButtonData() when $default != null:
return $default(_that.canSend,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class __SendButtonData implements _SendButtonData {
  const __SendButtonData({required this.canSend, required this.isLoading});
  

@override final  bool canSend;
@override final  bool isLoading;

/// Create a copy of _SendButtonData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_SendButtonDataCopyWith<__SendButtonData> get copyWith => __$_SendButtonDataCopyWithImpl<__SendButtonData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __SendButtonData&&(identical(other.canSend, canSend) || other.canSend == canSend)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,canSend,isLoading);

@override
String toString() {
  return '_SendButtonData(canSend: $canSend, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$_SendButtonDataCopyWith<$Res> implements _$SendButtonDataCopyWith<$Res> {
  factory _$_SendButtonDataCopyWith(__SendButtonData value, $Res Function(__SendButtonData) _then) = __$_SendButtonDataCopyWithImpl;
@override @useResult
$Res call({
 bool canSend, bool isLoading
});




}
/// @nodoc
class __$_SendButtonDataCopyWithImpl<$Res>
    implements _$_SendButtonDataCopyWith<$Res> {
  __$_SendButtonDataCopyWithImpl(this._self, this._then);

  final __SendButtonData _self;
  final $Res Function(__SendButtonData) _then;

/// Create a copy of _SendButtonData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canSend = null,Object? isLoading = null,}) {
  return _then(__SendButtonData(
canSend: null == canSend ? _self.canSend : canSend // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
