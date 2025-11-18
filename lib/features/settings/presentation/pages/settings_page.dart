import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = AppInfoCubit(repository: getIt<AppInfoRepository>());
      unawaited(cubit.load());
      return cubit;
    },
    child: const _SettingsView(),
  );
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.settingsPageTitle,
      body: ListView(
        key: const ValueKey('settings-list'),
        padding: EdgeInsets.zero,
        children: <Widget>[
          const AccountSection(),
          SizedBox(height: context.responsiveGapL),
          const ThemeSection(),
          SizedBox(height: context.responsiveGapL),
          const LanguageSection(),
          SizedBox(height: context.responsiveGapL),
          const AppInfoSection(),
          if (!const bool.fromEnvironment('dart.vm.product')) ...[
            SizedBox(height: context.responsiveGapL),
            const RemoteConfigDiagnosticsSection(),
            SizedBox(height: context.responsiveGapL),
            PlatformAdaptive.textButton(
              context: context,
              onPressed: () =>
                  throw Exception('Test exception for error handling'),
              child: const Text('Throw Test Exception'),
            ),
          ],
        ],
      ),
    );
  }
}
