part of 'supabase_auth_repository_impl.dart';

extension _SupabaseAuthRepositoryImplPrivate on SupabaseAuthRepositoryImpl {
  bool get _canAccessSupabase => isConfigured;

  void _requireConfigured() {
    if (_canAccessSupabase) {
      return;
    }
    throw const SupabaseAuthException(
      'Supabase is not configured (missing URL or anon key).',
    );
  }
}

const int _minimumSupabasePasswordLength = 6;
const String _genericUnexpectedAuthMessage = 'Authentication request failed.';
final RegExp _basicEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

void _validateCredentialInputs({
  required final String email,
  required final String password,
}) {
  final String normalizedEmail = email.trim();
  if (normalizedEmail.isEmpty ||
      !_basicEmailPattern.hasMatch(normalizedEmail)) {
    throw const SupabaseAuthException(
      'Please enter a valid email address.',
      code: SupabaseAuthErrorCode.invalidEmail,
    );
  }
  if (password.length < _minimumSupabasePasswordLength) {
    throw const SupabaseAuthException(
      'Password must be at least 6 characters.',
      code: SupabaseAuthErrorCode.weakPassword,
    );
  }
}

app_auth.AuthUser? _mapSupabaseUser(final User? user) =>
    user == null ? null : _toAuthUser(user);

Map<String, dynamic>? _signUpUserData(final String? displayName) {
  if (displayName == null) {
    return null;
  }
  final String trimmedDisplayName = displayName.trim();
  if (trimmedDisplayName.isEmpty) {
    return null;
  }
  return <String, dynamic>{'full_name': trimmedDisplayName};
}

SupabaseAuthException _authExceptionFromSupabase(final AuthException error) {
  return SupabaseAuthException(
    error.message,
    code: _mapErrorCode(error),
    cause: error,
  );
}

SupabaseAuthException _unexpectedAuthException(final Object error) =>
    SupabaseAuthException(_genericUnexpectedAuthMessage, cause: error);

app_auth.AuthUser _toAuthUser(final User user) {
  final meta = user.userMetadata;
  final String? displayName = switch (meta) {
    final Map<dynamic, dynamic> values => stringFromDynamic(
      values['full_name'],
    )?.trim(),
    _ => null,
  };
  return app_auth.AuthUser(
    id: user.id,
    email: user.email?.trim(),
    displayName: displayName?.isEmpty ?? true ? null : displayName,
    isAnonymous: false,
  );
}

SupabaseAuthErrorCode? _mapErrorCode(final AuthException error) {
  if (error is AuthRetryableFetchException || error.statusCode == null) {
    return SupabaseAuthErrorCode.network;
  }

  final String normalizedMessage = error.message.trim().toLowerCase();
  if (normalizedMessage.contains('invalid login credentials') ||
      normalizedMessage.contains('invalid email or password')) {
    return SupabaseAuthErrorCode.invalidCredentials;
  }

  if (normalizedMessage.contains('failed host lookup') ||
      normalizedMessage.contains('socketexception') ||
      normalizedMessage.contains('network')) {
    return SupabaseAuthErrorCode.network;
  }

  if (normalizedMessage.contains('password should be') ||
      normalizedMessage.contains('at least 6 characters')) {
    return SupabaseAuthErrorCode.weakPassword;
  }

  if (normalizedMessage.contains('validate email') ||
      (normalizedMessage.contains('invalid format') &&
          normalizedMessage.contains('email'))) {
    return SupabaseAuthErrorCode.invalidEmail;
  }

  if (normalizedMessage.contains('already registered') ||
      normalizedMessage.contains('user already exists') ||
      normalizedMessage.contains('email already in use')) {
    return SupabaseAuthErrorCode.userAlreadyExists;
  }

  return null;
}

User? _defaultReadCurrentUser() => Supabase.instance.client.auth.currentUser;

Stream<AuthState> _defaultAuthStateChangesStream() =>
    Supabase.instance.client.auth.onAuthStateChange;

Future<void> _defaultSignInWithPassword({
  required final String email,
  required final String password,
}) {
  return Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );
}

Future<void> _defaultSignUp({
  required final String email,
  required final String password,
  final Map<String, dynamic>? data,
}) {
  return Supabase.instance.client.auth.signUp(
    email: email,
    password: password,
    data: data,
  );
}

Future<void> _defaultSignOut() => Supabase.instance.client.auth.signOut();
