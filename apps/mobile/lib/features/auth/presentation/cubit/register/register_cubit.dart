import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_country_option.dart';
import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';

/// Cubit for registration form state and submission.
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  void fullNameChanged(String value) {
    emit(
      state.copyWith(
        fullName: state.fullName.update(value),
        submissionStatus: RegisterSubmissionStatus.initial,
      ),
    );
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: state.email.update(value),
        submissionStatus: RegisterSubmissionStatus.initial,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: state.password.update(value),
        submissionStatus: RegisterSubmissionStatus.initial,
      ),
    );
  }

  void confirmPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmPassword: state.confirmPassword.update(value),
        submissionStatus: RegisterSubmissionStatus.initial,
      ),
    );
  }

  void phoneChanged(String value) {
    emit(
      state.copyWith(
        phoneNumber: state.phoneNumber.update(value),
        submissionStatus: RegisterSubmissionStatus.initial,
      ),
    );
  }

  void countrySelected(CountryOption country) {
    emit(
      state.copyWith(
        selectedCountry: country,
        submissionStatus: RegisterSubmissionStatus.initial,
      ),
    );
  }

  void markTermsViewed() {
    if (!state.hasViewedTerms) {
      emit(state.copyWith(hasViewedTerms: true));
    }
  }

  void termsAcceptanceChanged({required bool accepted}) {
    emit(
      state.copyWith(
        acceptedTerms: state.hasViewedTerms && accepted,
        submissionStatus: RegisterSubmissionStatus.initial,
      ),
    );
  }

  void submit() {
    final bool isValid = state.isValid;
    emit(
      state.copyWith(
        showErrors: true,
        submissionStatus: isValid
            ? RegisterSubmissionStatus.success
            : RegisterSubmissionStatus.failure,
      ),
    );
  }

  void resetSubmissionStatus() {
    if (state.submissionStatus != RegisterSubmissionStatus.initial) {
      emit(
        state.copyWith(submissionStatus: RegisterSubmissionStatus.initial),
      );
    }
  }
}
