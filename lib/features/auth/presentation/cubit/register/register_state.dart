import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_country_option.dart';

enum RegisterSubmissionStatus { initial, success, failure }

enum RegisterFullNameError { empty, tooShort }

enum RegisterEmailError { empty, invalid }

enum RegisterPasswordError { empty, tooShort, lettersAndNumbers, whitespace }

enum RegisterConfirmPasswordError { empty, mismatch }

enum RegisterPhoneError { empty, invalid }

class RegisterState extends Equatable {
  const RegisterState({
    this.fullName = const RegisterFieldState(),
    this.email = const RegisterFieldState(),
    this.password = const RegisterFieldState(),
    this.confirmPassword = const RegisterFieldState(),
    this.phoneNumber = const RegisterFieldState(),
    this.selectedCountry = CountryOption.defaultCountry,
    this.showErrors = false,
    this.submissionStatus = RegisterSubmissionStatus.initial,
    this.hasViewedTerms = false,
    this.acceptedTerms = false,
  });

  final RegisterFieldState fullName;
  final RegisterFieldState email;
  final RegisterFieldState password;
  final RegisterFieldState confirmPassword;
  final RegisterFieldState phoneNumber;
  final CountryOption selectedCountry;
  final bool showErrors;
  final RegisterSubmissionStatus submissionStatus;
  final bool hasViewedTerms;
  final bool acceptedTerms;

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

  RegisterState copyWith({
    final RegisterFieldState? fullName,
    final RegisterFieldState? email,
    final RegisterFieldState? password,
    final RegisterFieldState? confirmPassword,
    final RegisterFieldState? phoneNumber,
    final CountryOption? selectedCountry,
    final bool? showErrors,
    final RegisterSubmissionStatus? submissionStatus,
    final bool? hasViewedTerms,
    final bool? acceptedTerms,
  }) => RegisterState(
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    password: password ?? this.password,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    selectedCountry: selectedCountry ?? this.selectedCountry,
    showErrors: showErrors ?? this.showErrors,
    submissionStatus: submissionStatus ?? this.submissionStatus,
    hasViewedTerms: hasViewedTerms ?? this.hasViewedTerms,
    acceptedTerms: acceptedTerms ?? this.acceptedTerms,
  );

  @override
  List<Object> get props => <Object>[
    fullName,
    email,
    password,
    confirmPassword,
    phoneNumber,
    selectedCountry,
    showErrors,
    submissionStatus,
    hasViewedTerms,
    acceptedTerms,
  ];

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

class RegisterFieldState extends Equatable {
  const RegisterFieldState({this.value = '', this.isDirty = false});

  final String value;
  final bool isDirty;

  RegisterFieldState copyWith({final String? value, final bool? isDirty}) =>
      RegisterFieldState(
        value: value ?? this.value,
        isDirty: isDirty ?? this.isDirty,
      );

  RegisterFieldState update(final String value) =>
      copyWith(value: value, isDirty: true);

  @override
  List<Object> get props => <Object>[value, isDirty];
}
