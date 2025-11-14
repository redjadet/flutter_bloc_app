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

  Widget _buildIconButton({
    required final BuildContext context,
    required final VoidCallback? onPressed,
    required final IconData icon,
    required final String label,
    final Key? key,
  }) => PlatformAdaptive.filledButton(
    key: key,
    context: context,
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: context.responsiveIconSize),
        SizedBox(width: context.responsiveHorizontalGapS),
        Text(label),
      ],
    ),
  );

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
          _buildIconButton(
            context: context,
            onPressed: onLoadPlatformInfo,
            icon: Icons.phone_iphone,
            label: l10n.exampleNativeInfoButton,
          ),
          SizedBox(height: context.responsiveGapS),
          _buildIconButton(
            context: context,
            onPressed: onOpenWebsocket,
            icon: Icons.wifi,
            label: l10n.exampleWebsocketButton,
          ),
          SizedBox(height: context.responsiveGapS),
          _buildIconButton(
            context: context,
            onPressed: onOpenChatList,
            icon: Icons.forum_outlined,
            label: 'Chat List Demo',
          ),
          SizedBox(height: context.responsiveGapS),
          _buildIconButton(
            context: context,
            onPressed: onOpenSearch,
            icon: Icons.search,
            label: 'Search Demo',
          ),
          SizedBox(height: context.responsiveGapS),
          _buildIconButton(
            context: context,
            onPressed: onOpenProfile,
            icon: Icons.person,
            label: 'Profile Demo',
          ),
          SizedBox(height: context.responsiveGapS),
          _buildIconButton(
            context: context,
            onPressed: onOpenRegister,
            icon: Icons.app_registration,
            label: 'Register Demo',
            key: const ValueKey('example-register-button'),
          ),
          SizedBox(height: context.responsiveGapS),
          _buildIconButton(
            context: context,
            onPressed: onOpenLoggedOut,
            icon: Icons.logout,
            label: 'Logged Out Demo',
          ),
          SizedBox(height: context.responsiveGapL),
          _buildIconButton(
            context: context,
            onPressed: onRunIsolates,
            icon: Icons.bolt_outlined,
            label: l10n.exampleRunIsolatesButton,
            key: const ValueKey('example-run-isolates-button'),
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
