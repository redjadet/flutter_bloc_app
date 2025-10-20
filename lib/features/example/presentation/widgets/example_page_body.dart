import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_sections.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ExamplePageBody extends StatelessWidget {
  const ExamplePageBody({
    required this.l10n,
    required this.theme,
    required this.colors,
    required this.onBackPressed,
    required this.onLoadPlatformInfo,
    required this.onOpenWebsocket,
    required this.onOpenGoogleMaps,
    required this.onRunIsolates,
    required this.isFetchingInfo,
    required this.platformInfo,
    required this.infoError,
    required this.isRunningIsolates,
    required this.isolateError,
    required this.fibonacciInput,
    required this.fibonacciResult,
    required this.parallelValues,
    required this.parallelDuration,
    super.key,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback onBackPressed;
  final VoidCallback? onLoadPlatformInfo;
  final VoidCallback onOpenWebsocket;
  final VoidCallback onOpenGoogleMaps;
  final VoidCallback? onRunIsolates;
  final bool isFetchingInfo;
  final NativePlatformInfo? platformInfo;
  final String? infoError;
  final bool isRunningIsolates;
  final String? isolateError;
  final int? fibonacciInput;
  final int? fibonacciResult;
  final List<int>? parallelValues;
  final Duration? parallelDuration;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.symmetric(vertical: UI.gapL),
    child: Card(
      key: const ValueKey('example-content-card'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UI.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: UI.cardPadH,
          vertical: UI.cardPadV,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(UI.radiusM),
              child: FancyShimmerImage(
                imageUrl:
                    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
                height: 180,
                width: double.infinity,
                boxFit: BoxFit.cover,
                shimmerBaseColor: colors.surfaceContainerHighest,
                shimmerHighlightColor: colors.surface,
              ),
            ),
            SizedBox(height: UI.gapL),
            Icon(Icons.explore, size: 64, color: colors.primary),
            SizedBox(height: UI.gapM),
            Text(
              l10n.examplePageDescription,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: UI.gapL),
            FilledButton(
              onPressed: onBackPressed,
              child: Text(l10n.exampleBackButtonLabel),
            ),
            SizedBox(height: UI.gapL),
            FilledButton.icon(
              onPressed: onLoadPlatformInfo,
              icon: const Icon(Icons.phone_iphone),
              label: Text(l10n.exampleNativeInfoButton),
            ),
            SizedBox(height: UI.gapS),
            FilledButton.icon(
              onPressed: onOpenWebsocket,
              icon: const Icon(Icons.wifi),
              label: Text(l10n.exampleWebsocketButton),
            ),
            SizedBox(height: UI.gapS),
            FilledButton.icon(
              onPressed: onOpenGoogleMaps,
              icon: const Icon(Icons.map),
              label: Text(l10n.exampleGoogleMapsButton),
            ),
            SizedBox(height: UI.gapS),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: PlatformInfoSection(
                isLoading: isFetchingInfo,
                info: platformInfo,
                errorMessage: infoError,
              ),
            ),
            SizedBox(height: UI.gapL),
            FilledButton.icon(
              key: const ValueKey('example-run-isolates-button'),
              onPressed: onRunIsolates,
              icon: const Icon(Icons.bolt_outlined),
              label: Text(l10n.exampleRunIsolatesButton),
            ),
            SizedBox(height: UI.gapS),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: IsolateResultSection(
                isLoading: isRunningIsolates,
                errorMessage: isolateError,
                fibonacciInput: fibonacciInput,
                fibonacciResult: fibonacciResult,
                parallelValues: parallelValues,
                parallelDuration: parallelDuration,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
