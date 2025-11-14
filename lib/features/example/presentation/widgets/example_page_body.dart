import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_sections.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class ExamplePageBody extends StatelessWidget {
  const ExamplePageBody({
    required this.l10n,
    required this.theme,
    required this.colors,
    required this.onBackPressed,
    required this.onLoadPlatformInfo,
    required this.onOpenWebsocket,
    required this.onOpenChatList,
    required this.onOpenSearch,
    required this.onOpenProfile,
    required this.onOpenRegister,
    required this.onOpenLoggedOut,
    required this.onRunIsolates,
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
  final VoidCallback onOpenChatList;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenRegister;
  final VoidCallback onOpenLoggedOut;
  final VoidCallback? onRunIsolates;
  final bool isRunningIsolates;
  final String? isolateError;
  final int? fibonacciInput;
  final int? fibonacciResult;
  final List<int>? parallelValues;
  final Duration? parallelDuration;

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.symmetric(vertical: context.responsiveGapL),
    child: CommonCard(
      key: const ValueKey('example-content-card'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(context.responsiveCardRadius),
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
          SizedBox(height: context.responsiveGapL),
          Icon(
            Icons.explore,
            size: context.responsiveIconSize * 2.5,
            color: colors.primary,
          ),
          SizedBox(height: context.responsiveGapM),
          Text(
            l10n.examplePageDescription,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveGapL),
          PlatformAdaptive.filledButton(
            context: context,
            onPressed: onBackPressed,
            child: Text(l10n.exampleBackButtonLabel),
          ),
          SizedBox(height: context.responsiveGapL),
          PlatformAdaptive.filledButton(
            context: context,
            onPressed: onLoadPlatformInfo,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_iphone, size: context.responsiveIconSize),
                SizedBox(width: context.responsiveHorizontalGapS),
                Text(l10n.exampleNativeInfoButton),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          PlatformAdaptive.filledButton(
            context: context,
            onPressed: onOpenWebsocket,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi, size: context.responsiveIconSize),
                SizedBox(width: context.responsiveHorizontalGapS),
                Text(l10n.exampleWebsocketButton),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          PlatformAdaptive.filledButton(
            context: context,
            onPressed: onOpenChatList,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forum_outlined, size: context.responsiveIconSize),
                SizedBox(width: context.responsiveHorizontalGapS),
                const Text('Chat List Demo'),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          PlatformAdaptive.filledButton(
            context: context,
            onPressed: onOpenSearch,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: context.responsiveIconSize),
                SizedBox(width: context.responsiveHorizontalGapS),
                const Text('Search Demo'),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          PlatformAdaptive.filledButton(
            context: context,
            onPressed: onOpenProfile,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: context.responsiveIconSize),
                SizedBox(width: context.responsiveHorizontalGapS),
                const Text('Profile Demo'),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          PlatformAdaptive.filledButton(
            key: const ValueKey('example-register-button'),
            context: context,
            onPressed: onOpenRegister,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.app_registration,
                  size: context.responsiveIconSize,
                ),
                SizedBox(width: context.responsiveHorizontalGapS),
                const Text('Register Demo'),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          PlatformAdaptive.filledButton(
            context: context,
            onPressed: onOpenLoggedOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: context.responsiveIconSize),
                SizedBox(width: context.responsiveHorizontalGapS),
                const Text('Logged Out Demo'),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapL),
          PlatformAdaptive.filledButton(
            key: const ValueKey('example-run-isolates-button'),
            context: context,
            onPressed: onRunIsolates,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_outlined, size: context.responsiveIconSize),
                SizedBox(width: context.responsiveHorizontalGapS),
                Text(l10n.exampleRunIsolatesButton),
              ],
            ),
          ),
          SizedBox(height: context.responsiveGapS),
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
  );
}
