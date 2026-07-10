import 'dart:async';

import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';

/// Optional QA/dev-only sections (cache diagnostics, remote config, etc.).
/// Built in [lib/app/router/routes_core.dart] so settings stays decoupled from
/// other features' packages.
typedef SettingsQaExtrasBuilder = List<Widget> Function(BuildContext context);

/// App settings screen: theme, locale, cache clear, and optional app info.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.appInfoRepository,
    required this.showQaExtras,
    this.authRepository,
    this.buildQaExtras,
    super.key,
  });

  final AppInfoRepository appInfoRepository;
  final AuthRepository? authRepository;

  /// When true, render [buildQaExtras] (dev/qa flavors; resolved at router).
  final bool showQaExtras;
  final SettingsQaExtrasBuilder? buildQaExtras;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AppInfoCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AppInfoCubit(repository: widget.appInfoRepository);
    unawaited(_cubit.load());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: _SettingsView(
      authRepository: widget.authRepository,
      showQaExtras: widget.showQaExtras,
      buildQaExtras: widget.buildQaExtras,
    ),
  );
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({
    required this.showQaExtras,
    this.authRepository,
    this.buildQaExtras,
  });

  final AuthRepository? authRepository;
  final bool showQaExtras;
  final SettingsQaExtrasBuilder? buildQaExtras;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final List<Widget> sections = <Widget>[
      AccountSection(
        key: const ValueKey('settings-account'),
        authRepository: authRepository,
      ),
      SizedBox(
        key: const ValueKey('settings-gap-1'),
        height: context.responsiveGapL,
      ),
      const ThemeSection(key: ValueKey('settings-theme')),
      SizedBox(
        key: const ValueKey('settings-gap-2'),
        height: context.responsiveGapL,
      ),
      const IntegrationsSection(key: ValueKey('settings-integrations')),
      SizedBox(
        key: const ValueKey('settings-gap-3'),
        height: context.responsiveGapL,
      ),
      const LanguageSection(key: ValueKey('settings-language')),
      SizedBox(
        key: const ValueKey('settings-gap-4'),
        height: context.responsiveGapL,
      ),
      const AppInfoSection(key: ValueKey('settings-app-info')),
      if (showQaExtras) ...[
        SizedBox(
          key: const ValueKey('settings-gap-qa'),
          height: context.responsiveGapL,
        ),
        ...(buildQaExtras?.call(context) ?? const <Widget>[]),
      ],
      if (!const bool.fromEnvironment('dart.vm.product')) ...[
        SizedBox(
          key: const ValueKey('settings-gap-debug'),
          height: context.responsiveGapL,
        ),
        KeyedSubtree(
          key: const ValueKey('settings-throw-test-exception'),
          child: PlatformAdaptive.textButton(
            context: context,
            onPressed: () =>
                throw Exception('Test exception for error handling'),
            child: Text(l10n.settingsThrowTestException),
          ),
        ),
      ],
    ];
    return CommonPageLayout(
      title: l10n.settingsPageTitle,
      body: ListView(
        key: const ValueKey('settings-list'),
        padding: EdgeInsets.zero,
        children: sections,
      ),
    );
  }
}
