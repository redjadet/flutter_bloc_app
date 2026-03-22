import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/diagnostics/diagnostics_sync_timestamp.dart';
import 'package:flutter_bloc_app/core/diagnostics/profile_cache_controls_port.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/diagnostics/settings_diagnostics_widgets.dart';
import 'package:flutter_bloc_app/shared/widgets/settings_section.dart';

class ProfileCacheControlsSection extends StatefulWidget {
  const ProfileCacheControlsSection({
    required this.profileCacheRepository,
    super.key,
  });

  final ProfileCacheControlsPort profileCacheRepository;

  @override
  State<ProfileCacheControlsSection> createState() =>
      _ProfileCacheControlsSectionState();
}

class _ProfileCacheControlsSectionState
    extends State<ProfileCacheControlsSection> {
  bool _isClearing = false;
  ProfileCacheMetadata? _metadata;
  bool _loadingMetadata = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMetadata());
  }

  Future<void> _handleClearCache() async {
    final ProfileCacheControlsPort repo = widget.profileCacheRepository;
    if (_isClearing) {
      return;
    }
    setState(() => _isClearing = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await repo.clearProfile();
      if (!mounted) {
        return;
      }
      await _loadMetadata();
      if (!mounted) {
        return;
      }
      ErrorHandling.hideCurrentSnackBar(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsProfileCacheClearedMessage)),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ProfileCacheControlsSection._handleClearCache failed',
        error,
        stackTrace,
      );
      if (!mounted) {
        return;
      }
      ErrorHandling.hideCurrentSnackBar(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsProfileCacheErrorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  Future<void> _loadMetadata() async {
    if (!mounted) {
      return;
    }
    setState(() => _loadingMetadata = true);
    try {
      final ProfileCacheMetadata metadata = await widget.profileCacheRepository
          .loadMetadata();
      if (!mounted) {
        return;
      }
      setState(() {
        _metadata = metadata;
        _loadingMetadata = false;
      });
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ProfileCacheControlsSection._loadMetadata failed',
        error,
        stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() => _loadingMetadata = false);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final double gap = context.responsiveGapS;

    return SettingsSection(
      title: l10n.settingsProfileCacheSectionTitle,
      child: CommonCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.settingsProfileCacheDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: gap),
            if (_loadingMetadata)
              Padding(
                padding: EdgeInsets.only(bottom: gap),
                child: const SettingsDiagnosticsBusyGlyph(),
              )
            else if (_metadata case final meta?)
              Padding(
                padding: EdgeInsets.only(bottom: gap),
                child: Text(
                  _formatMetadata(context, meta),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            SettingsDiagnosticsClearButton(
              label: l10n.settingsProfileCacheClearButton,
              isBusy: _isClearing,
              onPressed: _isClearing ? null : _handleClearCache,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMetadata(
    final BuildContext context,
    final ProfileCacheMetadata metadata,
  ) {
    final List<String> parts = <String>[];
    if (metadata.lastSyncedAt case final t?) {
      if (isPlausibleDiagnosticsSyncTime(t)) {
        final DateTime local = t.toLocal();
        final MaterialLocalizations material = MaterialLocalizations.of(
          context,
        );
        parts.add(
          context.l10n.settingsDiagnosticsLastSyncedAt(
            material.formatShortDate(local),
            material.formatTimeOfDay(TimeOfDay.fromDateTime(local)),
          ),
        );
      }
    }
    if (metadata.sizeBytes case final b?) {
      if (b >= 0) {
        final int kb = (b / 1024).ceil();
        parts.add(context.l10n.settingsDiagnosticsCacheSizeKb(kb));
      }
    }
    if (parts.isEmpty) {
      return metadata.hasProfile
          ? context.l10n.profileCachedProfileDetailsUnavailable
          : context.l10n.profileNoCachedProfile;
    }
    return parts.join(' · ');
  }
}
