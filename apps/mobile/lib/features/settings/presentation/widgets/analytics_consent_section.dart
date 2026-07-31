import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';

/// Settings toggle for consent-gated product analytics collection.
class AnalyticsConsentSection extends StatefulWidget {
  const AnalyticsConsentSection({
    super.key,
    this.consentRepository,
    this.analytics,
  });

  final AnalyticsConsentRepository? consentRepository;
  final ProductAnalytics? analytics;

  @override
  State<AnalyticsConsentSection> createState() =>
      _AnalyticsConsentSectionState();
}

class _AnalyticsConsentSectionState extends State<AnalyticsConsentSection> {
  bool _enabled = false;
  bool _loading = true;
  bool _available = true;
  StreamSubscription<bool>? _changesSubscription;

  AnalyticsConsentRepository? get _consentOrNull {
    if (widget.consentRepository != null) {
      return widget.consentRepository;
    }
    if (getIt.isRegistered<AnalyticsConsentRepository>()) {
      return getIt<AnalyticsConsentRepository>();
    }
    return null;
  }

  ProductAnalytics? get _analyticsOrNull {
    if (widget.analytics != null) {
      return widget.analytics;
    }
    if (getIt.isRegistered<ProductAnalytics>()) {
      return getIt<ProductAnalytics>();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    final AnalyticsConsentRepository? consent = _consentOrNull;
    if (consent != null) {
      _changesSubscription = consent.changes.listen(
        (final enabled) {
          if (!mounted) {
            return;
          }
          setState(() => _enabled = enabled);
        },
        onError: (final Object _, final StackTrace _) {
          // Keep last loaded toggle value if the consent stream fails.
        },
      );
    }
  }

  @override
  void dispose() {
    unawaited(_changesSubscription?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    final AnalyticsConsentRepository? consent = _consentOrNull;
    if (consent == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _available = false;
        _loading = false;
      });
      return;
    }
    final bool enabled = await consent.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _onChanged(final bool value) async {
    final AnalyticsConsentRepository? consent = _consentOrNull;
    final ProductAnalytics? analytics = _analyticsOrNull;
    if (consent == null || analytics == null) {
      return;
    }
    final bool previous = _enabled;
    setState(() => _enabled = value);
    final bool saved = await consent.save(enabled: value);
    if (!saved) {
      if (mounted) {
        setState(() => _enabled = previous);
      }
      return;
    }
    await analytics.setCollectionEnabled(enabled: value);
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    if (!_available) {
      if (kReleaseMode) {
        return SettingsSection(
          title: l10n.settingsAnalyticsConsentSectionTitle,
          child: CommonCard(
            child: ListTile(
              key: const ValueKey('settings-analytics-consent-unavailable'),
              title: Text(l10n.settingsAnalyticsUnavailable),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }
    return SettingsSection(
      title: l10n.settingsAnalyticsConsentSectionTitle,
      child: CommonCard(
        child: SwitchListTile.adaptive(
          key: const ValueKey('settings-analytics-consent-switch'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(l10n.settingsAnalyticsConsentTitle),
          subtitle: Text(l10n.settingsAnalyticsConsentExplanation),
          value: _enabled,
          onChanged: _loading ? null : _onChanged,
        ),
      ),
    );
  }
}
