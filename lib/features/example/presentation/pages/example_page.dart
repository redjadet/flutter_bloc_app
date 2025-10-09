import 'dart:math';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_sections.dart';
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
  final Random _random = Random(42);
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
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _infoError = error.message ?? error.toString();
      });
    } on MissingPluginException catch (error) {
      if (!mounted) return;
      setState(() {
        _infoError = error.message ?? error.toString();
      });
    } on Exception catch (error) {
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
    } on Exception catch (error) {
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
                    FilledButton.icon(
                      onPressed: () => context.pushNamed(AppRoutes.websocket),
                      icon: const Icon(Icons.wifi),
                      label: Text(l10n.exampleWebsocketButton),
                    ),
                    SizedBox(height: UI.gapS),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: PlatformInfoSection(
                        isLoading: _isFetchingInfo,
                        info: _platformInfo,
                        errorMessage: _infoError,
                      ),
                    ),
                    SizedBox(height: UI.gapL),
                    FilledButton.icon(
                      key: const ValueKey('example-run-isolates-button'),
                      onPressed: _isRunningIsolates
                          ? null
                          : () => _runIsolateSamples(),
                      icon: const Icon(Icons.bolt_outlined),
                      label: Text(l10n.exampleRunIsolatesButton),
                    ),
                    SizedBox(height: UI.gapS),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: IsolateResultSection(
                        isLoading: _isRunningIsolates,
                        errorMessage: _isolateError,
                        fibonacciInput: _fibonacciInput,
                        fibonacciResult: _fibonacciResult,
                        parallelValues: _parallelResult,
                        parallelDuration: _parallelDuration,
                      ),
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
}
