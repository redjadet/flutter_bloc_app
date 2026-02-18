// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterFieldState {

 String get value; bool get isDirty;
/// Create a copy of RegisterFieldState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<RegisterFieldState> get copyWith => _$RegisterFieldStateCopyWithImpl<RegisterFieldState>(this as RegisterFieldState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterFieldState&&(identical(other.value, value) || other.value == value)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty));
}


@override
int get hashCode => Object.hash(runtimeType,value,isDirty);

@override
String toString() {
  return 'RegisterFieldState(value: $value, isDirty: $isDirty)';
}


}

/// @nodoc
abstract mixin class $RegisterFieldStateCopyWith<$Res>  {
  factory $RegisterFieldStateCopyWith(RegisterFieldState value, $Res Function(RegisterFieldState) _then) = _$RegisterFieldStateCopyWithImpl;
@useResult
$Res call({
 String value, bool isDirty
});




}
/// @nodoc
class _$RegisterFieldStateCopyWithImpl<$Res>
    implements $RegisterFieldStateCopyWith<$Res> {
  _$RegisterFieldStateCopyWithImpl(this._self, this._then);

  final RegisterFieldState _self;
  final $Res Function(RegisterFieldState) _then;

/// Create a copy of RegisterFieldState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? isDirty = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterFieldState].
extension RegisterFieldStatePatterns on RegisterFieldState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterFieldState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterFieldState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterFieldState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterFieldState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterFieldState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterFieldState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  bool isDirty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterFieldState() when $default != null:
return $default(_that.value,_that.isDirty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  bool isDirty)  $default,) {final _that = this;
switch (_that) {
case _RegisterFieldState():
return $default(_that.value,_that.isDirty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  bool isDirty)?  $default,) {final _that = this;
switch (_that) {
case _RegisterFieldState() when $default != null:
return $default(_that.value,_that.isDirty);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterFieldState extends RegisterFieldState {
  const _RegisterFieldState({this.value = '', this.isDirty = false}): super._();
  

@override@JsonKey() final  String value;
@override@JsonKey() final  bool isDirty;

/// Create a copy of RegisterFieldState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterFieldStateCopyWith<_RegisterFieldState> get copyWith => __$RegisterFieldStateCopyWithImpl<_RegisterFieldState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterFieldState&&(identical(other.value, value) || other.value == value)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty));
}


@override
int get hashCode => Object.hash(runtimeType,value,isDirty);

@override
String toString() {
  return 'RegisterFieldState(value: $value, isDirty: $isDirty)';
}


}

/// @nodoc
abstract mixin class _$RegisterFieldStateCopyWith<$Res> implements $RegisterFieldStateCopyWith<$Res> {
  factory _$RegisterFieldStateCopyWith(_RegisterFieldState value, $Res Function(_RegisterFieldState) _then) = __$RegisterFieldStateCopyWithImpl;
@override @useResult
$Res call({
 String value, bool isDirty
});




}
/// @nodoc
class __$RegisterFieldStateCopyWithImpl<$Res>
    implements _$RegisterFieldStateCopyWith<$Res> {
  __$RegisterFieldStateCopyWithImpl(this._self, this._then);

  final _RegisterFieldState _self;
  final $Res Function(_RegisterFieldState) _then;

/// Create a copy of RegisterFieldState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? isDirty = null,}) {
  return _then(_RegisterFieldState(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RegisterState {

 RegisterFieldState get fullName; RegisterFieldState get email; RegisterFieldState get password; RegisterFieldState get confirmPassword; RegisterFieldState get phoneNumber; CountryOption get selectedCountry; bool get showErrors; RegisterSubmissionStatus get submissionStatus; bool get hasViewedTerms; bool get acceptedTerms;
/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterStateCopyWith<RegisterState> get copyWith => _$RegisterStateCopyWithImpl<RegisterState>(this as RegisterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterState&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors)&&(identical(other.submissionStatus, submissionStatus) || other.submissionStatus == submissionStatus)&&(identical(other.hasViewedTerms, hasViewedTerms) || other.hasViewedTerms == hasViewedTerms)&&(identical(other.acceptedTerms, acceptedTerms) || other.acceptedTerms == acceptedTerms));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,email,password,confirmPassword,phoneNumber,selectedCountry,showErrors,submissionStatus,hasViewedTerms,acceptedTerms);

@override
String toString() {
  return 'RegisterState(fullName: $fullName, email: $email, password: $password, confirmPassword: $confirmPassword, phoneNumber: $phoneNumber, selectedCountry: $selectedCountry, showErrors: $showErrors, submissionStatus: $submissionStatus, hasViewedTerms: $hasViewedTerms, acceptedTerms: $acceptedTerms)';
}


}

/// @nodoc
abstract mixin class $RegisterStateCopyWith<$Res>  {
  factory $RegisterStateCopyWith(RegisterState value, $Res Function(RegisterState) _then) = _$RegisterStateCopyWithImpl;
@useResult
$Res call({
 RegisterFieldState fullName, RegisterFieldState email, RegisterFieldState password, RegisterFieldState confirmPassword, RegisterFieldState phoneNumber, CountryOption selectedCountry, bool showErrors, RegisterSubmissionStatus submissionStatus, bool hasViewedTerms, bool acceptedTerms
});


$RegisterFieldStateCopyWith<$Res> get fullName;$RegisterFieldStateCopyWith<$Res> get email;$RegisterFieldStateCopyWith<$Res> get password;$RegisterFieldStateCopyWith<$Res> get confirmPassword;$RegisterFieldStateCopyWith<$Res> get phoneNumber;$CountryOptionCopyWith<$Res> get selectedCountry;

}
/// @nodoc
class _$RegisterStateCopyWithImpl<$Res>
    implements $RegisterStateCopyWith<$Res> {
  _$RegisterStateCopyWithImpl(this._self, this._then);

  final RegisterState _self;
  final $Res Function(RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? email = null,Object? password = null,Object? confirmPassword = null,Object? phoneNumber = null,Object? selectedCountry = null,Object? showErrors = null,Object? submissionStatus = null,Object? hasViewedTerms = null,Object? acceptedTerms = null,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,selectedCountry: null == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as CountryOption,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,submissionStatus: null == submissionStatus ? _self.submissionStatus : submissionStatus // ignore: cast_nullable_to_non_nullable
as RegisterSubmissionStatus,hasViewedTerms: null == hasViewedTerms ? _self.hasViewedTerms : hasViewedTerms // ignore: cast_nullable_to_non_nullable
as bool,acceptedTerms: null == acceptedTerms ? _self.acceptedTerms : acceptedTerms // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get fullName {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.fullName, (value) {
    return _then(_self.copyWith(fullName: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get email {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get password {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get confirmPassword {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.confirmPassword, (value) {
    return _then(_self.copyWith(confirmPassword: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get phoneNumber {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.phoneNumber, (value) {
    return _then(_self.copyWith(phoneNumber: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryOptionCopyWith<$Res> get selectedCountry {
  
  return $CountryOptionCopyWith<$Res>(_self.selectedCountry, (value) {
    return _then(_self.copyWith(selectedCountry: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegisterState].
extension RegisterStatePatterns on RegisterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegisterFieldState fullName,  RegisterFieldState email,  RegisterFieldState password,  RegisterFieldState confirmPassword,  RegisterFieldState phoneNumber,  CountryOption selectedCountry,  bool showErrors,  RegisterSubmissionStatus submissionStatus,  bool hasViewedTerms,  bool acceptedTerms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.fullName,_that.email,_that.password,_that.confirmPassword,_that.phoneNumber,_that.selectedCountry,_that.showErrors,_that.submissionStatus,_that.hasViewedTerms,_that.acceptedTerms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegisterFieldState fullName,  RegisterFieldState email,  RegisterFieldState password,  RegisterFieldState confirmPassword,  RegisterFieldState phoneNumber,  CountryOption selectedCountry,  bool showErrors,  RegisterSubmissionStatus submissionStatus,  bool hasViewedTerms,  bool acceptedTerms)  $default,) {final _that = this;
switch (_that) {
case _RegisterState():
return $default(_that.fullName,_that.email,_that.password,_that.confirmPassword,_that.phoneNumber,_that.selectedCountry,_that.showErrors,_that.submissionStatus,_that.hasViewedTerms,_that.acceptedTerms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegisterFieldState fullName,  RegisterFieldState email,  RegisterFieldState password,  RegisterFieldState confirmPassword,  RegisterFieldState phoneNumber,  CountryOption selectedCountry,  bool showErrors,  RegisterSubmissionStatus submissionStatus,  bool hasViewedTerms,  bool acceptedTerms)?  $default,) {final _that = this;
switch (_that) {
case _RegisterState() when $default != null:
return $default(_that.fullName,_that.email,_that.password,_that.confirmPassword,_that.phoneNumber,_that.selectedCountry,_that.showErrors,_that.submissionStatus,_that.hasViewedTerms,_that.acceptedTerms);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterState extends RegisterState {
  const _RegisterState({this.fullName = const RegisterFieldState(), this.email = const RegisterFieldState(), this.password = const RegisterFieldState(), this.confirmPassword = const RegisterFieldState(), this.phoneNumber = const RegisterFieldState(), this.selectedCountry = CountryOption.defaultCountry, this.showErrors = false, this.submissionStatus = RegisterSubmissionStatus.initial, this.hasViewedTerms = false, this.acceptedTerms = false}): super._();
  

@override@JsonKey() final  RegisterFieldState fullName;
@override@JsonKey() final  RegisterFieldState email;
@override@JsonKey() final  RegisterFieldState password;
@override@JsonKey() final  RegisterFieldState confirmPassword;
@override@JsonKey() final  RegisterFieldState phoneNumber;
@override@JsonKey() final  CountryOption selectedCountry;
@override@JsonKey() final  bool showErrors;
@override@JsonKey() final  RegisterSubmissionStatus submissionStatus;
@override@JsonKey() final  bool hasViewedTerms;
@override@JsonKey() final  bool acceptedTerms;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterStateCopyWith<_RegisterState> get copyWith => __$RegisterStateCopyWithImpl<_RegisterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterState&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors)&&(identical(other.submissionStatus, submissionStatus) || other.submissionStatus == submissionStatus)&&(identical(other.hasViewedTerms, hasViewedTerms) || other.hasViewedTerms == hasViewedTerms)&&(identical(other.acceptedTerms, acceptedTerms) || other.acceptedTerms == acceptedTerms));
}


@override
int get hashCode => Object.hash(runtimeType,fullName,email,password,confirmPassword,phoneNumber,selectedCountry,showErrors,submissionStatus,hasViewedTerms,acceptedTerms);

@override
String toString() {
  return 'RegisterState(fullName: $fullName, email: $email, password: $password, confirmPassword: $confirmPassword, phoneNumber: $phoneNumber, selectedCountry: $selectedCountry, showErrors: $showErrors, submissionStatus: $submissionStatus, hasViewedTerms: $hasViewedTerms, acceptedTerms: $acceptedTerms)';
}


}

/// @nodoc
abstract mixin class _$RegisterStateCopyWith<$Res> implements $RegisterStateCopyWith<$Res> {
  factory _$RegisterStateCopyWith(_RegisterState value, $Res Function(_RegisterState) _then) = __$RegisterStateCopyWithImpl;
@override @useResult
$Res call({
 RegisterFieldState fullName, RegisterFieldState email, RegisterFieldState password, RegisterFieldState confirmPassword, RegisterFieldState phoneNumber, CountryOption selectedCountry, bool showErrors, RegisterSubmissionStatus submissionStatus, bool hasViewedTerms, bool acceptedTerms
});


@override $RegisterFieldStateCopyWith<$Res> get fullName;@override $RegisterFieldStateCopyWith<$Res> get email;@override $RegisterFieldStateCopyWith<$Res> get password;@override $RegisterFieldStateCopyWith<$Res> get confirmPassword;@override $RegisterFieldStateCopyWith<$Res> get phoneNumber;@override $CountryOptionCopyWith<$Res> get selectedCountry;

}
/// @nodoc
class __$RegisterStateCopyWithImpl<$Res>
    implements _$RegisterStateCopyWith<$Res> {
  __$RegisterStateCopyWithImpl(this._self, this._then);

  final _RegisterState _self;
  final $Res Function(_RegisterState) _then;

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? email = null,Object? password = null,Object? confirmPassword = null,Object? phoneNumber = null,Object? selectedCountry = null,Object? showErrors = null,Object? submissionStatus = null,Object? hasViewedTerms = null,Object? acceptedTerms = null,}) {
  return _then(_RegisterState(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as RegisterFieldState,selectedCountry: null == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as CountryOption,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,submissionStatus: null == submissionStatus ? _self.submissionStatus : submissionStatus // ignore: cast_nullable_to_non_nullable
as RegisterSubmissionStatus,hasViewedTerms: null == hasViewedTerms ? _self.hasViewedTerms : hasViewedTerms // ignore: cast_nullable_to_non_nullable
as bool,acceptedTerms: null == acceptedTerms ? _self.acceptedTerms : acceptedTerms // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get fullName {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.fullName, (value) {
    return _then(_self.copyWith(fullName: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get email {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get password {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get confirmPassword {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.confirmPassword, (value) {
    return _then(_self.copyWith(confirmPassword: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterFieldStateCopyWith<$Res> get phoneNumber {
  
  return $RegisterFieldStateCopyWith<$Res>(_self.phoneNumber, (value) {
    return _then(_self.copyWith(phoneNumber: value));
  });
}/// Create a copy of RegisterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryOptionCopyWith<$Res> get selectedCountry {
  
  return $CountryOptionCopyWith<$Res>(_self.selectedCountry, (value) {
    return _then(_self.copyWith(selectedCountry: value));
  });
}
}

// dart format on
