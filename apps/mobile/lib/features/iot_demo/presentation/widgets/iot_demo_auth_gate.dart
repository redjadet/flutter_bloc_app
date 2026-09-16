import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/auth/optional_supabase_auth_gate.dart';
import 'package:material_ui/material_ui.dart';

/// IoT demo wrapper around [OptionalSupabaseAuthGate].
///
/// [counterPath] is the unexpected-failure fallback (maps to
/// [OptionalSupabaseAuthGate.fallbackPath]).
class IotDemoAuthGate extends StatelessWidget {
  const new({
    required this.isSupabaseInitialized,
    required this.getCurrentUser,
    required this.authStateChanges,
    required this.counterPath,
    required this.supabaseAuthPath,
    required this.redirectReturnPath,
    required this.child,
    super.key,
  });

  final bool isSupabaseInitialized;
  final AuthUser? Function() getCurrentUser;
  final Stream<AuthUser?> authStateChanges;
  final String counterPath;
  final String supabaseAuthPath;
  final String redirectReturnPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OptionalSupabaseAuthGate(
      isSupabaseInitialized: isSupabaseInitialized,
      getCurrentUser: getCurrentUser,
      authStateChanges: authStateChanges,
      fallbackPath: counterPath,
      supabaseAuthPath: supabaseAuthPath,
      redirectReturnPath: redirectReturnPath,
      child: child,
    );
  }
}
