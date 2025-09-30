import 'dart:math';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_samples.dart';
import 'package:go_router/go_router.dart';

/// Simple example page used to demonstrate GoRouter navigation
class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final NativePlatformService _platformService = NativePlatformService();
  final Random _random = Random();
  NativePlatformInfo? _platformInfo;
  bool _isFetchingInfo = false;
  String? _infoError;
  bool _isRunningIsolates = false;
  String? _isolateError;
  int? _fibonacciResult;
  int? _fibonacciInput;
  List<int>? _parallelResult;
  Duration? _parallelDuration;

  Future<void> _loadPlatformInfo(BuildContext context) async {
    if (_isFetchingInfo) return;
    setState(() {
      _isFetchingInfo = true;
      _infoError = null;
    });
    try {
      final NativePlatformInfo info = await _platformService.getPlatformInfo();
      if (!mounted) return;
      setState(() {
        _platformInfo = info;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _infoError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingInfo = false;
        });
      }
    }
  }

  Future<void> _runIsolateSamples() async {
    if (_isRunningIsolates) return;
    _setIsolateLoading();
    try {
      final int fibonacciInput = 12 + _random.nextInt(12);
      final int fibonacci = await IsolateSamples.fibonacci(fibonacciInput);

      final Stopwatch stopwatch = Stopwatch()..start();
      final List<int> doubled = await IsolateSamples.delayedDoubleAll(
        const <int>[2, 4, 8],
      );
      stopwatch.stop();

      _setIsolateResults(
        input: fibonacciInput,
        result: fibonacci,
        parallelValues: doubled,
        elapsed: stopwatch.elapsed,
      );
    } catch (error) {
      _setIsolateFailure(error);
    }
  }

  void _setIsolateLoading() {
    if (!mounted) return;
    setState(() {
      _isRunningIsolates = true;
      _isolateError = null;
      _fibonacciResult = null;
      _fibonacciInput = null;
      _parallelResult = null;
      _parallelDuration = null;
    });
  }

  void _setIsolateResults({
    required int input,
    required int result,
    required List<int> parallelValues,
    required Duration elapsed,
  }) {
    if (!mounted) return;
    setState(() {
      _isRunningIsolates = false;
      _isolateError = null;
      _fibonacciInput = input;
      _fibonacciResult = result;
      _parallelResult = parallelValues;
      _parallelDuration = elapsed;
    });
  }

  void _setIsolateFailure(Object error) {
    if (!mounted) return;
    setState(() {
      _isRunningIsolates = false;
      _isolateError = error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examplePageTitle)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(UI.gapL),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UI.radiusM),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UI.cardPadH,
                vertical: UI.cardPadV,
              ),
              child: SingleChildScrollView(
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
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.goNamed(AppRoutes.counter);
                        }
                      },
                      child: Text(l10n.exampleBackButtonLabel),
                    ),
                    SizedBox(height: UI.gapL),
                    FilledButton.icon(
                      onPressed: _isFetchingInfo
                          ? null
                          : () => _loadPlatformInfo(context),
                      icon: const Icon(Icons.phone_iphone),
                      label: Text(l10n.exampleNativeInfoButton),
                    ),
                    SizedBox(height: UI.gapS),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildPlatformInfoSection(theme, l10n),
                    ),
                    SizedBox(height: UI.gapL),
                    FilledButton.icon(
                      onPressed: _isRunningIsolates
                          ? null
                          : () => _runIsolateSamples(),
                      icon: const Icon(Icons.bolt_outlined),
                      label: Text(l10n.exampleRunIsolatesButton),
                    ),
                    SizedBox(height: UI.gapS),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildIsolateSection(theme, l10n),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformInfoSection(ThemeData theme, AppLocalizations l10n) {
    if (_isFetchingInfo && _platformInfo == null && _infoError == null) {
      return Padding(
        padding: EdgeInsets.only(top: UI.gapS),
        child: const CircularProgressIndicator(),
      );
    }
    if (_infoError != null) {
      return Padding(
        padding: EdgeInsets.only(top: UI.gapS),
        child: Text(
          l10n.exampleNativeInfoError,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_platformInfo == null) {
      return const SizedBox.shrink();
    }
    final NativePlatformInfo info = _platformInfo!;
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: Column(
        key: ValueKey<String>('platform-info-${info.platform}-${info.version}'),
        children: [
          Text(
            l10n.exampleNativeInfoTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UI.gapXS),
          Text(
            info.toString(),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIsolateSection(ThemeData theme, AppLocalizations l10n) {
    final bool hasResults =
        _fibonacciResult != null &&
        _fibonacciInput != null &&
        _parallelResult != null &&
        _parallelDuration != null;
    final bool showSpinner =
        _isRunningIsolates && !hasResults && _isolateError == null;

    if (showSpinner) {
      return Padding(
        padding: EdgeInsets.only(top: UI.gapS),
        child: const CircularProgressIndicator(),
      );
    }
    if (_isolateError != null) {
      return Padding(
        padding: EdgeInsets.only(top: UI.gapS),
        child: Text(
          _isolateError!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (!hasResults) {
      return const SizedBox.shrink();
    }
    final String durationText = _parallelDuration == null
        ? l10n.exampleIsolateParallelPending
        : l10n.exampleIsolateParallelComplete(
            _parallelResult!.join(', '),
            _parallelDuration!.inMilliseconds,
          );
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: Column(
        key: ValueKey<String>('isolate-result-$_parallelDuration'),
        children: [
          Text(
            l10n.exampleIsolateFibonacciLabel(
              _fibonacciInput ?? 0,
              _fibonacciResult ?? 0,
            ),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UI.gapXS),
          Text(
            durationText,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
