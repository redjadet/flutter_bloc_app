import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_credential_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseAuthCredentialPolicy', () {
    test('isValidEmail', () {
      expect(SupabaseAuthCredentialPolicy.isValidEmail('a@b.co'), isTrue);
      expect(SupabaseAuthCredentialPolicy.isValidEmail('  a@b.co  '), isTrue);
      expect(SupabaseAuthCredentialPolicy.isValidEmail(''), isFalse);
      expect(
        SupabaseAuthCredentialPolicy.isValidEmail('not-an-email'),
        isFalse,
      );
      expect(SupabaseAuthCredentialPolicy.isValidEmail('a@b'), isFalse);
    });

    test('meetsPasswordLength uses minimumPasswordLength', () {
      expect(
        SupabaseAuthCredentialPolicy.meetsPasswordLength('123456'),
        isTrue,
      );
      expect(
        SupabaseAuthCredentialPolicy.meetsPasswordLength('12345'),
        isFalse,
      );
      expect(SupabaseAuthCredentialPolicy.minimumPasswordLength, 6);
    });

    test('canSubmit requires both email and password', () {
      expect(
        SupabaseAuthCredentialPolicy.canSubmit(
          email: 'a@b.co',
          password: '123456',
        ),
        isTrue,
      );
      expect(
        SupabaseAuthCredentialPolicy.canSubmit(
          email: 'bad',
          password: '123456',
        ),
        isFalse,
      );
      expect(
        SupabaseAuthCredentialPolicy.canSubmit(
          email: 'a@b.co',
          password: 'short',
        ),
        isFalse,
      );
    });
  });
}
