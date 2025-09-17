import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    final List<({ThemeMode mode, String label})> options =
        <({ThemeMode mode, String label})>[
          (mode: ThemeMode.system, label: l10n.themeModeSystem),
          (mode: ThemeMode.light, label: l10n.themeModeLight),
          (mode: ThemeMode.dark, label: l10n.themeModeDark),
        ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPageTitle)),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, currentMode) {
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: UI.hgapL,
              vertical: UI.gapM,
            ),
            children: <Widget>[
              Text(l10n.themeSectionTitle, style: theme.textTheme.titleMedium),
              SizedBox(height: UI.gapS),
              Card(
                child: Column(
                  children: <Widget>[
                    for (final option in options)
                      ListTile(
                        title: Text(option.label),
                        trailing: currentMode == option.mode
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () =>
                            context.read<ThemeCubit>().setMode(option.mode),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
