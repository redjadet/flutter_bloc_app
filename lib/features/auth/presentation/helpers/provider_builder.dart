import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as firebase_ui_google;

List<firebase_ui.AuthProvider> buildAuthProviders({
  required final FirebaseAuth auth,
  required final firebase_ui_google.GoogleProvider? Function()
  googleProviderFactory,
  final List<firebase_ui.AuthProvider>? override,
}) {
  final List<firebase_ui.AuthProvider> providers =
      List<firebase_ui.AuthProvider>.from(
        override ?? firebase_ui.FirebaseUIAuth.providersFor(auth.app),
      );

  if (!providers.any(
    (final provider) => provider is firebase_ui.EmailAuthProvider,
  )) {
    providers.insert(0, firebase_ui.EmailAuthProvider());
  }

  if (providers.isEmpty) {
    providers.add(firebase_ui.EmailAuthProvider());
  }

  final bool hasGoogleProvider = providers.any(
    (final provider) => provider is firebase_ui_google.GoogleProvider,
  );

  if (!hasGoogleProvider) {
    final firebase_ui_google.GoogleProvider? googleProvider =
        googleProviderFactory();
    if (googleProvider != null) {
      providers.add(googleProvider);
    }
  }

  return providers;
}
