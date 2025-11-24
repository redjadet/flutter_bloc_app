import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class ProfileCacheControlsSection extends StatefulWidget {
  const ProfileCacheControlsSection({
    super.key,
    this.profileCacheRepository,
  });

  @visibleForTesting
  final ProfileCacheRepository? profileCacheRepository;

  @override
  State<ProfileCacheControlsSection> createState() =>
      _ProfileCacheControlsSectionState();
}

class _ProfileCacheControlsSectionState
    extends State<ProfileCacheControlsSection> {
  bool _isClearing = false;

  ProfileCacheRepository get _repository =>
      widget.profileCacheRepository ?? getIt<ProfileCacheRepository>();

  Future<void> _handleClearCache() async {
    if (_isClearing) {
      return;
    }
    setState(() => _isClearing = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await _repository.clearProfile();
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
}
