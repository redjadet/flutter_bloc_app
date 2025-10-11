import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/app_info_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/account_section.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/app_info_section.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/language_section.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/theme_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AppInfoCubit(repository: getIt<AppInfoRepository>())..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: RootAwareBackButton(homeTooltip: l10n.homeTitle),
        title: Text(l10n.settingsPageTitle),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: UI.horizontalGapL,
          vertical: UI.gapM,
        ),
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
