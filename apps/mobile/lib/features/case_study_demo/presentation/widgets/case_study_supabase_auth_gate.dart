import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/auth/optional_supabase_auth_gate.dart';
import 'package:material_ui/material_ui.dart';

/// Case study demo wrapper around [OptionalSupabaseAuthGate].
class CaseStudySupabaseAuthGate extends StatelessWidget {
  const new({
    required this.isSupabaseInitialized,
    required this.getCurrentUser,
    required this.authStateChanges,
    required this.fallbackPath,
    required this.supabaseAuthPath,
    required this.redirectReturnPath,
    required this.child,
    super.key,
  });

  final bool isSupabaseInitialized;
  final AuthUser? Function() getCurrentUser;
  final Stream<AuthUser?> authStateChanges;

  /// Where to send the user if the gate fails unexpectedly.
  final String fallbackPath;

  final String supabaseAuthPath;

  /// Path to return to after successful Supabase sign-in.
  final String redirectReturnPath;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OptionalSupabaseAuthGate(
      isSupabaseInitialized: isSupabaseInitialized,
      getCurrentUser: getCurrentUser,
      authStateChanges: authStateChanges,
      fallbackPath: fallbackPath,
      supabaseAuthPath: supabaseAuthPath,
      redirectReturnPath: redirectReturnPath,
      child: child,
    );
  }
}
