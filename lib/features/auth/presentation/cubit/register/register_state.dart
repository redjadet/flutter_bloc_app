import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_country_option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

enum RegisterSubmissionStatus { initial, success, failure }

enum RegisterFullNameError { empty, tooShort }

enum RegisterEmailError { empty, invalid }

enum RegisterPasswordError { empty, tooShort, lettersAndNumbers, whitespace }

enum RegisterConfirmPasswordError { empty, mismatch }

enum RegisterPhoneError { empty, invalid }

@freezed
abstract class RegisterFieldState with _$RegisterFieldState {
  const factory RegisterFieldState({
    @Default('') final String value,
    @Default(false) final bool isDirty,
  }) = _RegisterFieldState;

  const RegisterFieldState._();

  RegisterFieldState update(final String value) =>
      copyWith(value: value, isDirty: true);
}

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(RegisterFieldState()) final RegisterFieldState fullName,
    @Default(RegisterFieldState()) final RegisterFieldState email,
    @Default(RegisterFieldState()) final RegisterFieldState password,
    @Default(RegisterFieldState()) final RegisterFieldState confirmPassword,
    @Default(RegisterFieldState()) final RegisterFieldState phoneNumber,
    @Default(CountryOption.defaultCountry) final CountryOption selectedCountry,
    @Default(false) final bool showErrors,
    @Default(RegisterSubmissionStatus.initial)
    final RegisterSubmissionStatus submissionStatus,
    @Default(false) final bool hasViewedTerms,
    @Default(false) final bool acceptedTerms,
  }) = _RegisterState;

  const RegisterState._();

  bool get isValid =>
      _validateFullName() == null &&
      _validateEmail() == null &&
      _validatePassword() == null &&
      _validateConfirmPassword() == null &&
      _validatePhoneNumber() == null &&
      acceptedTerms;

  RegisterFullNameError? get fullNameError =>
      _shouldShowError(fullName) ? _validateFullName() : null;
  RegisterEmailError? get emailError =>
      _shouldShowError(email) ? _validateEmail() : null;
  RegisterPasswordError? get passwordError =>
      _shouldShowError(password) ? _validatePassword() : null;
  RegisterConfirmPasswordError? get confirmPasswordError =>
      _shouldShowError(confirmPassword) ? _validateConfirmPassword() : null;
  RegisterPhoneError? get phoneError =>
      _shouldShowError(phoneNumber) ? _validatePhoneNumber() : null;
  bool get termsAcceptanceError => showErrors && !acceptedTerms;

  bool _shouldShowError(final RegisterFieldState field) =>
      showErrors || field.isDirty;

  RegisterFullNameError? _validateFullName() {
    final String value = fullName.value.trim();
    if (value.isEmpty) {
      return RegisterFullNameError.empty;
    }
    if (value.length < 2) {
      return RegisterFullNameError.tooShort;
    }
    return null;
  }

  static final Pattern _emailRegex = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$',
  );

  RegisterEmailError? _validateEmail() {
    final String value = email.value.trim();
    if (value.isEmpty) {
      return RegisterEmailError.empty;
    }
    if (!(_emailRegex as RegExp).hasMatch(value)) {
      return RegisterEmailError.invalid;
    }
    return null;
  }

  RegisterPasswordError? _validatePassword() {
    final String value = password.value;
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return RegisterPasswordError.empty;
    }
    if (trimmed.length < 8) {
      return RegisterPasswordError.tooShort;
    }
    if (RegExp(r'\s').hasMatch(value)) {
      return RegisterPasswordError.whitespace;
    }
    final bool hasLetter = RegExp('[A-Za-z]').hasMatch(value);
    final bool hasDigit = RegExp(r'\d').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return RegisterPasswordError.lettersAndNumbers;
    }
    return null;
  }

  RegisterConfirmPasswordError? _validateConfirmPassword() {
    final String value = confirmPassword.value.trim();
    if (value.isEmpty) {
      return RegisterConfirmPasswordError.empty;
    }
    if (value != password.value.trim()) {
      return RegisterConfirmPasswordError.mismatch;
    }
    return null;
  }

  RegisterPhoneError? _validatePhoneNumber() {
    final String rawValue = phoneNumber.value;
    if (rawValue.trim().isEmpty) {
      return RegisterPhoneError.empty;
    }
    final String normalized = rawValue.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\d{6,15}$').hasMatch(normalized)) {
      return RegisterPhoneError.invalid;
    }
    return null;
  }
}
