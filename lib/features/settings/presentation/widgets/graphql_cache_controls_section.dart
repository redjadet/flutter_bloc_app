import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_cache_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:get_it/get_it.dart';

class GraphqlCacheControlsSection extends StatefulWidget {
  const GraphqlCacheControlsSection({
    super.key,
    this.cacheRepository,
  });

  @visibleForTesting
  final GraphqlDemoCacheRepository? cacheRepository;

  @override
  State<GraphqlCacheControlsSection> createState() =>
      _GraphqlCacheControlsSectionState();
}

class _GraphqlCacheControlsSectionState
    extends State<GraphqlCacheControlsSection> {
  bool _isClearing = false;

  GraphqlDemoCacheRepository? get _repository =>
      widget.cacheRepository ??
      (GetIt.instance.isRegistered<GraphqlDemoCacheRepository>()
          ? GetIt.instance<GraphqlDemoCacheRepository>()
          : null);

  Future<void> _handleClear() async {
    final GraphqlDemoCacheRepository? repo = _repository;
    if (_isClearing || repo == null) return;
    setState(() => _isClearing = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await repo.clear();
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.settingsGraphqlCacheClearedMessage)),
        );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'GraphqlCacheControlsSection._handleClear failed',
        error,
        stackTrace,
      );
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.settingsGraphqlCacheErrorMessage)),
        );
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final double gap = context.responsiveGapS;
    final double cardPadding = context.responsiveCardPadding;

    return SettingsSection(
      title: l10n.settingsGraphqlCacheSectionTitle,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: context.responsiveGapM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.settingsGraphqlCacheDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: gap),
              Align(
                alignment: Alignment.centerRight,
                child: PlatformAdaptive.textButton(
                  context: context,
                  onPressed: _isClearing ? null : _handleClear,
                  child: _isClearing
                      ? SizedBox(
                          height: context.responsiveGapM,
                          width: context.responsiveGapM,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.settingsGraphqlCacheClearButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
