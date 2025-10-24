import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

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
    final AppLocalizations l10n = AppLocalizations.of(context);
    return CommonPageLayout(
      title: l10n.settingsPageTitle,
      body: ListView(
        key: const ValueKey('settings-list'),
        padding: EdgeInsets.zero,
        children: <Widget>[
          const AccountSection(),
          SizedBox(height: UI.gapL),
          const ThemeSection(),
          SizedBox(height: UI.gapL),
          const LanguageSection(),
          SizedBox(height: UI.gapL),
          const AppInfoSection(),
          SizedBox(height: UI.gapL),
          TextButton(
            onPressed: () => throw Exception(),
            child: const Text('Throw Test Exception'),
          ),
        ],
      ),
    );
  }
}
