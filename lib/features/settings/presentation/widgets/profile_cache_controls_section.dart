import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class ProfileCacheControlsSection extends StatefulWidget {
  const ProfileCacheControlsSection({
    required this.profileCacheRepository,
    super.key,
  });

  final ProfileCacheRepository profileCacheRepository;

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
    // Fire-and-forget so initState stays synchronous
    unawaited(_loadMetadata());
  }

  Future<void> _handleClearCache() async {
    final ProfileCacheRepository repo = widget.profileCacheRepository;
    if (_isClearing) {
      return;
    }
    setState(() => _isClearing = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await repo.clearProfile();
      await _loadMetadata();
      if (!mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
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
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.settingsProfileCacheErrorMessage)),
        );
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  Future<void> _loadMetadata() async {
    setState(() => _loadingMetadata = true);
    final ProfileCacheMetadata metadata = await widget.profileCacheRepository
        .loadMetadata();
    if (!mounted) {
      return;
    }
    setState(() {
      _metadata = metadata;
      _loadingMetadata = false;
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final double gap = context.responsiveGapS;
    final double cardPadding = context.responsiveCardPadding;

    return SettingsSection(
      title: l10n.settingsProfileCacheSectionTitle,
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
                l10n.settingsProfileCacheDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: gap),
              if (_loadingMetadata)
                Padding(
                  padding: EdgeInsets.only(bottom: gap),
                  child: SizedBox(
                    height: context.responsiveGapM,
                    width: context.responsiveGapM,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_metadata != null)
                Padding(
                  padding: EdgeInsets.only(bottom: gap),
                  child: Text(
                    _formatMetadata(context, _metadata!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: PlatformAdaptive.textButton(
                  context: context,
                  onPressed: _isClearing ? null : _handleClearCache,
                  child: _isClearing
                      ? SizedBox(
                          height: context.responsiveGapM,
                          width: context.responsiveGapM,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.settingsProfileCacheClearButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMetadata(
    final BuildContext context,
    final ProfileCacheMetadata metadata,
  ) {
    final List<String> parts = <String>[];
    if (metadata.lastSyncedAt != null) {
      final DateTime local = metadata.lastSyncedAt!.toLocal();
      final MaterialLocalizations material = MaterialLocalizations.of(context);
      parts.add(
        'Last synced: ${material.formatShortDate(local)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}',
      );
    }
    if (metadata.sizeBytes != null) {
      final int kb = (metadata.sizeBytes! / 1024).ceil();
      parts.add('Cache size: ${kb}KB');
    }
    if (parts.isEmpty) {
      return 'No cached profile';
    }
    return parts.join(' · ');
  }
}
