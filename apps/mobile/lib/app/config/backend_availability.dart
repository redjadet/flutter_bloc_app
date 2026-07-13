import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';

/// Notifies listeners when opportunistic backends finish initializing.
///
/// [BackendAvailability.fromBootstrap] already reads live Firebase/Supabase
/// flags. This ticker exists so route builders that capture banner bools can
/// rebuild after deferred web backend init completes.
class BackendAvailabilityUpdates extends ChangeNotifier {
  BackendAvailabilityUpdates._();

  static final BackendAvailabilityUpdates instance =
      BackendAvailabilityUpdates._();

  void notifyUpdated() => notifyListeners();
}

/// Runtime backend availability and web no-backend policy flags.
///
/// Web behavior: backends are opportunistic (used when available) but never
/// required for feature usability.
class BackendAvailability {
  const BackendAvailability({
    required this.firebaseInitialized,
    required this.supabaseInitialized,
    required this.webNoBackendMode,
    required this.allowWebLocalGuestAuth,
    required this.allowLocalChatFallback,
  });

  factory BackendAvailability.fromBootstrap() {
    const bool webNoBackendMode = kIsWeb;
    return BackendAvailability(
      firebaseInitialized: FirebaseBootstrapService.isFirebaseInitialized,
      supabaseInitialized: SupabaseBootstrapService.isSupabaseInitialized,
      webNoBackendMode: webNoBackendMode,
      allowWebLocalGuestAuth: webNoBackendMode,
      allowLocalChatFallback: webNoBackendMode,
    );
  }

  final bool firebaseInitialized;
  final bool supabaseInitialized;

  /// True only on web builds. This is the single switch enabling web-only
  /// no-backend behavior (no required login, local fallbacks).
  final bool webNoBackendMode;

  /// Allow local guest auth on web when Firebase Auth is unavailable.
  final bool allowWebLocalGuestAuth;

  /// Allow local chat response fallback when no remote path is usable.
  final bool allowLocalChatFallback;

  /// Whether the chat UI should show the backend-disabled banner: web
  /// no-backend mode with either Firebase or Supabase unavailable.
  bool get showChatBackendDisabledBanner =>
      webNoBackendMode && (!firebaseInitialized || !supabaseInitialized);

  /// Whether the IoT cloud tab should show the backend-disabled banner: web
  /// no-backend mode with Supabase unavailable.
  bool get showIotCloudBackendDisabledBanner =>
      webNoBackendMode && !supabaseInitialized;
}
