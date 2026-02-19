// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_list_date_picker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DatePickerResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatePickerResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return '_DatePickerResult()';
}


}

/// @nodoc
class _$DatePickerResultCopyWith<$Res>  {
_$DatePickerResultCopyWith(_DatePickerResult _, $Res Function(_DatePickerResult) __);
}


/// Adds pattern-matching-related methods to [_DatePickerResult].
extension _DatePickerResultPatterns on _DatePickerResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DatePickerResultConfirmed value)?  confirmed,TResult Function( _DatePickerResultCleared value)?  cleared,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DatePickerResultConfirmed() when confirmed != null:
return confirmed(_that);case _DatePickerResultCleared() when cleared != null:
return cleared(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DatePickerResultConfirmed value)  confirmed,required TResult Function( _DatePickerResultCleared value)  cleared,}){
final _that = this;
switch (_that) {
case _DatePickerResultConfirmed():
return confirmed(_that);case _DatePickerResultCleared():
return cleared(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DatePickerResultConfirmed value)?  confirmed,TResult? Function( _DatePickerResultCleared value)?  cleared,}){
final _that = this;
switch (_that) {
case _DatePickerResultConfirmed() when confirmed != null:
return confirmed(_that);case _DatePickerResultCleared() when cleared != null:
return cleared(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime date)?  confirmed,TResult Function()?  cleared,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DatePickerResultConfirmed() when confirmed != null:
return confirmed(_that.date);case _DatePickerResultCleared() when cleared != null:
return cleared();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime date)  confirmed,required TResult Function()  cleared,}) {final _that = this;
switch (_that) {
case _DatePickerResultConfirmed():
return confirmed(_that.date);case _DatePickerResultCleared():
return cleared();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime date)?  confirmed,TResult? Function()?  cleared,}) {final _that = this;
switch (_that) {
case _DatePickerResultConfirmed() when confirmed != null:
return confirmed(_that.date);case _DatePickerResultCleared() when cleared != null:
return cleared();case _:
  return null;

}
}

}

/// @nodoc


class _DatePickerResultConfirmed extends _DatePickerResult {
  const _DatePickerResultConfirmed(this.date): super._();
  

 final  DateTime date;

/// Create a copy of _DatePickerResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DatePickerResultConfirmedCopyWith<_DatePickerResultConfirmed> get copyWith => __$DatePickerResultConfirmedCopyWithImpl<_DatePickerResultConfirmed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatePickerResultConfirmed&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,date);

@override
String toString() {
  return '_DatePickerResult.confirmed(date: $date)';
}


}

/// @nodoc
abstract mixin class _$DatePickerResultConfirmedCopyWith<$Res> implements _$DatePickerResultCopyWith<$Res> {
  factory _$DatePickerResultConfirmedCopyWith(_DatePickerResultConfirmed value, $Res Function(_DatePickerResultConfirmed) _then) = __$DatePickerResultConfirmedCopyWithImpl;
@useResult
$Res call({
 DateTime date
});




}
/// @nodoc
class __$DatePickerResultConfirmedCopyWithImpl<$Res>
    implements _$DatePickerResultConfirmedCopyWith<$Res> {
  __$DatePickerResultConfirmedCopyWithImpl(this._self, this._then);

  final _DatePickerResultConfirmed _self;
  final $Res Function(_DatePickerResultConfirmed) _then;

/// Create a copy of _DatePickerResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? date = null,}) {
  return _then(_DatePickerResultConfirmed(
null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class _DatePickerResultCleared extends _DatePickerResult {
  const _DatePickerResultCleared(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DatePickerResultCleared);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return '_DatePickerResult.cleared()';
}


}




// dart format on
