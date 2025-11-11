import 'package:equatable/equatable.dart';

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
    RegisterFieldState? fullName,
    RegisterFieldState? email,
    RegisterFieldState? password,
    RegisterFieldState? confirmPassword,
    RegisterFieldState? phoneNumber,
    CountryOption? selectedCountry,
    bool? showErrors,
    RegisterSubmissionStatus? submissionStatus,
    bool? hasViewedTerms,
    bool? acceptedTerms,
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

  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$',
  );

  RegisterEmailError? _validateEmail() {
    final String value = email.value.trim();
    if (value.isEmpty) {
      return RegisterEmailError.empty;
    }
    if (!_emailRegex.hasMatch(value)) {
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

class CountryOption extends Equatable {
  const CountryOption({
    required this.code,
    required this.name,
    required this.dialCode,
  });

  final String code;
  final String name;
  final String dialCode;

  String get flagEmoji {
    if (code.length != 2) {
      return '🏳️';
    }
    const int base = 0x1F1E6;
    const int alphaBase = 65;
    final List<int> chars = code
        .toUpperCase()
        .codeUnits
        .map((final int unit) => base + unit - alphaBase)
        .toList();
    return String.fromCharCodes(chars);
  }

  static const CountryOption defaultCountry = CountryOption(
    code: 'US',
    name: 'United States',
    dialCode: '+1',
  );

  @override
  List<Object> get props => <Object>[code, name, dialCode];
}

const List<CountryOption> kSupportedCountries = <CountryOption>[
  CountryOption.defaultCountry,
  CountryOption(code: 'CA', name: 'Canada', dialCode: '+1'),
  CountryOption(code: 'GB', name: 'United Kingdom', dialCode: '+44'),
  CountryOption(code: 'DE', name: 'Germany', dialCode: '+49'),
  CountryOption(code: 'FR', name: 'France', dialCode: '+33'),
  CountryOption(code: 'AU', name: 'Australia', dialCode: '+61'),
  CountryOption(code: 'IN', name: 'India', dialCode: '+91'),
  CountryOption(code: 'JP', name: 'Japan', dialCode: '+81'),
  CountryOption(code: 'CN', name: 'China', dialCode: '+86'),
  CountryOption(code: 'TR', name: 'Turkey', dialCode: '+90'),
  CountryOption(code: 'BR', name: 'Brazil', dialCode: '+55'),
  CountryOption(code: 'ZA', name: 'South Africa', dialCode: '+27'),
];
