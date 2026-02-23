// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchBodyData {

 bool get isLoading; bool get isError; bool get hasResults; List<SearchResult> get results;
/// Create a copy of _SearchBodyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchBodyDataCopyWith<_SearchBodyData> get copyWith => __$SearchBodyDataCopyWithImpl<_SearchBodyData>(this as _SearchBodyData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchBodyData&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.hasResults, hasResults) || other.hasResults == hasResults)&&const DeepCollectionEquality().equals(other.results, results));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isError,hasResults,const DeepCollectionEquality().hash(results));

@override
String toString() {
  return '_SearchBodyData(isLoading: $isLoading, isError: $isError, hasResults: $hasResults, results: $results)';
}


}

/// @nodoc
abstract mixin class _$SearchBodyDataCopyWith<$Res>  {
  factory _$SearchBodyDataCopyWith(_SearchBodyData value, $Res Function(_SearchBodyData) _then) = __$SearchBodyDataCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isError, bool hasResults, List<SearchResult> results
});




}
/// @nodoc
class __$SearchBodyDataCopyWithImpl<$Res>
    implements _$SearchBodyDataCopyWith<$Res> {
  __$SearchBodyDataCopyWithImpl(this._self, this._then);

  final _SearchBodyData _self;
  final $Res Function(_SearchBodyData) _then;

/// Create a copy of _SearchBodyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isError = null,Object? hasResults = null,Object? results = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,hasResults: null == hasResults ? _self.hasResults : hasResults // ignore: cast_nullable_to_non_nullable
as bool,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,
  ));
}

}


/// Adds pattern-matching-related methods to [_SearchBodyData].
extension _SearchBodyDataPatterns on _SearchBodyData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __SearchBodyData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __SearchBodyData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __SearchBodyData value)  $default,){
final _that = this;
switch (_that) {
case __SearchBodyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __SearchBodyData value)?  $default,){
final _that = this;
switch (_that) {
case __SearchBodyData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isError,  bool hasResults,  List<SearchResult> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __SearchBodyData() when $default != null:
return $default(_that.isLoading,_that.isError,_that.hasResults,_that.results);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isError,  bool hasResults,  List<SearchResult> results)  $default,) {final _that = this;
switch (_that) {
case __SearchBodyData():
return $default(_that.isLoading,_that.isError,_that.hasResults,_that.results);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isError,  bool hasResults,  List<SearchResult> results)?  $default,) {final _that = this;
switch (_that) {
case __SearchBodyData() when $default != null:
return $default(_that.isLoading,_that.isError,_that.hasResults,_that.results);case _:
  return null;

}
}

}

/// @nodoc


class __SearchBodyData implements _SearchBodyData {
  const __SearchBodyData({required this.isLoading, required this.isError, required this.hasResults, required final  List<SearchResult> results}): _results = results;
  

@override final  bool isLoading;
@override final  bool isError;
@override final  bool hasResults;
 final  List<SearchResult> _results;
@override List<SearchResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of _SearchBodyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_SearchBodyDataCopyWith<__SearchBodyData> get copyWith => __$_SearchBodyDataCopyWithImpl<__SearchBodyData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __SearchBodyData&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.hasResults, hasResults) || other.hasResults == hasResults)&&const DeepCollectionEquality().equals(other._results, _results));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isError,hasResults,const DeepCollectionEquality().hash(_results));

@override
String toString() {
  return '_SearchBodyData(isLoading: $isLoading, isError: $isError, hasResults: $hasResults, results: $results)';
}


}

/// @nodoc
abstract mixin class _$_SearchBodyDataCopyWith<$Res> implements _$SearchBodyDataCopyWith<$Res> {
  factory _$_SearchBodyDataCopyWith(__SearchBodyData value, $Res Function(__SearchBodyData) _then) = __$_SearchBodyDataCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isError, bool hasResults, List<SearchResult> results
});




}
/// @nodoc
class __$_SearchBodyDataCopyWithImpl<$Res>
    implements _$_SearchBodyDataCopyWith<$Res> {
  __$_SearchBodyDataCopyWithImpl(this._self, this._then);

  final __SearchBodyData _self;
  final $Res Function(__SearchBodyData) _then;

/// Create a copy of _SearchBodyData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isError = null,Object? hasResults = null,Object? results = null,}) {
  return _then(__SearchBodyData(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,hasResults: null == hasResults ? _self.hasResults : hasResults // ignore: cast_nullable_to_non_nullable
as bool,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,
  ));
}


}

// dart format on
