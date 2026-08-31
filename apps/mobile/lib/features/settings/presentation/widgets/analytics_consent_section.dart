import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/analytics/analytics_consent_repository.dart';
import 'package:flutter_bloc_app/app/analytics/product_analytics.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Settings toggle for consent-gated product analytics collection.
class AnalyticsConsentSection extends StatefulWidget {
  const AnalyticsConsentSection({
    required this.analyticsConsentRepository,
    required this.productAnalytics,
    super.key,
  });

  final AnalyticsConsentRepository analyticsConsentRepository;
  final ProductAnalytics productAnalytics;

  @override
  State<AnalyticsConsentSection> createState() =>
      _AnalyticsConsentSectionState();
}

class _AnalyticsConsentSectionState extends State<AnalyticsConsentSection> {
  bool _enabled = false;
  bool _loading = true;
  bool _mutating = false;
  int _mutationEpoch = 0;
  StreamSubscription<bool>? _changesSubscription;

  @override
  void initState() {
    super.initState();
    _bindConsentRepository();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant AnalyticsConsentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(
      oldWidget.analyticsConsentRepository,
      widget.analyticsConsentRepository,
    )) {
      return;
    }
    unawaited(_changesSubscription?.cancel());
    _mutationEpoch++;
    _mutating = false;
    _bindConsentRepository();
    unawaited(_load());
  }

  @override
  void dispose() {
    unawaited(_changesSubscription?.cancel());
    super.dispose();
  }

  void _bindConsentRepository() {
    _changesSubscription = widget.analyticsConsentRepository.changes.listen(
      (enabled) {
        if (!mounted || _mutating) {
          return;
        }
        setState(() => _enabled = enabled);
      },
      onError: (Object _, StackTrace _) {
        // Keep last loaded toggle value if the consent stream fails.
      },
    );
  }

  Future<void> _load() async {
    final int epoch = _mutationEpoch;
    final bool enabled = await widget.analyticsConsentRepository.load();
    if (!mounted || epoch != _mutationEpoch) {
      return;
    }
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _onChanged(bool value) async {
    if (_mutating) {
      return;
    }
    final bool previous = _enabled;
    final int epoch = ++_mutationEpoch;
    setState(() {
      _enabled = value;
      _mutating = true;
    });
    try {
      final bool saved = await widget.analyticsConsentRepository.save(
        enabled: value,
      );
      if (epoch != _mutationEpoch) {
        return;
      }
      if (!saved) {
        if (mounted) {
          setState(() => _enabled = previous);
        }
        return;
      }
      if (epoch != _mutationEpoch) {
        return;
      }
      // Persist collection flag even if the widget was disposed after save.
      await widget.productAnalytics.setCollectionEnabled(enabled: value);
    } finally {
      if (mounted && epoch == _mutationEpoch) {
        setState(() => _mutating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onChanged: (_loading || _mutating) ? null : _onChanged,
        ),
      ),
    );
  }
}
