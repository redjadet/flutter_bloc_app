/// Single source of truth for Supabase email/password client-side rules.
///
/// Used by the repository (throws typed errors) and the auth page (submit gate)
/// so UI and data-layer validation cannot drift. Register/Firebase auth keeps
/// its own stricter product policy in `register_state.dart`.
abstract final class SupabaseAuthCredentialPolicy {
  static const int minimumPasswordLength = 6;

  static final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String email) {
    final String normalized = email.trim();
    return normalized.isNotEmpty && emailPattern.hasMatch(normalized);
  }

  static bool meetsPasswordLength(String password) =>
      password.length >= minimumPasswordLength;

  /// True when both fields pass the same checks the repository enforces.
  static bool canSubmit({required String email, required String password}) =>
      isValidEmail(email) && meetsPasswordLength(password);
}
