import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_page_body.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
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

  Future<void> _loadPlatformInfo(final BuildContext context) async {
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
    required final int input,
    required final int result,
    required final List<int> parallelValues,
    required final Duration elapsed,
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

  void _setIsolateFailure(final Object error) {
    if (!mounted) return;
    setState(() {
      _isRunningIsolates = false;
      _isolateError = error.toString();
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return CommonPageLayout(
      title: l10n.examplePageTitle,
      body: ExamplePageBody(
        l10n: l10n,
        theme: theme,
        colors: colors,
        onBackPressed: () => NavigationUtils.popOrGoHome(context),
        onLoadPlatformInfo: _isFetchingInfo
            ? null
            : () => _loadPlatformInfo(context),
        onOpenWebsocket: () => context.pushNamed(AppRoutes.websocket),
        onOpenGoogleMaps: () => context.pushNamed(AppRoutes.googleMaps),
        onOpenSearch: () => context.pushNamed(AppRoutes.search),
        onOpenProfile: () => context.pushNamed(AppRoutes.profile),
        onRunIsolates: _isRunningIsolates ? null : _runIsolateSamples,
        isFetchingInfo: _isFetchingInfo,
        platformInfo: _platformInfo,
        infoError: _infoError,
        isRunningIsolates: _isRunningIsolates,
        isolateError: _isolateError,
        fibonacciInput: _fibonacciInput,
        fibonacciResult: _fibonacciResult,
        parallelValues: _parallelResult,
        parallelDuration: _parallelDuration,
      ),
    );
  }
}
