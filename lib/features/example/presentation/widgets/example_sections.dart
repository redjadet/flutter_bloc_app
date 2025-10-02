import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class PlatformInfoSection extends StatelessWidget {
  const PlatformInfoSection({
    super.key,
    required this.isLoading,
    required this.info,
    required this.errorMessage,
  });

  final bool isLoading;
  final NativePlatformInfo? info;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (isLoading && info == null && errorMessage == null) {
      return _loadingIndicator();
    }
    if (errorMessage != null) {
      return _errorText(theme, l10n.exampleNativeInfoError);
    }
    if (info == null) {
      return const SizedBox.shrink();
    }
    final NativePlatformInfo resolvedInfo = info!;
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: Column(
        key: ValueKey<String>(
          'platform-info-${resolvedInfo.platform}-${resolvedInfo.version}',
        ),
        children: [
          Text(
            l10n.exampleNativeInfoTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: UI.gapXS),
          Text(
            resolvedInfo.toString(),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _errorText(ThemeData theme, String message) {
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class IsolateResultSection extends StatelessWidget {
  const IsolateResultSection({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.fibonacciInput,
    required this.fibonacciResult,
    required this.parallelValues,
    required this.parallelDuration,
  });

  final bool isLoading;
  final String? errorMessage;
  final int? fibonacciInput;
  final int? fibonacciResult;
  final List<int>? parallelValues;
  final Duration? parallelDuration;

  bool get _hasResults =>
      fibonacciInput != null &&
      fibonacciResult != null &&
      parallelValues != null &&
      parallelDuration != null;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (isLoading && !_hasResults && errorMessage == null) {
      return _loadingIndicator();
    }
    if (errorMessage != null) {
      return _errorText(theme, errorMessage!);
    }
    if (!_hasResults) {
      return const SizedBox.shrink();
    }
    final List<int> resolvedValues = parallelValues!;
    final Duration? resolvedDuration = parallelDuration;
    final String durationText = resolvedDuration == null
        ? l10n.exampleIsolateParallelPending
        : l10n.exampleIsolateParallelComplete(
            resolvedValues.join(', '),
            resolvedDuration.inMilliseconds,
          );
    final int resolvedInput = fibonacciInput ?? 0;
    final int resolvedResult = fibonacciResult ?? 0;
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: Column(
        key: ValueKey<String>('isolate-result-$resolvedDuration'),
        children: [
          Text(
            l10n.exampleIsolateFibonacciLabel(resolvedInput, resolvedResult),
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

  Widget _loadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _errorText(ThemeData theme, String message) {
    return Padding(
      padding: EdgeInsets.only(top: UI.gapS),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
