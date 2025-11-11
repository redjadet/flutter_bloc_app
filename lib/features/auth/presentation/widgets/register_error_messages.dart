import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String? fullNameErrorText(
  final AppLocalizations l10n,
  final RegisterFullNameError? error,
) {
  switch (error) {
    case RegisterFullNameError.empty:
      return l10n.registerFullNameEmptyError;
    case RegisterFullNameError.tooShort:
      return l10n.registerFullNameTooShortError;
    case null:
      return null;
  }
}

String? emailErrorText(
  final AppLocalizations l10n,
  final RegisterEmailError? error,
) {
  switch (error) {
    case RegisterEmailError.empty:
      return l10n.registerEmailEmptyError;
    case RegisterEmailError.invalid:
      return l10n.registerEmailInvalidError;
    case null:
      return null;
  }
}

String? passwordErrorText(
  final AppLocalizations l10n,
  final RegisterPasswordError? error,
) {
  switch (error) {
    case RegisterPasswordError.empty:
      return l10n.registerPasswordEmptyError;
    case RegisterPasswordError.tooShort:
      return l10n.registerPasswordTooShortError;
    case RegisterPasswordError.lettersAndNumbers:
      return l10n.registerPasswordLettersAndNumbersError;
    case RegisterPasswordError.whitespace:
      return l10n.registerPasswordWhitespaceError;
    case null:
      return null;
  }
}

String? confirmPasswordErrorText(
  final AppLocalizations l10n,
  final RegisterConfirmPasswordError? error,
) {
  switch (error) {
    case RegisterConfirmPasswordError.empty:
      return l10n.registerConfirmPasswordEmptyError;
    case RegisterConfirmPasswordError.mismatch:
      return l10n.registerConfirmPasswordMismatchError;
    case null:
      return null;
  }
}

String? phoneErrorText(
  final AppLocalizations l10n,
  final RegisterPhoneError? error,
) {
  switch (error) {
    case RegisterPhoneError.empty:
      return l10n.registerPhoneEmptyError;
    case RegisterPhoneError.invalid:
      return l10n.registerPhoneInvalidError;
    case null:
      return null;
  }
}
