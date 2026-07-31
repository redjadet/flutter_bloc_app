import 'dart:async';

import 'package:design_system/design_system.dart';
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

  AnalyticsConsentRepository get _consent =>
      widget.consentRepository ?? getIt<AnalyticsConsentRepository>();

  ProductAnalytics get _analytics =>
      widget.analytics ?? getIt<ProductAnalytics>();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final bool enabled = await _consent.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _onChanged(final bool value) async {
    setState(() => _enabled = value);
    await _consent.save(enabled: value);
    await _analytics.setCollectionEnabled(enabled: value);
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
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
