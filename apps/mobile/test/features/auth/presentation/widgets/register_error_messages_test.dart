import 'package:flutter_bloc_app/features/auth/presentation/cubit/register/register_state.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/register_error_messages.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('fullNameErrorText', () {
    test('maps validation errors', () {
      expect(
        fullNameErrorText(l10n, RegisterFullNameError.empty),
        l10n.registerFullNameEmptyError,
      );
      expect(
        fullNameErrorText(l10n, RegisterFullNameError.tooShort),
        l10n.registerFullNameTooShortError,
      );
      expect(fullNameErrorText(l10n, null), isNull);
    });
  });

  group('emailErrorText', () {
    test('maps validation errors', () {
      expect(
        emailErrorText(l10n, RegisterEmailError.empty),
        l10n.registerEmailEmptyError,
      );
      expect(
        emailErrorText(l10n, RegisterEmailError.invalid),
        l10n.registerEmailInvalidError,
      );
      expect(emailErrorText(l10n, null), isNull);
    });
  });

  group('passwordErrorText', () {
    test('maps validation errors', () {
      expect(
        passwordErrorText(l10n, RegisterPasswordError.empty),
        l10n.registerPasswordEmptyError,
      );
      expect(
        passwordErrorText(l10n, RegisterPasswordError.tooShort),
        l10n.registerPasswordTooShortError,
      );
      expect(
        passwordErrorText(l10n, RegisterPasswordError.lettersAndNumbers),
        l10n.registerPasswordLettersAndNumbersError,
      );
      expect(
        passwordErrorText(l10n, RegisterPasswordError.whitespace),
        l10n.registerPasswordWhitespaceError,
      );
      expect(passwordErrorText(l10n, null), isNull);
    });
  });

  group('confirmPasswordErrorText', () {
    test('maps validation errors', () {
      expect(
        confirmPasswordErrorText(l10n, RegisterConfirmPasswordError.empty),
        l10n.registerConfirmPasswordEmptyError,
      );
      expect(
        confirmPasswordErrorText(l10n, RegisterConfirmPasswordError.mismatch),
        l10n.registerConfirmPasswordMismatchError,
      );
      expect(confirmPasswordErrorText(l10n, null), isNull);
    });
  });

  group('phoneErrorText', () {
    test('maps validation errors', () {
      expect(
        phoneErrorText(l10n, RegisterPhoneError.empty),
        l10n.registerPhoneEmptyError,
      );
      expect(
        phoneErrorText(l10n, RegisterPhoneError.invalid),
        l10n.registerPhoneInvalidError,
      );
      expect(phoneErrorText(l10n, null), isNull);
    });
  });
}
