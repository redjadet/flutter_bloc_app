import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Live native banner via [UiKitView] / [AndroidView], or a placeholder.
class NativePlatformShowcasePlatformViewSection extends StatelessWidget {
  const NativePlatformShowcasePlatformViewSection({
    super.key,
    this.platformOverride,
  });

  /// Test seam — avoid mounting a real platform view in widget tests.
  final TargetPlatform? platformOverride;

  static const String viewType =
      'com.example.flutter_bloc_app/native_showcase_banner';

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final TargetPlatform platform = platformOverride ?? defaultTargetPlatform;
    final bool showNative =
        !kIsWeb &&
        (platform == TargetPlatform.iOS || platform == TargetPlatform.android);

    return KeyedSubtree(
      key: const ValueKey<String>('native-platform-showcase-platform-view'),
      child: CommonCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.nativePlatformShowcasePlatformViewTitle,
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapS),
            Text(
              l10n.nativePlatformShowcasePlatformViewBody,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: context.responsiveGapM),
            SizedBox(
              height: 72,
              child: showNative
                  ? _NativeBanner(platform: platform)
                  : Center(
                      child: Text(
                        l10n.nativePlatformShowcasePlatformViewUnavailable,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NativeBanner extends StatelessWidget {
  const _NativeBanner({required this.platform});

  final TargetPlatform platform;

  @override
  Widget build(final BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return const UiKitView(
        viewType: NativePlatformShowcasePlatformViewSection.viewType,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: StandardMessageCodec(),
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
      );
    }
    return const AndroidView(
      viewType: NativePlatformShowcasePlatformViewSection.viewType,
      layoutDirection: TextDirection.ltr,
      creationParamsCodec: StandardMessageCodec(),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
    );
  }
}
