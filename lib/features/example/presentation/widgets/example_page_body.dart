import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_sections.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

part 'example_page_body_content.part.dart';

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
    required this.onOpenTodoList,
    required this.onOpenProfile,
    required this.onOpenRegister,
    required this.onOpenLoggedOut,
    required this.onOpenLibraryDemo,
    required this.onOpenIgamingDemo,
    required this.onOpenStaffAppDemo,
    required this.onOpenScapes,
    required this.onOpenWalletconnectAuth,
    required this.onOpenCameraGallery,
    required this.onOpenCaseStudyDemo,
    required this.onOpenIapDemo,
    required this.onOpenAiDecisionDemo,
    required this.onOpenOnlineTherapyDemo,
    required this.onRunIsolates,
    required this.isRunningIsolates,
    required this.isolateError,
    required this.fibonacciInput,
    required this.fibonacciResult,
    required this.parallelValues,
    required this.parallelDuration,
    this.onOpenFcmDemo,
    this.onOpenFirebaseFunctionsTest,
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
  final VoidCallback onOpenTodoList;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenRegister;
  final VoidCallback onOpenLoggedOut;
  final VoidCallback onOpenLibraryDemo;
  final VoidCallback onOpenIgamingDemo;
  final VoidCallback onOpenStaffAppDemo;
  final VoidCallback? onOpenFcmDemo;
  final VoidCallback? onOpenFirebaseFunctionsTest;
  final VoidCallback onOpenScapes;
  final VoidCallback onOpenWalletconnectAuth;
  final VoidCallback onOpenCameraGallery;
  final VoidCallback onOpenCaseStudyDemo;
  final VoidCallback onOpenIapDemo;
  final VoidCallback onOpenAiDecisionDemo;
  final VoidCallback onOpenOnlineTherapyDemo;
  final VoidCallback? onRunIsolates;
  final bool isRunningIsolates;
  final String? isolateError;
  final int? fibonacciInput;
  final int? fibonacciResult;
  final List<int>? parallelValues;
  final Duration? parallelDuration;

  @override
  Widget build(final BuildContext context) => _ExamplePageBodyContent(
    l10n: l10n,
    theme: theme,
    colors: colors,
    onBackPressed: onBackPressed,
    onLoadPlatformInfo: onLoadPlatformInfo,
    onOpenWebsocket: onOpenWebsocket,
    onOpenChatList: onOpenChatList,
    onOpenSearch: onOpenSearch,
    onOpenTodoList: onOpenTodoList,
    onOpenProfile: onOpenProfile,
    onOpenRegister: onOpenRegister,
    onOpenLoggedOut: onOpenLoggedOut,
    onOpenLibraryDemo: onOpenLibraryDemo,
    onOpenIgamingDemo: onOpenIgamingDemo,
    onOpenStaffAppDemo: onOpenStaffAppDemo,
    onOpenFcmDemo: onOpenFcmDemo,
    onOpenFirebaseFunctionsTest: onOpenFirebaseFunctionsTest,
    onOpenScapes: onOpenScapes,
    onOpenWalletconnectAuth: onOpenWalletconnectAuth,
    onOpenCameraGallery: onOpenCameraGallery,
    onOpenCaseStudyDemo: onOpenCaseStudyDemo,
    onOpenIapDemo: onOpenIapDemo,
    onOpenAiDecisionDemo: onOpenAiDecisionDemo,
    onOpenOnlineTherapyDemo: onOpenOnlineTherapyDemo,
    onRunIsolates: onRunIsolates,
    isRunningIsolates: isRunningIsolates,
    isolateError: isolateError,
    fibonacciInput: fibonacciInput,
    fibonacciResult: fibonacciResult,
    parallelValues: parallelValues,
    parallelDuration: parallelDuration,
  );
}
