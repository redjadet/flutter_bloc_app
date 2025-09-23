import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/native_platform_service.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:go_router/go_router.dart';

/// Simple example page used to demonstrate GoRouter navigation
class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final NativePlatformService _platformService = NativePlatformService();
  NativePlatformInfo? _platformInfo;
  bool _isFetchingInfo = false;
  String? _infoError;

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
}
