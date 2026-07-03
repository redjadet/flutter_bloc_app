import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/diagnostics/graphql_cache_clear_port.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/diagnostics/settings_diagnostics_widgets.dart';
import 'package:flutter_bloc_app/shared/widgets/settings_section.dart';

class GraphqlCacheControlsSection extends StatefulWidget {
  const GraphqlCacheControlsSection({
    required this.cacheRepository,
    super.key,
  });

  @visibleForTesting
  final GraphqlCacheClearPort cacheRepository;

  @override
  State<GraphqlCacheControlsSection> createState() =>
      _GraphqlCacheControlsSectionState();
}

class _GraphqlCacheControlsSectionState
    extends State<GraphqlCacheControlsSection> {
  bool _isClearing = false;

  Future<void> _handleClear() async {
    final GraphqlCacheClearPort repo = widget.cacheRepository;
    if (_isClearing) return;
    setState(() => _isClearing = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await repo.clear();
      if (!mounted) return;
      ErrorHandling.hideCurrentSnackBar(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsGraphqlCacheClearedMessage)),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'GraphqlCacheControlsSection._handleClear failed',
        error,
        stackTrace,
      );
      if (!mounted) return;
      ErrorHandling.hideCurrentSnackBar(context);
      messenger.showSnackBar(
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

    return SettingsSection(
      title: l10n.settingsGraphqlCacheSectionTitle,
      child: CommonCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.settingsGraphqlCacheDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: gap),
            SettingsDiagnosticsClearButton(
              label: l10n.settingsGraphqlCacheClearButton,
              isBusy: _isClearing,
              onPressed: _isClearing ? null : _handleClear,
            ),
          ],
        ),
      ),
    );
  }
}
