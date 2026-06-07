import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String? fullNameErrorText(
  final AppLocalizations l10n,
  final RegisterFullNameError? error,
) => switch (error) {
  RegisterFullNameError.empty => l10n.registerFullNameEmptyError,
  RegisterFullNameError.tooShort => l10n.registerFullNameTooShortError,
  null => null,
};

String? emailErrorText(
  final AppLocalizations l10n,
  final RegisterEmailError? error,
) => switch (error) {
  RegisterEmailError.empty => l10n.registerEmailEmptyError,
  RegisterEmailError.invalid => l10n.registerEmailInvalidError,
  null => null,
};

String? passwordErrorText(
  final AppLocalizations l10n,
  final RegisterPasswordError? error,
) => switch (error) {
  RegisterPasswordError.empty => l10n.registerPasswordEmptyError,
  RegisterPasswordError.tooShort => l10n.registerPasswordTooShortError,
  RegisterPasswordError.lettersAndNumbers =>
    l10n.registerPasswordLettersAndNumbersError,
  RegisterPasswordError.whitespace => l10n.registerPasswordWhitespaceError,
  null => null,
};

String? confirmPasswordErrorText(
  final AppLocalizations l10n,
  final RegisterConfirmPasswordError? error,
) => switch (error) {
  RegisterConfirmPasswordError.empty => l10n.registerConfirmPasswordEmptyError,
  RegisterConfirmPasswordError.mismatch =>
    l10n.registerConfirmPasswordMismatchError,
  null => null,
};

String? phoneErrorText(
  final AppLocalizations l10n,
  final RegisterPhoneError? error,
) => switch (error) {
  RegisterPhoneError.empty => l10n.registerPhoneEmptyError,
  RegisterPhoneError.invalid => l10n.registerPhoneInvalidError,
  null => null,
};
