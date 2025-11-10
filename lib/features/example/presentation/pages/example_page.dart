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
  bool _isFetchingInfo = false;
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
    });
    try {
      final NativePlatformInfo info = await _platformService.getPlatformInfo();
      if (!mounted) return;
      await _showPlatformInfoDialog(info);
    } on PlatformException catch (error) {
      await _showPlatformInfoErrorDialog(error.message);
    } on MissingPluginException catch (error) {
      await _showPlatformInfoErrorDialog(error.message);
    } on Exception catch (error) {
      await _showPlatformInfoErrorDialog(error.toString());
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

  Future<void> _showPlatformInfoDialog(final NativePlatformInfo info) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final List<Widget> rows = <Widget>[
      _buildInfoRow(
        l10n.exampleNativeInfoDialogPlatformLabel,
        info.platform,
      ),
      _buildInfoRow(
        l10n.exampleNativeInfoDialogVersionLabel,
        info.version,
      ),
      if (info.manufacturer != null)
        _buildInfoRow(
          l10n.exampleNativeInfoDialogManufacturerLabel,
          info.manufacturer!,
        ),
      if (info.model != null)
        _buildInfoRow(
          l10n.exampleNativeInfoDialogModelLabel,
          info.model!,
        ),
      if (info.batteryLevel != null)
        _buildInfoRow(
          l10n.exampleNativeInfoDialogBatteryLabel,
          '${info.batteryLevel}%',
        ),
    ];

    await showAdaptiveDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) => AlertDialog.adaptive(
        title: Text(l10n.exampleNativeInfoDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.exampleDialogCloseButton),
          ),
        ],
      ),
    );
  }

  Future<void> _showPlatformInfoErrorDialog(final String? message) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final String? detail = (message?.trim().isNotEmpty ?? false)
        ? message!.trim()
        : null;
    await showAdaptiveDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) => AlertDialog.adaptive(
        title: Text(l10n.exampleNativeInfoDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.exampleNativeInfoError),
            if (detail != null) ...[
              const SizedBox(height: 12),
              Text(detail),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.exampleDialogCloseButton),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );

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
        onOpenChatList: () => context.pushNamed(AppRoutes.chatList),
        onOpenSearch: () => context.pushNamed(AppRoutes.search),
        onOpenProfile: () => context.pushNamed(AppRoutes.profile),
        onOpenRegister: () => context.pushNamed(AppRoutes.register),
        onOpenLoggedOut: () => context.pushNamed(AppRoutes.loggedOut),
        onRunIsolates: _isRunningIsolates ? null : _runIsolateSamples,
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
