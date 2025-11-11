import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RegisterCubit cubit;

  setUp(() {
    cubit = RegisterCubit();
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is default RegisterState', () {
    expect(cubit.state, const RegisterState());
  });

  test('fullNameChanged updates value and resets submission status', () {
    cubit
      ..submit()
      ..fullNameChanged('Jane Doe');

    expect(cubit.state.fullName.value, 'Jane Doe');
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.initial);
  });

  test('submit with empty fields yields validation errors', () {
    cubit.submit();

    expect(cubit.state.showErrors, isTrue);
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.failure);
    expect(cubit.state.fullNameError, isNotNull);
    expect(cubit.state.emailError, isNotNull);
    expect(cubit.state.passwordError, isNotNull);
    expect(cubit.state.confirmPasswordError, isNotNull);
    expect(cubit.state.phoneError, isNotNull);
  });

  test('submit with valid fields emits success status', () {
    cubit
      ..fullNameChanged('Jane Doe')
      ..emailChanged('jane.doe@example.com')
      ..phoneChanged('5551234567')
      ..passwordChanged('Password1')
      ..confirmPasswordChanged('Password1')
      ..markTermsViewed();
    cubit.termsAcceptanceChanged(accepted: true);

    cubit.submit();

    expect(cubit.state.isValid, isTrue);
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.success);
  });

  test('password with whitespace fails validation', () {
    cubit
      ..fullNameChanged('Jane Doe')
      ..emailChanged('jane.doe@example.com')
      ..phoneChanged('5551234567')
      ..passwordChanged('Pass word1')
      ..confirmPasswordChanged('Pass word1')
      ..markTermsViewed();
    cubit.termsAcceptanceChanged(accepted: true);

    cubit.submit();

    expect(cubit.state.passwordError, RegisterPasswordError.whitespace);
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.failure);
  });

  test('phone accepts formatted number characters and normalizes digits', () {
    cubit
      ..fullNameChanged('Jane Doe')
      ..emailChanged('jane.doe@example.com')
      ..phoneChanged('(555) 123-4567')
      ..passwordChanged('Password1')
      ..confirmPasswordChanged('Password1')
      ..markTermsViewed();
    cubit.termsAcceptanceChanged(accepted: true);

    cubit.submit();

    expect(cubit.state.phoneError, isNull);
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.success);
  });

  test('confirm password trims whitespace edges before comparison', () {
    cubit
      ..fullNameChanged('Jane Doe')
      ..emailChanged('jane.doe@example.com')
      ..phoneChanged('5551234567')
      ..passwordChanged('Password1')
      ..confirmPasswordChanged('  Password1  ')
      ..markTermsViewed();
    cubit.termsAcceptanceChanged(accepted: true);

    cubit.submit();

    expect(cubit.state.confirmPasswordError, isNull);
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.success);
  });

  test('countrySelected updates selected country', () {
    final CountryOption target = kSupportedCountries.last;
    cubit.countrySelected(target);

    expect(cubit.state.selectedCountry, target);
  });

  test('resetSubmissionStatus clears success', () {
    cubit
      ..fullNameChanged('Jane Doe')
      ..emailChanged('jane.doe@example.com')
      ..phoneChanged('5551234567')
      ..passwordChanged('Password1')
      ..confirmPasswordChanged('Password1')
      ..markTermsViewed();
    cubit.termsAcceptanceChanged(accepted: true);

    cubit.submit();
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.success);

    cubit.resetSubmissionStatus();
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.initial);
  });

  test('cannot accept terms before viewing them', () {
    cubit.termsAcceptanceChanged(accepted: true);

    expect(cubit.state.acceptedTerms, isFalse);
  });

  test('submit fails when terms are not accepted', () {
    cubit
      ..fullNameChanged('Jane Doe')
      ..emailChanged('jane.doe@example.com')
      ..phoneChanged('5551234567')
      ..passwordChanged('Password1')
      ..confirmPasswordChanged('Password1')
      ..markTermsViewed();

    cubit.submit();

    expect(cubit.state.termsAcceptanceError, isTrue);
    expect(cubit.state.submissionStatus, RegisterSubmissionStatus.failure);
  });

  test('markTermsViewed sets hasViewedTerms flag', () {
    expect(cubit.state.hasViewedTerms, isFalse);
    cubit.markTermsViewed();
    expect(cubit.state.hasViewedTerms, isTrue);
  });
}
