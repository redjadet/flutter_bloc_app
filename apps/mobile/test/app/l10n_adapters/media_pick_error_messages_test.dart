import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/l10n_adapters/media_pick_error_messages.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('maps known media pick error keys', (final tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (final context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      cameraGalleryErrorMessage(l10n, MediaPickErrorKeys.permissionDenied),
      l10n.cameraGalleryPermissionDenied,
    );
    expect(
      cameraGalleryErrorMessage(l10n, MediaPickErrorKeys.cameraUnavailable),
      l10n.cameraGalleryCameraUnavailable,
    );
    expect(
      cameraGalleryErrorMessage(l10n, MediaPickErrorKeys.cancelled),
      l10n.cameraGalleryCancelled,
    );
    expect(
      cameraGalleryErrorMessage(l10n, MediaPickErrorKeys.fileTooLarge),
      l10n.cameraGalleryFileTooLarge,
    );
    expect(
      cameraGalleryErrorMessage(l10n, MediaPickErrorKeys.generic),
      l10n.cameraGalleryGenericError,
    );
    expect(
      cameraGalleryErrorMessage(l10n, 'unknown-key'),
      l10n.cameraGalleryGenericError,
    );
  });
}
